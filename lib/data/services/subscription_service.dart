import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'price_service.dart';
import 'storage_service.dart';

enum SubscriptionPlan { weekly, monthly, yearly }

class SubscriptionService {
  final StorageService _storageService;

  SubscriptionService(this._storageService);

  bool get isPremium => _storageService.getIsPremium();

  /// Checks the subscription with the App Store / Google Play (through
  /// RevenueCat) and stores the result. A subscription or free trial that was
  /// refunded or revoked comes back inactive, so this removes Premium.
  /// Returns null if the store can't be reached; the stored status is then
  /// left as it was.
  Future<bool?> verifyWithStore() async {
    try {
      if (!await Purchases.isConfigured) return null;
      // Bypass the SDK's cached copy so a refund since the last launch is seen.
      await Purchases.invalidateCustomerInfoCache();
      final info = await Purchases.getCustomerInfo();
      return await applyCustomerInfo(info);
    } catch (e) {
      debugPrint('Subscription verification failed: $e');
      return null;
    }
  }

  /// Stores the premium status implied by [info] and returns it.
  Future<bool> applyCustomerInfo(CustomerInfo info) async {
    final active =
        info.entitlements.active.isNotEmpty ||
        info.activeSubscriptions.isNotEmpty;
    await _storageService.setIsPremium(active);
    return active;
  }

  /// Mock purchase for testing and development using remote product ID
  Future<bool> purchase(SubscriptionPlan plan, {String? productId}) async {
    try {
      final id = productId ?? plan.name;
      debugPrint(
        'Purchasing plan: ${plan.name} with product ID: $id (development mock)',
      );
      await Future.delayed(const Duration(milliseconds: 800));
      await _storageService.setIsPremium(true);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    } finally {
      unawaited(PriceService.refreshTrialEligibility());
    }
  }

  /// Mock restore purchases
  Future<bool> restorePurchases() async {
    try {
      debugPrint('Restoring purchases (development mock)');
      await Future.delayed(const Duration(milliseconds: 600));
      final wasPremium = _storageService.getIsPremium();
      return wasPremium;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    } finally {
      unawaited(PriceService.refreshTrialEligibility());
    }
  }
}
