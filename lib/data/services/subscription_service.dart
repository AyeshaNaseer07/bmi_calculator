import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import '../../log_transition.dart';
import '../models/remote_model.dart';
import 'price_service.dart';
import 'remote_config_service.dart';
import 'storage_service.dart';

enum SubscriptionPlan { weekly, monthly, yearly }

enum PremiumPurchaseResult {
  purchased,
  alreadySubscribed,
  pending,
  cancelled,
  failed,
}

enum PremiumRestoreResult { restored, nothingToRestore, failed }

enum _Entitlement { active, inactive, unknown }

class SubscriptionService {
  final StorageService _storage;

  SubscriptionService(this._storage);

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  String? _buyingId;
  Completer<PremiumPurchaseResult>? _buying;
  final Set<String> _awaitingApproval = {};
  bool _busy = false;
  bool get isBusy => _busy;
  void Function(bool isPremium)? onChanged;
  bool get isPremium => _storage.getIsPremium();

  // ───────────────────────── lifecycle ─────────────────────────
  void start() {
    _sub ??= _iap.purchaseStream.listen(
      _onUpdates,
      onError: (Object e) => debugPrint('[IAP] stream error: $e'),
    );
    PlatformCode.listenForEntitlementChanges(() {
      debugPrint('[IAP] StoreKit transaction update → re-checking');
      unawaited(checkExpiry());
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> checkExpiry() async {
    await PlatformCode.finishUnfinishedTransactions();
    if (!isPremium || _busy) return;
    final state = await _entitlement();
    if (_busy) return;
    if (state == _Entitlement.inactive) {
      debugPrint('[IAP] subscription no longer active → premium off');
      await _setPremium(false);
    }
  }

  // ───────────────────────── purchase ─────────────────────────
  Future<PremiumPurchaseResult> purchase(String productId) async {
    if (_busy) return PremiumPurchaseResult.failed;
    _busy = true;
    try {
      // 1. Already subscribed on this Apple ID? Restore instead of buying.
      if (await _entitlement() == _Entitlement.active) {
        debugPrint('[IAP] already subscribed → restoring, no store sheet');
        await _setPremium(true);
        return PremiumPurchaseResult.alreadySubscribed;
      }

      // 2. Normal purchase. Finish leftovers first, otherwise StoreKit
      await PlatformCode.finishUnfinishedTransactions();
      final product = await PriceService.fetchProduct(productId);
      if (product == null) {
        debugPrint('[IAP] product not found: $productId');
        return PremiumPurchaseResult.failed;
      }

      _buyingId = productId;
      _buying = Completer<PremiumPurchaseResult>();
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) return PremiumPurchaseResult.failed;

      var result = await _waitForPurchase(productId);

      if (result == PremiumPurchaseResult.failed &&
          await _entitlement() == _Entitlement.active) {
        await _setPremium(true);
        return PremiumPurchaseResult.alreadySubscribed;
      }

      switch (result) {
        case PremiumPurchaseResult.purchased:
          await _setPremium(true);
          unawaited(PlatformCode.logTransactionToFirebase(txt: productId));
        case PremiumPurchaseResult.pending:
          _awaitingApproval.add(productId);
        default:
          break;
      }
      return result;
    } catch (e) {
      debugPrint('[IAP] purchase error: $e');
      return PremiumPurchaseResult.failed;
    } finally {
      _buyingId = null;
      _buying = null;
      _busy = false;
      unawaited(PriceService.refreshTrialEligibility());
    }
  }

  Future<PremiumPurchaseResult> _waitForPurchase(String productId) {
    final done = Completer<PremiumPurchaseResult>();
    void finish(PremiumPurchaseResult r) {
      if (!done.isCompleted) done.complete(r);
    }

    _buying!.future.then(finish);

    if (Platform.isIOS) {
      unawaited(() async {
        for (var i = 0; i < 90 && !done.isCompleted; i++) {
          await Future<void>.delayed(const Duration(seconds: 2));
          if (done.isCompleted) return;
          final status = await PlatformCode.getSubscriptionStatus([productId]);
          if (status == 'active') {
            return finish(PremiumPurchaseResult.purchased);
          }
        }
        finish(PremiumPurchaseResult.failed);
      }());
    }
    return done.future;
  }

  // ───────────────────────── restore ─────────────────────────

  Future<PremiumRestoreResult> restore() async {
    if (_busy) return PremiumRestoreResult.failed;
    _busy = true;
    try {
      // 1. StoreKit 2 entitlements: no sign-in prompt.
      var state = await _entitlement();

      // 2. Replay transactions, then check again.
      if (state != _Entitlement.active) {
        await _iap.restorePurchases();
        await Future<void>.delayed(const Duration(milliseconds: 800));
        state = await _entitlement();
      }

      // 3. Force a sync with the App Store (may ask for the Apple ID
      if (state != _Entitlement.active && Platform.isIOS) {
        try {
          await _iap
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
              .sync();
        } catch (e) {
          debugPrint('[IAP] sync failed/cancelled: $e');
        }
        state = await _entitlement();
      }

      switch (state) {
        case _Entitlement.active:
          await _setPremium(true);
          return PremiumRestoreResult.restored;
        case _Entitlement.inactive:
          return PremiumRestoreResult.nothingToRestore;
        case _Entitlement.unknown:
          return PremiumRestoreResult.failed;
      }
    } catch (e) {
      debugPrint('[IAP] restore error: $e');
      return PremiumRestoreResult.failed;
    } finally {
      _busy = false;
      unawaited(PriceService.refreshTrialEligibility());
    }
  }

  // ───────────────────────── stream ─────────────────────────
  Future<void> _onUpdates(List<PurchaseDetails> updates) async {
    for (final p in updates) {
      if (p.pendingCompletePurchase && p.purchaseID != null) {
        unawaited(_complete(p));
      }

      final isCurrent = _buyingId != null && p.productID == _buyingId;
      switch (p.status) {
        case PurchaseStatus.purchased:
          if (isCurrent) {
            _finish(PremiumPurchaseResult.purchased);
          } else if (_awaitingApproval.remove(p.productID)) {
            // Ask to Buy approved later in this session.
            await _setPremium(true);
          } else if (!_busy) {
            // Renewal, refund or revocation: re-check (can only turn OFF).
            unawaited(checkExpiry());
          }
        case PurchaseStatus.restored:
          break;
        case PurchaseStatus.pending:
          if (isCurrent) _finish(PremiumPurchaseResult.pending);
        case PurchaseStatus.canceled:
          if (isCurrent) _finish(PremiumPurchaseResult.cancelled);
        case PurchaseStatus.error:
          if (isCurrent) {
            debugPrint('[IAP] error for ${p.productID}: ${p.error}');
            _finish(PremiumPurchaseResult.failed);
          }
      }
    }
  }

  void _finish(PremiumPurchaseResult r) {
    final c = _buying;
    if (c != null && !c.isCompleted) c.complete(r);
  }

  Future<void> _complete(PurchaseDetails p) async {
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      debugPrint('[IAP] completePurchase failed: $e');
    }
  }

  // ───────────────────────── helpers ─────────────────────────
  Future<_Entitlement> _entitlement() async {
    if (!Platform.isIOS) return _Entitlement.unknown;
    final status = await PlatformCode.getSubscriptionStatus(
      _productIds().toList(),
    );
    debugPrint('[IAP] entitlement: $status');
    return switch (status) {
      'active' => _Entitlement.active,
      'expired' || 'revoked' || 'none' => _Entitlement.inactive,
      _ => _Entitlement.unknown,
    };
  }

  /// Defaults plus whatever Remote Config names on either paywall.
  Set<String> _productIds() {
    final ids = <String>{
      RemoteModel.defaultWeeklyProductId,
      RemoteModel.defaultYearlyProductId,
      ?_buyingId,
    };
    try {
      final rc = RemoteConfigService.to;
      for (final paywall in PaywallType.values) {
        for (final plan in SubscriptionPlan.values) {
          ids.add(rc.getProductId(plan, paywall).trim());
        }
      }
    } catch (_) {
      // Remote Config not ready: defaults cover it.
    }
    return ids..remove('');
  }

  Future<void> _setPremium(bool premium) async {
    await _storage.setIsPremium(premium);
    onChanged?.call(premium);
  }
}
