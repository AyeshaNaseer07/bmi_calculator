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

/// Paywall plan slots. `monthly` is the weekly slot (kept for Remote Config
/// and PriceService compatibility).
enum SubscriptionPlan { weekly, monthly, yearly }

/// What happened after the user tapped Continue on a paywall.
enum PremiumPurchaseResult {
  /// New purchase completed: show the congrats dialog.
  purchased,

  /// The Apple ID already had an active subscription. No store sheet was
  /// shown and nothing was charged; premium was restored instead.
  alreadySubscribed,

  /// Waiting on Ask to Buy / SCA. Premium unlocks later by itself.
  pending,

  /// The user closed the store sheet.
  cancelled,

  /// Product missing, network error, store error.
  failed,
}

/// What happened after the user tapped Restore.
enum PremiumRestoreResult { restored, nothingToRestore, failed }

/// StoreKit 2 entitlement state from the native side.
enum _Entitlement { active, inactive, unknown }

/// iOS purchase flow.
///
/// Rules:
/// * Premium is only switched ON by an explicit user action: Continue
///   (purchase or "already subscribed" restore) or Restore. A reinstall
///   therefore goes through splash → onboarding → paywall as normal.
/// * Premium is switched OFF at launch when StoreKit says the subscription
///   expired, was refunded or doesn't exist for this Apple ID.
/// * Before opening the store sheet, Continue checks StoreKit 2's current
///   entitlements. If already subscribed, Apple's "You're already
///   subscribed" sheet is skipped and premium is restored in-app.
class SubscriptionService {
  final StorageService _storage;

  SubscriptionService(this._storage);

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// The purchase the user is currently making, if any.
  String? _buyingId;
  Completer<PremiumPurchaseResult>? _buying;

  /// Ask to Buy purchases waiting for approval in this session.
  final Set<String> _awaitingApproval = {};

  bool _busy = false;

  /// True while a purchase or restore is running. Paywalls use this to
  /// ignore premium changes they caused themselves.
  bool get isBusy => _busy;

  /// Called whenever the stored premium status changes.
  void Function(bool isPremium)? onChanged;

  bool get isPremium => _storage.getIsPremium();

  // ───────────────────────── lifecycle ─────────────────────────

  void start() {
    _sub ??= _iap.purchaseStream.listen(
      _onUpdates,
      onError: (Object e) => debugPrint('[IAP] stream error: $e'),
    );
    // Refunds / revocations / expiries while the app is open (including
    // Xcode → Debug → StoreKit → Manage Transactions → Refund).
    PlatformCode.listenForEntitlementChanges(() {
      debugPrint('[IAP] StoreKit transaction update → re-checking');
      unawaited(checkExpiry());
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// Turns premium OFF if the subscription is gone (expired, refunded,
  /// revoked). Runs at launch, on resume and on every StoreKit update.
  /// Never turns premium ON (that needs Continue or Restore).
  Future<void> checkExpiry() async {
    // Clears stuck transactions (e.g. a refunded one) so the product can be
    // bought again.
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
      //    rejects it with "storekit_duplicate_product_object".
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

      // The store can report an error when the user was in fact subscribed
      // (e.g. signed in to a different Apple ID mid-flow). Trust StoreKit.
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

  /// Waits for the purchase stream, but also polls StoreKit 2 because the
  /// stream event can arrive late or not at all on iOS.
  Future<PremiumPurchaseResult> _waitForPurchase(String productId) {
    final done = Completer<PremiumPurchaseResult>();
    void finish(PremiumPurchaseResult r) {
      if (!done.isCompleted) done.complete(r);
    }

    _buying!.future.then(finish);

    if (Platform.isIOS) {
      unawaited(() async {
        // Poll every 2s for up to 3 minutes (the store sheet stays open as
        // long as the user needs). If nothing ever answers, give up.
        for (var i = 0; i < 90 && !done.isCompleted; i++) {
          await Future<void>.delayed(const Duration(seconds: 2));
          if (done.isCompleted) return;
          final status = await PlatformCode.getSubscriptionStatus([productId]);
          if (status == 'active') return finish(PremiumPurchaseResult.purchased);
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
      //    password; fine because the user tapped Restore).
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
      // Pending/cancelled updates carry no transaction id (purchaseID is
      // null) and completing them throws a null-check error.
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

  /// StoreKit 2 `Transaction.currentEntitlements` for any of this app's
  /// products, read natively (no sign-in prompt, works offline from cache).
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
