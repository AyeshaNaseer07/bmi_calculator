import 'dart:io';

import 'package:flutter/foundation.dart';

class RemoteModel {
  String? _firstTimeOnboarding;
  String? _secondTimeOnboarding;
  String? _paywallBtnText;
  int? _crossDelay;
  String? _weeklyProductId;
  String? _yearlyProductId;
  String? _nativeAdId;
  String? _ads;
  String? _fullScreenNativeAd;
  String? _nativeAd;
  String? _fullScreenNativeAdId;
  String? _localNotification;
  String? _notificationFrequency;

  static String get defaultNativeAdId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';

  String get firstTimeOnboarding => _firstTimeOnboarding ?? 'on';
  set firstTimeOnboarding(String value) => _firstTimeOnboarding = value;

  String get secondTimeOnboarding => _secondTimeOnboarding ?? 'off';
  set secondTimeOnboarding(String value) => _secondTimeOnboarding = value;

  String get paywallBtnText => _paywallBtnText ?? 'Start Free Trial';
  set paywallBtnText(String value) => _paywallBtnText = value;

  int get crossDelay => _crossDelay ?? 3;
  set crossDelay(int value) => _crossDelay = value;

  String get weeklyProductId =>
      _weeklyProductId ?? 'com.weekly.bmi.calculator.app';
  set weeklyProductId(String value) => _weeklyProductId = value;

  String get yearlyProductId =>
      _yearlyProductId ?? 'com.yearly.bmi.calculator.app';
  set yearlyProductId(String value) => _yearlyProductId = value;

  String get nativeAdId => _nativeAdId ?? defaultNativeAdId;
  set nativeAdId(String value) => _nativeAdId = value;

  String get ads => _ads ?? 'on';
  set ads(String value) => _ads = value;

  String get fullScreenNativeAd => _fullScreenNativeAd ?? 'on';
  set fullScreenNativeAd(String value) => _fullScreenNativeAd = value;

  String get nativeAd => _nativeAd ?? 'on';
  set nativeAd(String value) => _nativeAd = value;

  String get fullScreenNativeAdId => _fullScreenNativeAdId ?? defaultNativeAdId;
  set fullScreenNativeAdId(String value) => _fullScreenNativeAdId = value;

  String get localNotification => _localNotification ?? 'on';
  set localNotification(String value) => _localNotification = value;

  String get notificationFrequency => _notificationFrequency ?? 'd';
  set notificationFrequency(String value) => _notificationFrequency = value;

  RemoteModel({
    this._firstTimeOnboarding,
    this._secondTimeOnboarding,
    this._paywallBtnText,
    this._crossDelay,
    this._weeklyProductId,
    this._yearlyProductId,
    this._nativeAdId,
    this._ads,
    this._fullScreenNativeAd,
    this._nativeAd,
    this._fullScreenNativeAdId,
    this._localNotification,
    this._notificationFrequency,
  });

  // Convenience boolean helpers
  bool get isFirstTimeOnboarding => _isOn(firstTimeOnboarding);

  /// Onboarding on every launch after the first one ("onward").
  bool get isSecondTimeOnboarding => _isOn(secondTimeOnboarding);

  static bool _isOn(String? v) {
    if (v == null) return false;
    final s = v.trim().toLowerCase();
    return s == 'on' || s == 'true';
  }

  /// Master switch (legacy `ads` key). Used as the fallback for the two
  /// separate ad switches below when they aren't set in Remote Config.
  bool get isAdsEnabled => _isOn(ads);

  /// Full-screen native ad shown inside onboarding.
  bool get isFullScreenNativeAdEnabled => _isOn(fullScreenNativeAd);

  /// All other (inline/bottom) native ads: language, onboarding slide, home.
  bool get isNativeAdEnabled => _isOn(nativeAd);

  bool get isLocalNotificationEnabled => _isOn(localNotification);

