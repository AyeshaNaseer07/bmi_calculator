import 'package:flutter/foundation.dart';

class RemoteModel {
  String? _firstTimeOnboarding;
  String? _secondTimeOnboarding;
  String? _paywallBtnText;
  int? _crossDelay;
  String? _weeklyProductId;
  String? _yearlyProductId;
  String? _fullScreenNativeAd;
  String? _languageNativeAd;
  String? _onboardingNativeAd;
  String? _fullScreenNativeAdId;
  String? _languageNativeAdId;
  String? _onboardingNativeAdId;
  String? _appOpenAd;
  String? _appOpenAdId;
  String? _splashInterAd;
  String? _splashInterAdId;
  String? _paywallCrossInterAd;
  String? _paywallCrossInterAdId;
  String? _calculatorInterAd;
  String? _calculatorInterAdId;
  String? _localNotification;
  String? _notificationFrequency;

  // AppLovin MAX ad units; Remote Config overrides each one.
  static const String defaultAppOpenAdId = '8912e79bed7e47df';
  static const String defaultSplashInterAdId = '85b22c87e3ca84c2';
  static const String defaultPaywallCrossInterAdId = 'ff833ded57dafd9a';
  static const String defaultCalculatorInterAdId = '0a4481fa2371003a';
  static const String defaultFullScreenNativeAdId = '2854da2e9e4a2bc5';
  static const String defaultLanguageNativeAdId = '18189ba9818ddf0a';
  static const String defaultOnboardingNativeAdId = '99f2f2b2c1b0ca6a';

  String get firstTimeOnboarding => _firstTimeOnboarding ?? 'on';
  set firstTimeOnboarding(String value) => _firstTimeOnboarding = value;

  String get secondTimeOnboarding => _secondTimeOnboarding ?? 'off';
  set secondTimeOnboarding(String value) => _secondTimeOnboarding = value;

  String get paywallBtnText => _paywallBtnText ?? '';
  set paywallBtnText(String value) => _paywallBtnText = value;

  int get crossDelay => _crossDelay ?? 3;
  set crossDelay(int value) => _crossDelay = value;

  String get weeklyProductId =>
      _weeklyProductId ?? 'com.weekly.bmi.calculator.app';
  set weeklyProductId(String value) => _weeklyProductId = value;

  String get yearlyProductId =>
      _yearlyProductId ?? 'com.yearly.bmi.calculator.app';
  set yearlyProductId(String value) => _yearlyProductId = value;

  String get fullScreenNativeAd => _fullScreenNativeAd ?? 'on';
  set fullScreenNativeAd(String value) => _fullScreenNativeAd = value;

  String get languageNativeAd => _languageNativeAd ?? 'on';
  set languageNativeAd(String value) => _languageNativeAd = value;

  String get onboardingNativeAd => _onboardingNativeAd ?? 'on';
  set onboardingNativeAd(String value) => _onboardingNativeAd = value;

  String get fullScreenNativeAdId =>
      _fullScreenNativeAdId ?? defaultFullScreenNativeAdId;
  set fullScreenNativeAdId(String value) => _fullScreenNativeAdId = value;

  String get languageNativeAdId =>
      _languageNativeAdId ?? defaultLanguageNativeAdId;
  set languageNativeAdId(String value) => _languageNativeAdId = value;

  String get onboardingNativeAdId =>
      _onboardingNativeAdId ?? defaultOnboardingNativeAdId;
  set onboardingNativeAdId(String value) => _onboardingNativeAdId = value;

  String get appOpenAd => _appOpenAd ?? 'on';
  set appOpenAd(String value) => _appOpenAd = value;

  String get appOpenAdId => _appOpenAdId ?? defaultAppOpenAdId;
  set appOpenAdId(String value) => _appOpenAdId = value;

  String get splashInterAd => _splashInterAd ?? 'on';
  set splashInterAd(String value) => _splashInterAd = value;

  String get splashInterAdId => _splashInterAdId ?? defaultSplashInterAdId;
  set splashInterAdId(String value) => _splashInterAdId = value;

  String get paywallCrossInterAd => _paywallCrossInterAd ?? 'on';
  set paywallCrossInterAd(String value) => _paywallCrossInterAd = value;

  String get paywallCrossInterAdId =>
      _paywallCrossInterAdId ?? defaultPaywallCrossInterAdId;
  set paywallCrossInterAdId(String value) => _paywallCrossInterAdId = value;

  String get calculatorInterAd => _calculatorInterAd ?? 'on';
  set calculatorInterAd(String value) => _calculatorInterAd = value;

