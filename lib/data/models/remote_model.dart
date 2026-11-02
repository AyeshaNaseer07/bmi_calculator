import 'package:flutter/foundation.dart';

class RemoteModel {
  String? _firstTimeOnboarding;
  String? _secondTimeOnboarding;
  String? _onbPaywallBtnText;
  int? _onbPaywallCrossDelay;
  String? _onbPaywallWeeklyProductId;
  String? _onbPaywallYearlyProductId;
  String? _weekPaywallBtnText;
  int? _weekPaywallCrossDelay;
  String? _weekPaywallWeeklyProductId;
  String? _weekPaywallYearlyProductId;
  String? _fullScreenNativeAd;
  String? _languageNativeAd;
  String? _onboardingNativeAd;
  String? _fullScreenNativeAdId;
  String? _languageNativeAdId;
  String? _onboardingNativeAdId;
  String? _appOpenAd;
  String? _appOpenAdId;
  String? _firstTimeSplashInterAd;
  String? _secondTimeSplashInterAd;
  String? _splashInterAdId;
  String? _onbPaywallEnable;
  String? _onbPaywallId;
  String? _weekPaywallEnable;
  String? _weekPaywallId;
  String? _calculatorInterAd;
  String? _calculatorInterAdId;
  String? _localNotification;
  String? _notificationFrequency;
  String? _softPaywallAccess;
  String? _showAdsDebugger;

  // AppLovin MAX ad units; Remote Config overrides each one.
  static const String defaultWeeklyProductId = 'com.weekly.bmi.calculator.app';
  static const String defaultYearlyProductId = 'com.yearly.bmi.calculator.app';
  static const String defaultAppOpenAdId = '8912e79bed7e47df';
  static const String defaultSplashInterAdId = '85b22c87e3ca84c2';
  // Both paywalls' cross interstitials share this ad unit until set separately.
  static const String defaultPaywallCrossInterAdId = 'ff833ded57dafd9a';
  static const String defaultCalculatorInterAdId = '0a4481fa2371003a';
  static const String defaultFullScreenNativeAdId = '2854da2e9e4a2bc5';
  static const String defaultLanguageNativeAdId = '18189ba9818ddf0a';
  static const String defaultOnboardingNativeAdId = '99f2f2b2c1b0ca6a';

  String get firstTimeOnboarding => _firstTimeOnboarding ?? 'on';
  set firstTimeOnboarding(String value) => _firstTimeOnboarding = value;

  String get secondTimeOnboarding => _secondTimeOnboarding ?? 'off';
  set secondTimeOnboarding(String value) => _secondTimeOnboarding = value;

  // Onboarding paywall (onb_paywall_*).
  String get onbPaywallBtnText => _onbPaywallBtnText ?? '';
  set onbPaywallBtnText(String value) => _onbPaywallBtnText = value;

  int get onbPaywallCrossDelay => _onbPaywallCrossDelay ?? 3;
  set onbPaywallCrossDelay(int value) => _onbPaywallCrossDelay = value;

  String get onbPaywallWeeklyProductId =>
      _onbPaywallWeeklyProductId ?? defaultWeeklyProductId;
  set onbPaywallWeeklyProductId(String value) =>
      _onbPaywallWeeklyProductId = value;

  String get onbPaywallYearlyProductId =>
      _onbPaywallYearlyProductId ?? defaultYearlyProductId;
  set onbPaywallYearlyProductId(String value) =>
      _onbPaywallYearlyProductId = value;

  // Week (soft) paywall (week_paywall_*).
  String get weekPaywallBtnText => _weekPaywallBtnText ?? '';
  set weekPaywallBtnText(String value) => _weekPaywallBtnText = value;

  int get weekPaywallCrossDelay => _weekPaywallCrossDelay ?? 3;
  set weekPaywallCrossDelay(int value) => _weekPaywallCrossDelay = value;

  String get weekPaywallWeeklyProductId =>
      _weekPaywallWeeklyProductId ?? defaultWeeklyProductId;
  set weekPaywallWeeklyProductId(String value) =>
      _weekPaywallWeeklyProductId = value;

