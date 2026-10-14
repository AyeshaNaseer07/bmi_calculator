import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'remote_config_service.dart';
import 'subscription_service.dart';

/// Price of one subscription plan as returned by the store.
class PlanPrice {
  final double amount;
  final String currencyCode;
  final String priceString;

  const PlanPrice(this.amount, this.currencyCode, this.priceString);

  String format(double v) {
    try {
      return NumberFormat.simpleCurrency(name: currencyCode).format(v);
    } catch (_) {
      return '$currencyCode ${v.toStringAsFixed(2)}';
    }
  }

  /// Monthly plan → equivalent price per week.
  String get perWeek => format(amount * 12 / 52);

  /// Yearly plan → equivalent price per month.
  String get perMonth => format(amount / 12);
}

/// Loads plan prices from the store (RevenueCat). Falls back to the
/// default USD prices if the store can't be reached in time.
class PriceService {
  static const Map<SubscriptionPlan, PlanPrice> fallback = {
    SubscriptionPlan.monthly: PlanPrice(4.99, 'USD', '\$4.99'),
    SubscriptionPlan.yearly: PlanPrice(29.99, 'USD', '\$29.99'),
  };

  static Map<SubscriptionPlan, PlanPrice>? _cache;

  static Future<Map<SubscriptionPlan, PlanPrice>> load(
    RemoteConfigService rc,
  ) async {
    if (_cache != null) return _cache!;
    final result = Map<SubscriptionPlan, PlanPrice>.of(fallback);
    try {
      if (!await Purchases.isConfigured) return result;
      final ids = {
        SubscriptionPlan.monthly: rc.getProductId(SubscriptionPlan.monthly),
        SubscriptionPlan.yearly: rc.getProductId(SubscriptionPlan.yearly),
      }..removeWhere((_, id) => id.isEmpty);
      if (ids.isEmpty) return result;
      final products = await Purchases.getProducts(
        ids.values.toList(),
      ).timeout(const Duration(seconds: 10));
      for (final entry in ids.entries) {
        for (final p in products) {
          // Android ids can carry a ":base-plan" suffix.
          if (p.identifier == entry.value ||
              p.identifier.split(':').first == entry.value) {
            result[entry.key] = PlanPrice(p.price, p.currencyCode, p.priceString);
          }
        }
      }
      _cache = result;
    } catch (e) {
      debugPrint('Price fetch failed, using defaults: $e');
    }
    return result;
  }
}
