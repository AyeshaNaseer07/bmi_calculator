import 'dart:io';

import 'package:flutter/foundation.dart';

class RemoteModel {
  String splashProductId;
  String splashYearlyProductId;
  int splashProductCrossDelay;
  String splashProductBtnText;
  String monthlyPrice;
  String yearlyPrice;
  String trialSubtitle;
  String onboarding;
  int premiumDiscountCrossDelay;
  String premiumDiscountBtnText;
  String premiumDiscountOfferProductId;

  String onboardingDefaultSelection;
  String nativeAdId;
  static String get defaultNativeAdId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';

  RemoteModel({
    required this.splashProductId,
    required this.splashYearlyProductId,
    required this.splashProductCrossDelay,
    required this.splashProductBtnText,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.trialSubtitle,
    required this.onboarding,
    required this.premiumDiscountCrossDelay,
    required this.premiumDiscountBtnText,
    required this.premiumDiscountOfferProductId,
    required this.onboardingDefaultSelection,
    required this.nativeAdId,
  });

  static String _parseString(dynamic val, String defaultValue) {
    if (val == null) return defaultValue;
    if (val is Map) {
      final v = val['value'];
      if (v != null) return v.toString();
    }
    if (val is String) return val;
    if (val is bool) return val ? 'on' : 'off';
    return val.toString();
  }

  static int _parseInt(dynamic val, int defaultValue) {
    if (val == null) return defaultValue;
    if (val is Map) {
      val = val['value'];
    }
    if (val == null) return defaultValue;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? defaultValue;
  }

  factory RemoteModel.fromRemoteConfig(Map<String, dynamic> remoteConfig) {
    try {
      return RemoteModel(
        splashProductId: _parseString(
          remoteConfig['splash_product_id'] ??
              remoteConfig['monthly_product_id'],
          'com.monthly.bmi.calculator',
        ),
        splashYearlyProductId: _parseString(
          remoteConfig['splashYearlyProductId'] ??
              remoteConfig['yearly_product_id'],
          'com.yearly.bmi.calculator',
        ),
        splashProductCrossDelay: _parseInt(
          remoteConfig['splash_product_cross_delay'] ??
              remoteConfig['cross_delay'],
          3,
        ),
        splashProductBtnText: _parseString(
          remoteConfig['splash_product_btn_text'] ??
              remoteConfig['button_text'],
          'Start Free Trial',
        ),
        monthlyPrice: _parseString(remoteConfig['monthly_price'], '\$4.99'),
        yearlyPrice: _parseString(remoteConfig['yearly_price'], '\$29.99'),
        trialSubtitle: _parseString(
          remoteConfig['trial_subtitle'],
          '7 Days Free • Cancel Anytime',
        ),
        onboarding: _parseString(remoteConfig['onboarding'], 'on'),
        premiumDiscountCrossDelay: _parseInt(
          remoteConfig['premium_discount_cross_delay'],
          3,
        ),
        premiumDiscountBtnText: _parseString(
          remoteConfig['premium_discount_btn_text'],
          'Start Free Trial',
        ),
        premiumDiscountOfferProductId: _parseString(
          remoteConfig['premium_discount_offer_product_id'],
          'com.offer.bmi.calculator',
        ),
        onboardingDefaultSelection: _parseString(
          remoteConfig['onboarding_default_selection'],
          'com.yearly.bmi.calculator',
        ),
        nativeAdId: _parseString(
          remoteConfig['native_ad_id'] ??
              remoteConfig['native_ad_unit_id'] ??
              remoteConfig['nativeAdId'],
          defaultNativeAdId,
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode || kProfileMode) {
        debugPrint('RemoteModel.fromRemoteConfig error: $e\n$stackTrace');
      }
      return RemoteModel.defaults();
    }
  }

  // Default fallback model
  factory RemoteModel.defaults() {
    return RemoteModel(
      splashProductId: 'com.monthly.bmi.calculator',
      splashYearlyProductId: 'com.yearly.bmi.calculator',
      splashProductCrossDelay: 3,
      splashProductBtnText: 'Start Free Trial',
      monthlyPrice: '\$4.99',
      yearlyPrice: '\$29.99',
      trialSubtitle: '7 Days Free • Cancel Anytime',
      onboarding: 'on',
      premiumDiscountCrossDelay: 3,
      premiumDiscountBtnText: 'Start Free Trial',
      premiumDiscountOfferProductId: 'com.offer.bmi.calculator',
      onboardingDefaultSelection: 'com.yearly.bmi.calculator',
      nativeAdId: defaultNativeAdId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'splash_product_id': splashProductId,
      'splashYearlyProductId': splashYearlyProductId,
      'splash_product_cross_delay': splashProductCrossDelay,
      'splash_product_btn_text': splashProductBtnText,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'trial_subtitle': trialSubtitle,
      'onboarding': onboarding,
      'premium_discount_cross_delay': premiumDiscountCrossDelay,
      'premium_discount_btn_text': premiumDiscountBtnText,
      'premium_discount_offer_product_id': premiumDiscountOfferProductId,
      'onboarding_default_selection': onboardingDefaultSelection,
      'native_ad_id': nativeAdId,
    };
  }
}

RemoteModel remoteModel = RemoteModel.defaults();