  String get weekPaywallYearlyProductId =>
      _weekPaywallYearlyProductId ?? defaultYearlyProductId;
  set weekPaywallYearlyProductId(String value) =>
      _weekPaywallYearlyProductId = value;

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

  /// Splash interstitial until onboarding has been completed once.
  String get firstTimeSplashInterAd => _firstTimeSplashInterAd ?? 'on';
  set firstTimeSplashInterAd(String value) => _firstTimeSplashInterAd = value;

  /// Splash interstitial on every launch after that.
  String get secondTimeSplashInterAd => _secondTimeSplashInterAd ?? 'on';
  set secondTimeSplashInterAd(String value) => _secondTimeSplashInterAd = value;

  String get splashInterAdId => _splashInterAdId ?? defaultSplashInterAdId;
  set splashInterAdId(String value) => _splashInterAdId = value;

  /// Interstitial on the main paywall's cross (`onb_paywall_*`), both after
  /// onboarding and when opened inside the app.
  String get onbPaywallEnable => _onbPaywallEnable ?? 'on';
  set onbPaywallEnable(String value) => _onbPaywallEnable = value;

  String get onbPaywallId => _onbPaywallId ?? defaultPaywallCrossInterAdId;
  set onbPaywallId(String value) => _onbPaywallId = value;

  /// Interstitial on the 1 Week Meal Plan paywall's cross (`week_paywall_*`).
  String get weekPaywallEnable => _weekPaywallEnable ?? 'on';
  set weekPaywallEnable(String value) => _weekPaywallEnable = value;

  String get weekPaywallId => _weekPaywallId ?? defaultPaywallCrossInterAdId;
  set weekPaywallId(String value) => _weekPaywallId = value;

  String get calculatorInterAd => _calculatorInterAd ?? 'on';
  set calculatorInterAd(String value) => _calculatorInterAd = value;

  String get calculatorInterAdId =>
      _calculatorInterAdId ?? defaultCalculatorInterAdId;
  set calculatorInterAdId(String value) => _calculatorInterAdId = value;

  String get localNotification => _localNotification ?? 'on';
  set localNotification(String value) => _localNotification = value;

  String get notificationFrequency => _notificationFrequency ?? 'd';
  set notificationFrequency(String value) => _notificationFrequency = value;

  String get softPaywallAccess => _softPaywallAccess ?? 'true';
  set softPaywallAccess(String value) => _softPaywallAccess = value;

  String get showAdsDebugger => _showAdsDebugger ?? 'off';
  set showAdsDebugger(String value) => _showAdsDebugger = value;

  RemoteModel({
    this._firstTimeOnboarding,
    this._secondTimeOnboarding,
    this._onbPaywallBtnText,
    this._onbPaywallCrossDelay,
    this._onbPaywallWeeklyProductId,
    this._onbPaywallYearlyProductId,
    this._weekPaywallBtnText,
    this._weekPaywallCrossDelay,
    this._weekPaywallWeeklyProductId,
    this._weekPaywallYearlyProductId,
    this._fullScreenNativeAd,
    this._languageNativeAd,
    this._onboardingNativeAd,
    this._fullScreenNativeAdId,
    this._languageNativeAdId,
    this._onboardingNativeAdId,
    this._appOpenAd,
    this._appOpenAdId,
    this._firstTimeSplashInterAd,
    this._secondTimeSplashInterAd,
    this._splashInterAdId,
    this._onbPaywallEnable,
    this._onbPaywallId,
    this._weekPaywallEnable,
    this._weekPaywallId,
    this._calculatorInterAd,
    this._calculatorInterAdId,
    this._localNotification,
    this._notificationFrequency,
    this._softPaywallAccess,
    this._showAdsDebugger,
  });

  bool get isFirstTimeOnboarding => _isOn(firstTimeOnboarding);

  /// Onboarding again on later launches, once it has been completed.
  bool get isSecondTimeOnboarding => _isOn(secondTimeOnboarding);

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

  bool get isFirstTimeSplashInterAdEnabled => _isOn(firstTimeSplashInterAd);
  bool get isSecondTimeSplashInterAdEnabled => _isOn(secondTimeSplashInterAd);
  bool get isOnbPaywallInterAdEnabled => _isOn(onbPaywallEnable);
  bool get isWeekPaywallInterAdEnabled => _isOn(weekPaywallEnable);
  bool get isCalculatorInterAdEnabled => _isOn(calculatorInterAd);

