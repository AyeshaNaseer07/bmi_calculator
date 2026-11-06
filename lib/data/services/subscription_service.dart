import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../log_transition.dart';
import '../models/remote_model.dart';
import 'price_service.dart';
import 'remote_config_service.dart';
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

  /// Product ids StoreKit replayed as restored while a restore or an
  /// entitlement check is running; null otherwise.
  Set<String>? _restored;
  DateTime? _lastRestoredEventAt;
  bool _restoring = false;
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
    // A purchase or restore in progress decides the status itself.
    if (_purchase != null || _restoring) return null;
    if (!await _isLinked()) {
      await _setPremium(false);
      return false;
    }
    try {
      if (Platform.isIOS) {
        // StoreKit's own entitlement state is authoritative and needs no
        // timing luck, unlike the purchase stream below.
        final status = await _storeStatus();
        if (_purchase != null || _restoring) return null;
        if (status == 'active') {
          await _setPremium(true);
          return true;
        }
      }
      final active = (await _activeProductIds()).isNotEmpty;
      // A purchase or restore started meanwhile and owns the status now.
      if (_purchase != null || _restoring) return null;
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
          if (Platform.isIOS) {
            unawaited(PlatformCode.logTransactionToFirebase(txt: id));
          }
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
  ///
  /// Asks StoreKit for the entitlement directly first, then replays the
  /// purchase history through the purchase stream and waits for it to
  /// settle, and only then falls back to `sync()` (which may ask for the
  /// Apple ID password). Any restored product unlocks premium.
  Future<bool> restorePurchases() async {
    if (_restoring) return false;
    _restoring = true;
    final seen = _restored = <String>{};
    try {
      var active = await _restoreCheck(seen);
      if (!active && Platform.isIOS) {
        // Asks for the Apple ID password, so only on the user's tap.
        await _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
            .sync();
        active = await _restoreCheck(seen);
      }
      debugPrint('Restore result: active=$active, restored=$seen');
      if (!active) return false;
      await _link();
      await _setPremium(true);
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    } finally {
      if (identical(_restored, seen)) _restored = null;
      _restoring = false;
      unawaited(PriceService.refreshTrialEligibility());
    }
  }

  Future<bool> _restoreCheck(Set<String> seen) async {
    if (Platform.isIOS) {
      final status = await _storeStatus();
      if (status == 'active') return true;
    }
    await _iap.restorePurchases();
    await _waitForRestoredEvents(seen, minWait: const Duration(seconds: 3));
    return seen.isNotEmpty;
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
    // iOS returns once StoreKit is done, but the purchase stream's update can
    // trail the reply (or never arrive). So the stream is raced against
    // StoreKit's own entitlement state, and whichever answers first wins.
    if (Platform.isIOS) return _iosOutcome(id, result);
    return result;
  }

  Future<_Outcome> _iosOutcome(String id, Future<_Outcome> fromStream) {
    final done = Completer<_Outcome>();
    void finish(_Outcome outcome) {
      if (!done.isCompleted) done.complete(outcome);
    }

    fromStream.then(finish);
    unawaited(() async {
      for (var i = 0; i < 10 && !done.isCompleted; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (done.isCompleted) return;
        final status = await PlatformCode.getSubscriptionStatus([id]);
        debugPrint('Entitlement after purchase ($id): $status');
        if (status == 'active') return finish(_Outcome.purchased);
      }
      if (done.isCompleted) return;
      try {
        finish(
          (await _activeProductIds()).contains(id)
              ? _Outcome.purchased
              : _Outcome.failed,
        );
      } catch (_) {
        finish(_Outcome.failed);
      }
    }());
    return done.future;
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
          _noteRestored(p.productID);
        case PurchaseStatus.purchased:
          if (isOwnPurchase) {
            _finishPurchase(_Outcome.purchased);
          } else if (_restoring) {
            // Replayed history can arrive as "purchased" during a restore.
            _noteRestored(p.productID);
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

  void _noteRestored(String productId) {
    debugPrint('Restored product from store: $productId');
    _restored?.add(productId);
    _lastRestoredEventAt = DateTime.now();
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
    // StoreKit 2 replays Transaction.currentEntitlements on the purchase
    // stream as restored purchases, without a sign-in prompt.
    final owner = _restored == null;
    final restored = _restored ??= <String>{};
    try {
      await _iap.restorePurchases();
      await _waitForRestoredEvents(restored);
      return {...restored};
    } finally {
      if (owner && identical(_restored, restored)) _restored = null;
    }
  }

  /// StoreKit gives no "restore finished" signal, so wait until restored
  /// purchases have arrived and then stopped coming. With none at all, give
  /// up after [minWait].
  Future<void> _waitForRestoredEvents(
    Set<String> seen, {
    Duration minWait = const Duration(milliseconds: 1500),
  }) async {
    const quiet = Duration(milliseconds: 800);
    const maxWait = Duration(seconds: 8);
    final started = DateTime.now();
    _lastRestoredEventAt = null;
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final now = DateTime.now();
      final elapsed = now.difference(started);
      if (elapsed >= maxWait) return;
      if (seen.isEmpty) {
        if (elapsed >= minWait) return;
      } else if (now.difference(_lastRestoredEventAt ?? started) >= quiet) {
        return;
      }
    }
  }

  static const _knownProductIds = [
    RemoteModel.defaultWeeklyProductId,
    RemoteModel.defaultYearlyProductId,
  ];

  /// Every product id this app can sell: the defaults, whatever Remote
  /// Config currently names for each paywall, and the one being bought.
  Set<String> _candidateProductIds() {
    final ids = <String>{..._knownProductIds, ?_purchaseProductId};
    try {
      final rc = RemoteConfigService.to;
      for (final paywall in PaywallType.values) {
        for (final plan in [
          SubscriptionPlan.monthly,
          SubscriptionPlan.yearly,
        ]) {
          ids.add(rc.getProductId(plan, paywall).trim());
        }
      }
    } catch (_) {
      // Remote Config not ready yet: the defaults still cover the common case.
    }
    return ids..remove('');
  }

  /// StoreKit 2 entitlement for any of this app's products: `active`,
  /// `revoked`, `expired`, `none` or `unknown`.
  Future<String> _storeStatus() async {
    final status = await PlatformCode.getSubscriptionStatus(
      _candidateProductIds().toList(),
    );
    debugPrint('Store entitlement status: $status');
    return status;
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
