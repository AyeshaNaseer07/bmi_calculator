import 'dart:io';

import 'package:flutter/foundation.dart';

class RemoteModel {
  String firstTimeOnboarding;
  String secondTimeOnboarding;
  String paywallBtnText;
  int crossDelay;
  String monthlyProductId;
  String yearlyProductId;
  String nativeAdId;
  String ads;
  String localNotification;

  static String get defaultNativeAdId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';

  RemoteModel({
    required this.firstTimeOnboarding,
    required this.secondTimeOnboarding,
    required this.paywallBtnText,
    required this.crossDelay,
    required this.monthlyProductId,
    required this.yearlyProductId,
    required this.nativeAdId,
    required this.ads,
    required this.localNotification,
  });

  // Convenience boolean helpers
  bool get isFirstTimeOnboarding =>
      firstTimeOnboarding.toLowerCase() == 'on' ||
      firstTimeOnboarding.toLowerCase() == 'true';

  bool get isSecondTimeOnboarding =>
      secondTimeOnboarding.toLowerCase() == 'on' ||
      secondTimeOnboarding.toLowerCase() == 'true';

  bool get isAdsEnabled =>
      ads.toLowerCase() == 'on' || ads.toLowerCase() == 'true';

  bool get isLocalNotificationEnabled =>
      localNotification.toLowerCase() == 'on' ||
      localNotification.toLowerCase() == 'true';

  // Compatibility aliases
  String get splashProductId => monthlyProductId;
  String get splashYearlyProductId => yearlyProductId;
  int get splashProductCrossDelay => crossDelay;
  String get splashProductBtnText => paywallBtnText;

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
        firstTimeOnboarding: _parseString(
          remoteConfig['first_time_onboarding'] ??
              remoteConfig['firstTimeOnboarding'] ??
              remoteConfig['is_first_time_onboarding'] ??
              remoteConfig['onboarding'],
          'on',
        ),
        secondTimeOnboarding: _parseString(
          remoteConfig['second_time_onboarding'] ??
              remoteConfig['secondTimeOnboarding'] ??
              remoteConfig['is_second_time_onboarding'],
          'off',
        ),
        paywallBtnText: _parseString(
          remoteConfig['paywall_btn_text'] ??
              remoteConfig['paywall_button_text'] ??
              remoteConfig['splash_product_btn_text'] ??
              remoteConfig['button_text'],
          'Start Free Trial',
        ),
        crossDelay: _parseInt(
          remoteConfig['cross_delay'] ??
              remoteConfig['paywall_cross_delay'] ??
              remoteConfig['splash_product_cross_delay'],
          3,
        ),
        monthlyProductId: _parseString(
          remoteConfig['monthly_product_id'] ??
              remoteConfig['splash_product_id'],
          'com.monthly.bmi.calculator',
        ),
        yearlyProductId: _parseString(
          remoteConfig['yearly_product_id'] ??
              remoteConfig['splashYearlyProductId'] ??
              remoteConfig['splash_yearly_product_id'],
          'com.yearly.bmi.calculator',
        ),
        nativeAdId: _parseString(
          remoteConfig['native_ad_id'] ??
              remoteConfig['ad_id'] ??
              remoteConfig['native_ad_unit_id'] ??
              remoteConfig['nativeAdId'],
          defaultNativeAdId,
        ),
        ads: _parseString(
          remoteConfig['ads'] ??
              remoteConfig['ads_enabled'] ??
              remoteConfig['is_ads_enabled'] ??
              remoteConfig['ads_on_off'],
          'on',
        ),
        localNotification: _parseString(
          remoteConfig['local_notification'] ??
              remoteConfig['local_notifications'] ??
              remoteConfig['notification'] ??
              remoteConfig['local_notification_enabled'],
          'on',
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
      firstTimeOnboarding: 'on',
      secondTimeOnboarding: 'off',
      paywallBtnText: 'Start Free Trial',
      crossDelay: 3,
      monthlyProductId: 'com.monthly.bmi.calculator',
      yearlyProductId: 'com.yearly.bmi.calculator',
      nativeAdId: defaultNativeAdId,
      ads: 'on',
      localNotification: 'on',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_time_onboarding': firstTimeOnboarding,
      'second_time_onboarding': secondTimeOnboarding,
      'paywall_btn_text': paywallBtnText,
      'cross_delay': crossDelay,
      'monthly_product_id': monthlyProductId,
      'yearly_product_id': yearlyProductId,
      'native_ad_id': nativeAdId,
      'ads': ads,
      'local_notification': localNotification,
    };
  }
}

RemoteModel remoteModel = RemoteModel.defaults();
