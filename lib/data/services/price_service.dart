import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'remote_config_service.dart';
import 'subscription_service.dart';

enum PlanType {
  weekly('Weekly', 'week', 1),
  monthly('Monthly', 'month', 52 / 12),
  yearly('Yearly', 'year', 52),
  lifetime('Lifetime', null, 0);

  const PlanType(this.title, this.periodWord, this.weeksPerPeriod);

  final String title;
  final String? periodWord;
  final double weeksPerPeriod;

  int get rank => index;
}

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

  String perWeek(PlanType type) => format(amount / type.weeksPerPeriod);

  String perMonth(PlanType type) =>
      format(amount / type.weeksPerPeriod * 52 / 12);
}

class PlanOffer {
  final SubscriptionPlan slot;
  final String productId;
  final StoreProduct? product;
  final PlanType type;
  final PlanPrice price;

  const PlanOffer({
    required this.slot,
    required this.productId,
    required this.product,
    required this.type,
    required this.price,
  });
}

class PriceService {
  static const Map<SubscriptionPlan, PlanPrice> fallback = {
    SubscriptionPlan.monthly: PlanPrice(4.99, 'USD', '\$4.99'),
    SubscriptionPlan.yearly: PlanPrice(29.99, 'USD', '\$29.99'),
  };

  static Map<SubscriptionPlan, PlanPrice>? _cache;
  static final Map<String, StoreProduct> _products = {};
  static final RxMap<String, bool> trialEligibility = <String, bool>{}.obs;
  static Future<Map<SubscriptionPlan, PlanPrice>> load(
    RemoteConfigService rc,
  ) async {
    if (_cache != null) {
      await refreshTrialEligibility();
      return _cache!;
    }
    final result = Map<SubscriptionPlan, PlanPrice>.of(fallback);
    try {
      if (!await Purchases.isConfigured) return result;
      final ids = {
        SubscriptionPlan.monthly: rc.getProductId(SubscriptionPlan.monthly),
        SubscriptionPlan.yearly: rc.getProductId(SubscriptionPlan.yearly),
      }..removeWhere((_, id) => id.isEmpty);
      if (ids.isEmpty) return result;
      final products = await Purchases.getProducts(ids.values.toList())
          .timeout(const Duration(seconds: 10));
      for (final p in products) {
        _products[p.identifier] = p;
        _products[p.identifier.split(':').first] = p;
      }
      for (final entry in ids.entries) {
        final p = _products[entry.value];
        if (p != null) {
          result[entry.key] = PlanPrice(p.price, p.currencyCode, p.priceString);
        }
      }
      _cache = result;
      await refreshTrialEligibility();
    } catch (e) {
      debugPrint('Price fetch failed, using defaults: $e');
    }
    return result;
  }

  static StoreProduct? productFor(String productId) => _products[productId];

  static PlanOffer offerFor(
    SubscriptionPlan slot,
    RemoteConfigService rc,
    Map<SubscriptionPlan, PlanPrice> prices,
  ) {
    final productId = rc.getProductId(slot);
    final product = productFor(productId);
    return PlanOffer(
      slot: slot,
      productId: productId,
      product: product,
      type: getPlanType(
        product,
        productId: productId,
        fallback: PlanType.values.byName(slot.name),
      ),
      price: prices[slot] ?? fallback[slot]!,
    );
  }

  static Future<void> refreshTrialEligibility() async {
    final products = {for (final p in _products.values) p.identifier: p};
    if (products.isEmpty) return;
    try {
      if (Platform.isAndroid) {
        trialEligibility.addAll({
          for (final p in products.values)
            p.identifier: p.defaultOption?.freePhase != null,
        });
        return;
      }
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
        products.keys.toList(),
      ).timeout(const Duration(seconds: 10));
      trialEligibility.addAll({
        for (final id in products.keys)
          id:
              result[id]?.status ==
              IntroEligibilityStatus.introEligibilityStatusEligible,
      });
    } catch (e) {
      debugPrint('Trial eligibility check failed: $e');
      trialEligibility.addAll({for (final id in products.keys) id: false});
    }
  }

  /// 1. The store's subscription period, 2. the product id, 3. [fallback].
  static PlanType getPlanType(
    StoreProduct? p, {
    required String productId,
    required PlanType fallback,
  }) {
    final match = RegExp(r'^P(\d+)([DWMY])$')
        .firstMatch(p?.subscriptionPeriod ?? '');
    if (match != null) {
      final value = int.parse(match.group(1)!);
      switch (match.group(2)) {
        case 'D':
          if (value >= 7) return PlanType.weekly;
        case 'W':
          return PlanType.weekly;
        case 'M':
          return PlanType.monthly;
        case 'Y':
          return PlanType.yearly;
      }
    }

    final id = productId.toLowerCase();
    if (id.contains('lifetime')) return PlanType.lifetime;
    if (id.contains('year') || id.contains('annual')) return PlanType.yearly;
    if (id.contains('month')) return PlanType.monthly;
    if (id.contains('week')) return PlanType.weekly;
    return fallback;
  }

  static String? getFreeTrialPeriod(StoreProduct? p) {
    final intro = p?.introductoryPrice;
    if (intro == null || intro.price != 0) return null;
    final unit = switch (intro.periodUnit) {
      PeriodUnit.day => 'day',
      PeriodUnit.week => 'week',
      PeriodUnit.month => 'month',
      PeriodUnit.year => 'year',
      PeriodUnit.unknown => null,
    };
    if (unit == null) return null;
    final count =
        intro.periodNumberOfUnits * (intro.cycles < 1 ? 1 : intro.cycles);
    return '$count $unit${count > 1 ? 's' : ''}';
  }

  static String? getEligibleTrialPeriod(StoreProduct? p) {
    if (p == null || trialEligibility[p.identifier] != true) return null;
    return getFreeTrialPeriod(p);
  }

  static String getCtaLabel(StoreProduct? selected) {
    if (getEligibleTrialPeriod(selected) != null) return 'Start Free Trial';
    final text = RemoteConfigService.to.buttonText.trim();
    if (text.isEmpty || text.toLowerCase().contains('trial')) return 'Continue';
    return text;
  }
}