  // Compatibility aliases
  String get splashProductId => weeklyProductId;
  String get splashWeeklyProductId => weeklyProductId;
  String get splashYearlyProductId => yearlyProductId;
  int get splashProductCrossDelay => crossDelay;
  String get splashProductBtnText => paywallBtnText;

  static String _parseString(dynamic val, String defaultValue) {
    if (val == null) return defaultValue;
    if (val is Map) {
      final v = val['value'];
      if (v != null) return v.toString();
    }
    if (val is String) return val.isEmpty ? defaultValue : val;
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
      final String adsMaster = _parseString(
        remoteConfig['ads'] ??
            remoteConfig['ads_enabled'] ??
            remoteConfig['is_ads_enabled'] ??
            remoteConfig['ads_on_off'],
        'on',
      );
      final String nativeAdId = _parseString(
        remoteConfig['native_ad_id'] ??
            remoteConfig['ad_id'] ??
            remoteConfig['native_ad_unit_id'] ??
            remoteConfig['nativeAdId'],
        defaultNativeAdId,
      );
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
              remoteConfig['onward_onboarding'] ??
              remoteConfig['onboarding_onward'] ??
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
        weeklyProductId: _parseString(
          remoteConfig['weekly_product_id'] ??
              remoteConfig['splash_weekly_product_id'] ??
              remoteConfig['weeklyProductId'] ??
              remoteConfig['splash_product_id'],
          'com.weekly.bmi.calculator.app',
        ),
        yearlyProductId: _parseString(
          remoteConfig['yearly_product_id'] ??
              remoteConfig['splashYearlyProductId'] ??
              remoteConfig['splash_yearly_product_id'] ??
              remoteConfig['yearlyProductId'],
          'com.yearly.bmi.calculator.app',
        ),
        nativeAdId: nativeAdId,
        ads: adsMaster,
        // Separate switches; fall back to the `ads` master value if missing.
        fullScreenNativeAd: _parseString(
          remoteConfig['full_screen_native_ad'] ??
              remoteConfig['fullscreen_native_ad'] ??
              remoteConfig['full_screen_native'] ??
              remoteConfig['fullScreenNativeAd'],
          adsMaster,
        ),
        nativeAd: _parseString(
          remoteConfig['native_ad'] ??
              remoteConfig['native_ads'] ??
              remoteConfig['nativeAd'],
          adsMaster,
        ),
        fullScreenNativeAdId: _parseString(
          remoteConfig['full_screen_native_ad_id'] ??
              remoteConfig['fullscreen_native_ad_id'] ??
              remoteConfig['fullScreenNativeAdId'],
          nativeAdId,
        ),
        localNotification: _parseString(
          remoteConfig['local_notification'] ??
              remoteConfig['local_notifications'] ??
              remoteConfig['notification'] ??
              remoteConfig['local_notification_enabled'],
          'on',
        ),
        notificationFrequency: _parseString(
          remoteConfig['show_notification_frequency'] ??
              remoteConfig['notification_frequency'] ??
              remoteConfig['frequency'],
          'd',
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
      weeklyProductId: 'com.weekly.bmi.calculator.app',
      yearlyProductId: 'com.yearly.bmi.calculator.app',
      nativeAdId: defaultNativeAdId,
      ads: 'on',
      fullScreenNativeAd: 'on',
      nativeAd: 'on',
      fullScreenNativeAdId: defaultNativeAdId,
      localNotification: 'on',
      notificationFrequency: 'd',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_time_onboarding': firstTimeOnboarding,
      'second_time_onboarding': secondTimeOnboarding,
      'paywall_btn_text': paywallBtnText,
      'cross_delay': crossDelay,
      'weekly_product_id': weeklyProductId,
      'yearly_product_id': yearlyProductId,
      'native_ad_id': nativeAdId,
      'ads': ads,
      'full_screen_native_ad': fullScreenNativeAd,
      'native_ad': nativeAd,
      'full_screen_native_ad_id': fullScreenNativeAdId,
      'local_notification': localNotification,
      'show_notification_frequency': notificationFrequency,
    };
  }
}

RemoteModel remoteModel = RemoteModel.defaults();
