import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'remote_config_service.dart';
import 'subscription_service.dart';

/// What a product actually is, decided from the store product itself rather
/// than from the Remote Config slot it was put in. Rank = enum index.
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

  /// Equivalent price per week for a plan of [type].
  String perWeek(PlanType type) => format(amount / type.weeksPerPeriod);

  /// Equivalent price per month for a plan of [type].
  String perMonth(PlanType type) =>
      format(amount / type.weeksPerPeriod * 52 / 12);
}

/// Everything a paywall card needs for one Remote Config slot.
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

/// Loads plan products from the store (RevenueCat) and works out plan type,
/// free trial and CTA text from them. Falls back to the default USD prices
/// if the store can't be reached in time.
class PriceService {
  static const Map<SubscriptionPlan, PlanPrice> fallback = {
    SubscriptionPlan.monthly: PlanPrice(4.99, 'USD', '\$4.99'),
    SubscriptionPlan.yearly: PlanPrice(29.99, 'USD', '\$29.99'),
  };

  static Map<SubscriptionPlan, PlanPrice>? _cache;

  /// Store products by product id (Android ids also stored without the
  /// ":base-plan" suffix).
  static final Map<String, StoreProduct> _products = {};

  /// Free-trial eligibility per product id. Missing = not eligible (yet).
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

  /// Card data for [slot], using the loaded [prices] (or the fallback).
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

  /// Re-checks free-trial eligibility for every loaded product. Call when
  /// products load and after every purchase or restore.
  static Future<void> refreshTrialEligibility() async {
    final products = {for (final p in _products.values) p.identifier: p};
    if (products.isEmpty) return;
    try {
      if (Platform.isAndroid) {
        // Google Play only returns offers the user is eligible for, so a
        // free phase on the default option means the user can take it.
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

  /// The product's free-trial length ("3 days", "1 week"), or null if its
  /// introductory offer isn't a free trial. Promotional and win-back offers
  /// are ignored. Does not check eligibility; UI should use
  /// [getEligibleTrialPeriod].
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

  /// Trial length only if the product has a free trial AND the user is
  /// eligible for it. All trial UI must go through this.
  static String? getEligibleTrialPeriod(StoreProduct? p) {
    if (p == null || trialEligibility[p.identifier] != true) return null;
    return getFreeTrialPeriod(p);
  }

  static String getCtaLabel(StoreProduct? selected) {
    if (getEligibleTrialPeriod(selected) != null) return 'Start Free Trial';
    final text = RemoteConfigService.to.buttonText.trim();
    // Never show trial wording from Remote Config to someone without a trial.
    if (text.isEmpty || text.toLowerCase().contains('trial')) return 'Continue';
    return text;
  }
}
