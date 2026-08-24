import 'package:flutter/foundation.dart';
import 'storage_service.dart';

enum SubscriptionPlan {
  monthly,
  yearly,
}

class SubscriptionService {
  final StorageService _storageService;

  SubscriptionService(this._storageService);

  bool get isPremium => _storageService.getIsPremium();

  /// Mock purchase for testing and development
  Future<bool> purchase(SubscriptionPlan plan) async {
    try {
      debugPrint('Purchasing plan: ${plan.name} (development mock)');
      await Future.delayed(const Duration(milliseconds: 800));
      await _storageService.setIsPremium(true);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
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
    }
  }

  Future<void> cancelSubscription() async {
    await _storageService.setIsPremium(false);
  }
}