  bool get isLocalNotificationEnabled => _isOn(localNotification);

  /// Closing the 1 Week Meal Plan soft paywall still opens the plan.
  bool get isSoftPaywallAccessEnabled => _isOn(softPaywallAccess);
  bool get isAdsDebuggerEnabled => _isOn(showAdsDebugger);

  // Compatibility aliases

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
        // Old shared keys still apply when a per-paywall key is unset.
        onbPaywallBtnText: _parseString(
          remoteConfig['onb_paywall_btn_text'] ??
              remoteConfig['premium_btn_text'] ??
              remoteConfig['paywall_btn_text'] ??
              remoteConfig['paywall_button_text'] ??
              remoteConfig['splash_product_btn_text'] ??
              remoteConfig['button_text'],
          '',
        ),
        onbPaywallCrossDelay: _parseInt(
          remoteConfig['onb_paywall_cross_delay'] ??
              remoteConfig['cross_delay'] ??
              remoteConfig['paywall_cross_delay'] ??
              remoteConfig['splash_product_cross_delay'],
          3,
        ),
        onbPaywallWeeklyProductId: _parseString(
          remoteConfig['onb_paywall_weekly_product_id'] ??
              remoteConfig['weekly_product_id'] ??
              remoteConfig['splash_weekly_product_id'] ??
              remoteConfig['weeklyProductId'] ??
              remoteConfig['splash_product_id'],
          defaultWeeklyProductId,
        ),
        onbPaywallYearlyProductId: _parseString(
          remoteConfig['onb_paywall_yearly_product_id'] ??
              remoteConfig['yearly_product_id'] ??
              remoteConfig['splashYearlyProductId'] ??
              remoteConfig['splash_yearly_product_id'] ??
              remoteConfig['yearlyProductId'],
          defaultYearlyProductId,
        ),
        weekPaywallBtnText: _parseString(
          remoteConfig['week_paywall_btn_text'] ??
              remoteConfig['premium_btn_text'] ??
              remoteConfig['paywall_btn_text'] ??
              remoteConfig['paywall_button_text'] ??
              remoteConfig['splash_product_btn_text'] ??
              remoteConfig['button_text'],
          '',
        ),
        weekPaywallCrossDelay: _parseInt(
          remoteConfig['week_paywall_cross_delay'] ??
              remoteConfig['cross_delay'] ??
              remoteConfig['paywall_cross_delay'] ??
              remoteConfig['splash_product_cross_delay'],
          3,
        ),
        weekPaywallWeeklyProductId: _parseString(
          remoteConfig['week_paywall_weekly_product_id'] ??
              remoteConfig['weekly_product_id'] ??
              remoteConfig['splash_weekly_product_id'] ??
              remoteConfig['weeklyProductId'] ??
              remoteConfig['splash_product_id'],
          defaultWeeklyProductId,
        ),
        weekPaywallYearlyProductId: _parseString(
          remoteConfig['week_paywall_yearly_product_id'] ??
              remoteConfig['yearly_product_id'] ??
              remoteConfig['splashYearlyProductId'] ??
              remoteConfig['splash_yearly_product_id'] ??
              remoteConfig['yearlyProductId'],
          defaultYearlyProductId,
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
        // The old single splash_inter_ad key still applies if a new one is unset.
        firstTimeSplashInterAd: _parseString(
          remoteConfig['first_time_splash_inter_ad'] ??
              remoteConfig['firstTimeSplashInterAd'] ??
              remoteConfig['splash_inter_ad'] ??
              remoteConfig['splashInterAd'],
          'on',
        ),
        secondTimeSplashInterAd: _parseString(
          remoteConfig['second_time_splash_inter_ad'] ??
              remoteConfig['secondTimeSplashInterAd'] ??
              remoteConfig['splash_inter_ad'] ??
              remoteConfig['splashInterAd'],
          'on',
        ),
        splashInterAdId: _parseString(
          remoteConfig['splash_inter_ad_id'] ?? remoteConfig['splashInterAdId'],
          defaultSplashInterAdId,
        ),
        onbPaywallEnable: _parseString(
          remoteConfig['onb_paywall_enable'],
          'on',
        ),
        onbPaywallId: _parseString(
          remoteConfig['onb_paywall_id'],
          defaultPaywallCrossInterAdId,
        ),
        weekPaywallEnable: _parseString(
          remoteConfig['week_paywall_enable'],
          'on',
        ),
        weekPaywallId: _parseString(
          remoteConfig['week_paywall_id'],
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
        softPaywallAccess: _parseString(
          remoteConfig['soft_paywall_access'] ??
              remoteConfig['softPaywallAccess'],
          'true',
        ),
        showAdsDebugger: _parseString(
          remoteConfig['show_ads_debugger'] ?? remoteConfig['showAdsDebugger'],
          'off',
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
      onbPaywallBtnText: '',
      onbPaywallCrossDelay: 3,
      onbPaywallWeeklyProductId: defaultWeeklyProductId,
      onbPaywallYearlyProductId: defaultYearlyProductId,
      weekPaywallBtnText: '',
      weekPaywallCrossDelay: 3,
      weekPaywallWeeklyProductId: defaultWeeklyProductId,
      weekPaywallYearlyProductId: defaultYearlyProductId,
      languageNativeAd: 'on',
      onboardingNativeAd: 'on',
      fullScreenNativeAd: 'on',
      fullScreenNativeAdId: defaultFullScreenNativeAdId,
      languageNativeAdId: defaultLanguageNativeAdId,
      onboardingNativeAdId: defaultOnboardingNativeAdId,
      appOpenAd: 'on',
      appOpenAdId: defaultAppOpenAdId,
      firstTimeSplashInterAd: 'on',
      secondTimeSplashInterAd: 'on',
      splashInterAdId: defaultSplashInterAdId,
      onbPaywallEnable: 'on',
      onbPaywallId: defaultPaywallCrossInterAdId,
      weekPaywallEnable: 'on',
      weekPaywallId: defaultPaywallCrossInterAdId,
      calculatorInterAd: 'on',
      calculatorInterAdId: defaultCalculatorInterAdId,
      localNotification: 'on',
      notificationFrequency: 'd',
      softPaywallAccess: 'true',
      showAdsDebugger: 'off',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_time_onboarding': firstTimeOnboarding,
      'second_time_onboarding': secondTimeOnboarding,
      'onb_paywall_btn_text': onbPaywallBtnText,
      'onb_paywall_cross_delay': onbPaywallCrossDelay,
      'onb_paywall_weekly_product_id': onbPaywallWeeklyProductId,
      'onb_paywall_yearly_product_id': onbPaywallYearlyProductId,
      'week_paywall_btn_text': weekPaywallBtnText,
      'week_paywall_cross_delay': weekPaywallCrossDelay,
      'week_paywall_weekly_product_id': weekPaywallWeeklyProductId,
      'week_paywall_yearly_product_id': weekPaywallYearlyProductId,
      'language_native_ad': languageNativeAd,
      'onboarding_native_ad': onboardingNativeAd,
      'full_screen_native_ad': fullScreenNativeAd,
      'full_screen_native_ad_id': fullScreenNativeAdId,
      'language_native_ad_id': languageNativeAdId,
      'onboarding_native_ad_id': onboardingNativeAdId,
      'app_open_ad': appOpenAd,
      'app_open_ad_id': appOpenAdId,
      'first_time_splash_inter_ad': firstTimeSplashInterAd,
      'second_time_splash_inter_ad': secondTimeSplashInterAd,
      'splash_inter_ad_id': splashInterAdId,
      'onb_paywall_enable': onbPaywallEnable,
      'onb_paywall_id': onbPaywallId,
      'week_paywall_enable': weekPaywallEnable,
      'week_paywall_id': weekPaywallId,
      'calculator_inter_ad': calculatorInterAd,
      'calculator_inter_ad_id': calculatorInterAdId,
      'local_notification': localNotification,
      'show_notification_frequency': notificationFrequency,
      'soft_paywall_access': softPaywallAccess,
      'show_ads_debugger': showAdsDebugger,
    };
  }
}

RemoteModel remoteModel = RemoteModel.defaults();
