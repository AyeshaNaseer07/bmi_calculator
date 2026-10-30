import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'price_service.dart';
import 'storage_service.dart';

enum SubscriptionPlan { weekly, monthly, yearly }

enum _Outcome { purchased, pending, failed }

/// Premium is only granted to the install a purchase or restore was made on,
/// so a reinstall stays free until Restore. The store can always revoke it.
class SubscriptionService {
  final StorageService _storageService;

  SubscriptionService(this._storageService);

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseUpdates;
  Completer<_Outcome>? _purchase;
  String? _purchaseProductId;
  Set<String>? _restored;
  Future<Set<String>>? _entitlementCheck;
  String? _installId;

  /// Called whenever the stored premium status is written.
  void Function(bool isPremium)? onChanged;

  bool get isPremium => _storageService.getIsPremium();

  void start() {
    _purchaseUpdates ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) => debugPrint('Purchase stream error: $e'),
    );
  }

  void dispose() {
    _purchaseUpdates?.cancel();
    _purchaseUpdates = null;
  }

  /// Null if the store couldn't be reached; the stored status is kept then.
  Future<bool?> verifyWithStore() async {
    if (!await _isLinked()) {
      await _setPremium(false);
      return false;
    }
    // A purchase in progress decides the status itself.
    if (_purchase != null) return null;
    try {
      final active = (await _activeProductIds()).isNotEmpty;
      await _setPremium(active);
      return active;
    } catch (e) {
      debugPrint('Subscription verification failed: $e');
      return null;
    }
  }

  Future<bool> purchase(SubscriptionPlan plan, {String? productId}) async {
    if (_purchase != null) return false;
    final id = productId ?? plan.name;
    final wasLinked = await _isLinked();
    _purchase = Completer<_Outcome>();
    _purchaseProductId = id;
    try {
      var outcome = await _buy(id);
      if (outcome == _Outcome.failed &&
          (await _activeProductIds()).contains(id)) {
        // "Already subscribed": the user asked for it, so it counts.
        outcome = _Outcome.purchased;
      }
      switch (outcome) {
        case _Outcome.purchased:
          await _setPremium(true);
          return true;
        case _Outcome.pending:
          // Ask to Buy and similar: the purchase stream unlocks it later.
          return false;
        case _Outcome.failed:
          if (!wasLinked) await _unlink();
          return false;
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (!wasLinked) await _unlink();
      return false;
    } finally {
      _purchase = null;
      _purchaseProductId = null;
      unawaited(PriceService.refreshTrialEligibility());
    }
  }

  /// The only way a purchase made before a reinstall unlocks premium again.
  Future<bool> restorePurchases() async {
    try {
      var active = await _activeProductIds();
      if (active.isEmpty && Platform.isIOS) {
        // Asks for the Apple ID password, so only on the user's tap.
        await _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
            .sync();
        active = await _activeProductIds();
      }
      if (active.isEmpty) return false;
      await _link();
      await _setPremium(true);
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    } finally {
      unawaited(PriceService.refreshTrialEligibility());
    }
  }

  Future<_Outcome> _buy(String id) async {
    final product = await PriceService.fetchProduct(id);
    if (product == null) {
      debugPrint('Product not found in store: $id');
      return _Outcome.failed;
    }
    // Linked before the store sheet opens, so a purchase that finishes
    // after the app was killed still unlocks premium on the next launch.
    await _link();
    final started = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    if (!started) return _Outcome.failed;
    final result = _purchase!.future;
    // iOS returns once StoreKit is done; its update can trail the reply.
    if (Platform.isIOS) {
      return result.timeout(
        const Duration(seconds: 5),
        onTimeout: () async => (await _activeProductIds()).contains(id)
            ? _Outcome.purchased
            : _Outcome.failed,
      );
    }
    return result;
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> updates) async {
    for (final p in updates) {
      // Unacknowledged Play purchases are refunded after 3 days.
      if (p.pendingCompletePurchase && p.status != PurchaseStatus.pending) {
        unawaited(_complete(p));
      }
      final isOwnPurchase =
          _purchase != null && p.productID == _purchaseProductId;
      switch (p.status) {
        case PurchaseStatus.restored:
          _restored?.add(p.productID);
        case PurchaseStatus.purchased:
          if (isOwnPurchase) {
            _finishPurchase(_Outcome.purchased);
          } else {
            // Renewal, refund, Ask to Buy approval: re-read the entitlements.
            unawaited(verifyWithStore());
          }
        case PurchaseStatus.pending:
          if (isOwnPurchase) _finishPurchase(_Outcome.pending);
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          if (isOwnPurchase) _finishPurchase(_Outcome.failed);
      }
    }
  }

  void _finishPurchase(_Outcome outcome) {
    final purchase = _purchase;
    if (purchase != null && !purchase.isCompleted) purchase.complete(outcome);
  }

  Future<void> _complete(PurchaseDetails p) async {
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      debugPrint('Complete purchase failed: $e');
    }
  }

  /// Products the store currently grants. Refunded and expired
  /// subscriptions aren't included. Throws if the store can't be reached.
  Future<Set<String>> _activeProductIds() => _entitlementCheck ??=
      _queryActiveProductIds().whenComplete(() => _entitlementCheck = null);

  Future<Set<String>> _queryActiveProductIds() async {
    if (Platform.isAndroid) {
      final response = await _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .queryPastPurchases();
      if (response.error != null) throw response.error!;
      final owned = response.pastPurchases.where(
        (p) => p.status == PurchaseStatus.purchased,
      );
      for (final p in owned) {
        if (p.pendingCompletePurchase) unawaited(_complete(p));
      }
      return owned.map((p) => p.productID).toSet();
    }
    // StoreKit 2 replays Transaction.currentEntitlements on the purchase
    // stream as restored purchases, without a sign-in prompt.
    final restored = _restored = <String>{};
    try {
      await _iap.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return restored;
    } finally {
      _restored = null;
    }
  }

  Future<void> _setPremium(bool premium) async {
    await _storageService.setIsPremium(premium);
    onChanged?.call(premium);
  }

  Future<bool> _isLinked() async =>
      _storageService.getPremiumInstallId() == await _currentInstallId();

  Future<void> _link() async =>
      _storageService.setPremiumInstallId(await _currentInstallId());

  Future<void> _unlink() async {
    await _storageService.setPremiumInstallId(null);
    await _setPremium(false);
  }

  /// Changes on every fresh install; app updates keep it.
  Future<String> _currentInstallId() async {
    if (_installId != null) return _installId!;
    String id = 'unknown';
    try {
      final time = (await PackageInfo.fromPlatform()).installTime;
      if (time != null) id = '${time.millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Install time unavailable: $e');
    }
    return _installId = id;
  }
}