  String get calculatorInterAdId =>
      _calculatorInterAdId ?? defaultCalculatorInterAdId;
  set calculatorInterAdId(String value) => _calculatorInterAdId = value;

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
    this._fullScreenNativeAd,
    this._languageNativeAd,
    this._onboardingNativeAd,
    this._fullScreenNativeAdId,
    this._languageNativeAdId,
    this._onboardingNativeAdId,
    this._appOpenAd,
    this._appOpenAdId,
    this._splashInterAd,
    this._splashInterAdId,
    this._paywallCrossInterAd,
    this._paywallCrossInterAdId,
    this._calculatorInterAd,
    this._calculatorInterAdId,
    this._localNotification,
    this._notificationFrequency,
  });

  bool get isFirstTimeOnboarding => _isOn(firstTimeOnboarding);

  static bool _isOn(String? v) {
    if (v == null) return false;
    final s = v.trim().toLowerCase();
    return s == 'on' || s == 'true';
  }

  bool get isFullScreenNativeAdEnabled => _isOn(fullScreenNativeAd);

  /// App open ad shown when returning to the app from the background.
  bool get isAppOpenAdEnabled => _isOn(appOpenAd);
  bool get isLanguageNativeAdEnabled => _isOn(languageNativeAd);
  bool get isOnboardingNativeAdEnabled => _isOn(onboardingNativeAd);

  bool get isSplashInterAdEnabled => _isOn(splashInterAd);
  bool get isPaywallCrossInterAdEnabled => _isOn(paywallCrossInterAd);
  bool get isCalculatorInterAdEnabled => _isOn(calculatorInterAd);

  bool get isLocalNotificationEnabled => _isOn(localNotification);

  // Compatibility aliases
  String get splashYearlyProductId => yearlyProductId;

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
          remoteConfig['premium_btn_text'] ??
              remoteConfig['paywall_btn_text'] ??
              remoteConfig['paywall_button_text'] ??
              remoteConfig['splash_product_btn_text'] ??
              remoteConfig['button_text'],
          '',
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
        languageNativeAd: _parseString(
          remoteConfig['language_native_ad'] ??
              remoteConfig['languageNativeAd'],
          'on',
        ),
        onboardingNativeAd: _parseString(
          remoteConfig['onboarding_native_ad'] ??
              remoteConfig['onboardingNativeAd'],
          'on',
        ),
        fullScreenNativeAd: _parseString(
          remoteConfig['full_screen_native_ad'] ??
              remoteConfig['fullscreen_native_ad'] ??
              remoteConfig['full_screen_native'] ??
              remoteConfig['fullScreenNativeAd'],
          'on',
        ),
        fullScreenNativeAdId: _parseString(
          remoteConfig['full_screen_native_ad_id'] ??
              remoteConfig['fullscreen_native_ad_id'] ??
              remoteConfig['fullScreenNativeAdId'],
          defaultFullScreenNativeAdId,
        ),
        languageNativeAdId: _parseString(
          remoteConfig['language_native_ad_id'] ??
              remoteConfig['languageNativeAdId'],
          defaultLanguageNativeAdId,
        ),
        onboardingNativeAdId: _parseString(
          remoteConfig['onboarding_native_ad_id'] ??
              remoteConfig['onboardingNativeAdId'],
          defaultOnboardingNativeAdId,
        ),
        appOpenAd: _parseString(
          remoteConfig['app_open_ad'] ?? remoteConfig['appOpenAd'],
          'on',
        ),
        appOpenAdId: _parseString(
          remoteConfig['app_open_ad_id'] ?? remoteConfig['appOpenAdId'],
          defaultAppOpenAdId,
        ),
        splashInterAd: _parseString(
          remoteConfig['splash_inter_ad'] ?? remoteConfig['splashInterAd'],
          'on',
        ),
        splashInterAdId: _parseString(
          remoteConfig['splash_inter_ad_id'] ?? remoteConfig['splashInterAdId'],
          defaultSplashInterAdId,
        ),
        paywallCrossInterAd: _parseString(
          remoteConfig['paywall_cross_inter_ad'] ??
              remoteConfig['paywallCrossInterAd'],
          'on',
        ),
        paywallCrossInterAdId: _parseString(
          remoteConfig['paywall_cross_inter_ad_id'] ??
              remoteConfig['paywallCrossInterAdId'],
          defaultPaywallCrossInterAdId,
        ),
        calculatorInterAd: _parseString(
          remoteConfig['calculator_inter_ad'] ??
              remoteConfig['calculatorInterAd'],
          'on',
        ),
        calculatorInterAdId: _parseString(
          remoteConfig['calculator_inter_ad_id'] ??
              remoteConfig['calculatorInterAdId'],
          defaultCalculatorInterAdId,
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
      paywallBtnText: '',
      crossDelay: 3,
      weeklyProductId: 'com.weekly.bmi.calculator.app',
      yearlyProductId: 'com.yearly.bmi.calculator.app',
      languageNativeAd: 'on',
      onboardingNativeAd: 'on',
      fullScreenNativeAd: 'on',
      fullScreenNativeAdId: defaultFullScreenNativeAdId,
      languageNativeAdId: defaultLanguageNativeAdId,
      onboardingNativeAdId: defaultOnboardingNativeAdId,
      appOpenAd: 'on',
      appOpenAdId: defaultAppOpenAdId,
      splashInterAd: 'on',
      splashInterAdId: defaultSplashInterAdId,
      paywallCrossInterAd: 'on',
      paywallCrossInterAdId: defaultPaywallCrossInterAdId,
      calculatorInterAd: 'on',
      calculatorInterAdId: defaultCalculatorInterAdId,
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
      'language_native_ad': languageNativeAd,
      'onboarding_native_ad': onboardingNativeAd,
      'full_screen_native_ad': fullScreenNativeAd,
      'full_screen_native_ad_id': fullScreenNativeAdId,
      'language_native_ad_id': languageNativeAdId,
      'onboarding_native_ad_id': onboardingNativeAdId,
      'app_open_ad': appOpenAd,
      'app_open_ad_id': appOpenAdId,
      'splash_inter_ad': splashInterAd,
      'splash_inter_ad_id': splashInterAdId,
      'paywall_cross_inter_ad': paywallCrossInterAd,
      'paywall_cross_inter_ad_id': paywallCrossInterAdId,
      'calculator_inter_ad': calculatorInterAd,
      'calculator_inter_ad_id': calculatorInterAdId,
      'local_notification': localNotification,
      'show_notification_frequency': notificationFrequency,
    };
  }
}

RemoteModel remoteModel = RemoteModel.defaults();
