import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

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

  String perDay(PlanType type) => format(amount / type.weeksPerPeriod / 7);

  String perWeek(PlanType type) => format(amount / type.weeksPerPeriod);

  String perMonth(PlanType type) =>
      format(amount / type.weeksPerPeriod * 52 / 12);
}

class PlanOffer {
  final SubscriptionPlan slot;
  final String productId;
  final ProductDetails? product;
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
  static final Map<String, ProductDetails> _products = {};
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
      if (!await InAppPurchase.instance.isAvailable()) return result;
      final ids = {
        SubscriptionPlan.monthly: rc.getProductId(SubscriptionPlan.monthly),
        SubscriptionPlan.yearly: rc.getProductId(SubscriptionPlan.yearly),
      }..removeWhere((_, id) => id.isEmpty);
      if (ids.isEmpty) return result;
      await _query(ids.values.toSet());
      for (final entry in ids.entries) {
        final p = _products[entry.value];
        if (p != null) result[entry.key] = _price(p);
      }
      _cache = result;
      await refreshTrialEligibility();
    } catch (e) {
      debugPrint('Price fetch failed, using defaults: $e');
    }
    return result;
  }

  static ProductDetails? productFor(String productId) => _products[productId];

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

  static Future<ProductDetails?> fetchProduct(String productId) async {
    if (!_products.containsKey(productId)) await _query({productId});
    return _products[productId];
  }

  static Future<void> _query(Set<String> ids) async {
    final response = await InAppPurchase.instance
        .queryProductDetails(ids)
        .timeout(const Duration(seconds: 10));
    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
    }
    final byId = <String, List<ProductDetails>>{};
    for (final p in response.productDetails) {
      (byId[p.id] ??= []).add(p);
    }
    for (final entry in byId.entries) {
      _products[entry.key] = _pick(entry.value);
    }
  }

  /// Play returns one entry per base plan and offer, and only offers the
  /// user is eligible for: prefer the free trial, then the base plan.
  static ProductDetails _pick(List<ProductDetails> options) {
    final play = options.whereType<GooglePlayProductDetails>();
    return play.where((p) => getFreeTrialPeriod(p) != null).firstOrNull ??
        play.where((p) => _playOffer(p)?.offerId == null).firstOrNull ??
        options.first;
  }

  static SubscriptionOfferDetailsWrapper? _playOffer(
    GooglePlayProductDetails p,
  ) {
    final index = p.subscriptionIndex;
    final offers = p.productDetails.subscriptionOfferDetails;
    return index == null || offers == null ? null : offers[index];
  }

  /// The renewal price, not a trial or intro phase.
  static PlanPrice _price(ProductDetails p) {
    if (p is GooglePlayProductDetails) {
      final phase = _playOffer(p)?.pricingPhases.lastOrNull;
      if (phase != null) {
        return PlanPrice(
          phase.priceAmountMicros / 1000000,
          phase.priceCurrencyCode,
          phase.formattedPrice,
        );
      }
    }
    return PlanPrice(p.rawPrice, p.currencyCode, p.price);
  }

  /// ISO 8601, e.g. P1M.
  static String? _subscriptionPeriod(ProductDetails? p) {
    if (p is GooglePlayProductDetails) {
      return _playOffer(p)?.pricingPhases.lastOrNull?.billingPeriod;
    }
    if (p is AppStoreProduct2Details) {
      final period = p.sk2Product.subscription?.subscriptionPeriod;
      if (period != null) return _iso(period);
    }
    return null;
  }

  static String _iso(SK2SubscriptionPeriod period) =>
      'P${period.value}${period.unit.name[0].toUpperCase()}';

  static Future<void> refreshTrialEligibility() async {
    final products = Map<String, ProductDetails>.of(_products);
    if (products.isEmpty) return;
    try {
      if (Platform.isAndroid) {
        trialEligibility.addAll({
          for (final entry in products.entries)
            entry.key: getFreeTrialPeriod(entry.value) != null,
        });
        return;
      }
      final ids = products.keys.toList();
      final eligible = await Future.wait(
        ids.map(SK2Product.isIntroductoryOfferEligible),
      ).timeout(const Duration(seconds: 10));
      trialEligibility.addAll({
        for (var i = 0; i < ids.length; i++) ids[i]: eligible[i],
      });
    } catch (e) {
      debugPrint('Trial eligibility check failed: $e');
      trialEligibility.addAll({for (final id in products.keys) id: false});
    }
  }

  /// 1. The store's subscription period, 2. the product id, 3. [fallback].
  static PlanType getPlanType(
    ProductDetails? p, {
    required String productId,
    required PlanType fallback,
  }) {
    final match = RegExp(r'^P(\d+)([DWMY])$')
        .firstMatch(_subscriptionPeriod(p) ?? '');
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

  static String? getFreeTrialPeriod(ProductDetails? p) {
    String? period;
    var cycles = 1;
    if (p is GooglePlayProductDetails) {
      final free = _playOffer(p)?.pricingPhases
          .where((phase) => phase.priceAmountMicros == 0)
          .firstOrNull;
      if (free == null) return null;
      period = free.billingPeriod;
      cycles = free.billingCycleCount;
    } else if (p is AppStoreProduct2Details) {
      final intro = p.sk2Product.subscription?.promotionalOffers
          .where(
            (o) =>
                o.type == SK2SubscriptionOfferType.introductory &&
                o.paymentMode == SK2SubscriptionOfferPaymentMode.freeTrial,
          )
          .firstOrNull;
      if (intro == null) return null;
      period = _iso(intro.period);
      cycles = intro.periodCount;
    }
    final match = RegExp(r'^P(\d+)([DWMY])$').firstMatch(period ?? '');
    if (match == null) return null;
    final unit = switch (match.group(2)) {
      'D' => 'day',
      'W' => 'week',
      'M' => 'month',
      _ => 'year',
    };
    final count = int.parse(match.group(1)!) * (cycles < 1 ? 1 : cycles);
    return '$count $unit${count > 1 ? 's' : ''}';
  }

  static String? getEligibleTrialPeriod(ProductDetails? p) {
    if (p == null || trialEligibility[p.id] != true) return null;
    return getFreeTrialPeriod(p);
  }

  static String getCtaLabel(ProductDetails? selected) {
    if (getEligibleTrialPeriod(selected) != null) return 'Start Free Trial';
    final text = RemoteConfigService.to.buttonText.trim();
    if (text.isEmpty || text.toLowerCase().contains('trial')) return 'Continue';
    return text;
  }
}
