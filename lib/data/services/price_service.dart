import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

import 'localization_service.dart';
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

  /// Null when the store didn't return this product.
  final PlanPrice? price;

  const PlanOffer({
    required this.slot,
    required this.productId,
    required this.product,
    required this.type,
    required this.price,
  });

  bool get isAvailable => product != null && price != null;
}

class PriceService {
  static final Map<String, ProductDetails> _products = {};
  static final RxMap<String, bool> trialEligibility = <String, bool>{}.obs;
  static final Map<PaywallType, Future<Map<SubscriptionPlan, PlanPrice>>>
  _inFlight = {};

  /// Prices for whichever of this paywall's current product ids are loaded.
  /// Keyed by product id, so a wrong id never borrows another product's price.
  static Map<SubscriptionPlan, PlanPrice> cached(PaywallType paywall) =>
      _pricesFor(RemoteConfigService.to, paywall);

  static Map<SubscriptionPlan, PlanPrice> _pricesFor(
    RemoteConfigService rc,
    PaywallType paywall,
  ) {
    final result = <SubscriptionPlan, PlanPrice>{};
    for (final slot in [SubscriptionPlan.monthly, SubscriptionPlan.yearly]) {
      final p = _products[rc.getProductId(slot, paywall)];
      if (p != null) result[slot] = _price(p);
    }
    return result;
  }

  static void preload(RemoteConfigService rc) {
    for (final type in PaywallType.values) {
      load(rc, type);
    }
  }

  /// Concurrent callers share one fetch.
  static Future<Map<SubscriptionPlan, PlanPrice>> load(
    RemoteConfigService rc,
    PaywallType paywall,
  ) {
    final running = _inFlight[paywall];
    if (running != null) return running;
    final future = _load(
      rc,
      paywall,
    ).whenComplete(() => _inFlight.remove(paywall));
    return _inFlight[paywall] = future;
  }

  static Future<Map<SubscriptionPlan, PlanPrice>> _load(
    RemoteConfigService rc,
    PaywallType paywall,
  ) async {
    try {
      if (!await InAppPurchase.instance.isAvailable()) {
        return _pricesFor(rc, paywall);
      }
      final ids = {
        for (final slot in [SubscriptionPlan.monthly, SubscriptionPlan.yearly])
          rc.getProductId(slot, paywall).trim(),
      }..remove('');
      // Each id is queried on its own: one invalid id must not affect the
      // others. Already-loaded ids are not fetched again.
      await Future.wait(
        ids.where((id) => !_products.containsKey(id)).map(fetchProduct),
      );
      await refreshTrialEligibility();
    } catch (e) {
      debugPrint('Price fetch failed: $e');
    }
    return _pricesFor(rc, paywall);
  }

  static ProductDetails? productFor(String productId) => _products[productId];

  static PlanOffer offerFor(
    SubscriptionPlan slot,
    RemoteConfigService rc,
    PaywallType paywall,
  ) {
    final productId = rc.getProductId(slot, paywall);
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
      price: product == null ? null : _price(product),
    );
  }

  /// Never throws; an unknown or failing id simply yields null.
  static Future<ProductDetails?> fetchProduct(String productId) async {
    if (productId.isEmpty) return null;
    if (!_products.containsKey(productId)) {
      try {
        await _query({productId});
      } catch (e) {
        debugPrint('Product query failed for $productId: $e');
      }
    }
    return _products[productId];
  }

  static Future<void> _query(Set<String> ids) async {
    final response = await InAppPurchase.instance
        .queryProductDetails(ids)
        .timeout(const Duration(seconds: 10));
    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found in store: ${response.notFoundIDs}');
    }
    final byId = <String, List<ProductDetails>>{};
    for (final p in response.productDetails) {
      (byId[p.id] ??= []).add(p);
    }
    for (final entry in byId.entries) {
      _products[entry.key] = _pick(entry.value);
    }
  }

  static ProductDetails _pick(List<ProductDetails> options) => options.first;

  static PlanPrice _price(ProductDetails p) {
    return PlanPrice(p.rawPrice, p.currencyCode, p.price);
  }

  /// ISO 8601, e.g. P1M.
  static String? _subscriptionPeriod(ProductDetails? p) {
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
    if (p is AppStoreProduct2Details) {
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

  static String getCtaLabel(ProductDetails? selected, PaywallType paywall) {
    if (getEligibleTrialPeriod(selected) != null) return 'start_free_trial'.tr;
    final text = RemoteConfigService.to.paywallBtnText(paywall).trim();
    if (text.isEmpty || text.toLowerCase().contains('trial')) {
      return 'continue_btn'.tr;
    }
    final localized = LocalizationService.trEnglish(text);
    if (localized == text && Get.locale?.languageCode != 'en') {
      return 'continue_btn'.tr;
    }
    return localized;
  }
}
