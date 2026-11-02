import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/remote_model.dart';
import 'storage_service.dart';
import 'subscription_service.dart';

class RemoteConfigService extends GetxService {
  final StorageService? _storage;

  static const String keyRemoteConfig = 'bmi_calculator_remote_config';
  final Rx<RemoteModel> model = RemoteModel.defaults().obs;

  RemoteConfigService([this._storage]);

  static RemoteConfigService get to => Get.find<RemoteConfigService>();

  RemoteModel get current => model.value;
  String get firstTimeOnboarding => model.value.firstTimeOnboarding;
  bool get isFirstTimeOnboardingEnabled {
    try {
      return model.value.isFirstTimeOnboarding;
    } catch (_) {
      return true;
    }
  }

  String get secondTimeOnboarding => model.value.secondTimeOnboarding;
  bool get isSecondTimeOnboardingEnabled {
    try {
      return model.value.isSecondTimeOnboarding;
    } catch (_) {
      return false;
    }
  }

  String get paywallBtnText => model.value.paywallBtnText;
  String get buttonText => model.value.paywallBtnText;
  int get crossDelaySeconds => model.value.crossDelay;
  String get weeklyProductId => model.value.weeklyProductId;
  String get yearlyProductId => model.value.yearlyProductId;

  bool get isSoftPaywallAccessEnabled {
    try {
      return model.value.isSoftPaywallAccessEnabled;
    } catch (_) {
      return true;
    }
  }

  bool get isAdsDebuggerEnabled {
    try {
      return model.value.isAdsDebuggerEnabled;
    } catch (_) {
      return false;
    }
  }

  bool get isFullScreenNativeAdEnabled {
    try {
      return model.value.isFullScreenNativeAdEnabled;
    } catch (_) {
      return true;
    }
  }

  bool get isLanguageNativeAdEnabled {
    try {
      return model.value.isLanguageNativeAdEnabled;
    } catch (_) {
      return true;
    }
  }

  bool get isOnboardingNativeAdEnabled {
    try {
      return model.value.isOnboardingNativeAdEnabled;
    } catch (_) {
      return true;
    }
  }

  String get fullScreenNativeAdId => model.value.fullScreenNativeAdId;
  String get languageNativeAdId => model.value.languageNativeAdId;
  String get onboardingNativeAdId => model.value.onboardingNativeAdId;

  bool get isAppOpenAdEnabled {
    try {
      return model.value.isAppOpenAdEnabled;
    } catch (_) {
      return true;
    }
  }

  String get appOpenAdId => model.value.appOpenAdId;

  bool get isSplashInterAdEnabled {
    try {
      return model.value.isSplashInterAdEnabled;
    } catch (_) {
      return true;
    }
  }

  String get splashInterAdId => model.value.splashInterAdId;

  bool get isOnbPaywallInterAdEnabled {
    try {
      return model.value.isOnbPaywallInterAdEnabled;
    } catch (_) {
      return true;
    }
  }

  String get onbPaywallId => model.value.onbPaywallId;

  bool get isWeekPaywallInterAdEnabled {
    try {
      return model.value.isWeekPaywallInterAdEnabled;
    } catch (_) {
      return true;
    }
  }

  String get weekPaywallId => model.value.weekPaywallId;

  bool get isCalculatorInterAdEnabled {
    try {
      return model.value.isCalculatorInterAdEnabled;
    } catch (_) {
      return true;
    }
  }

  String get calculatorInterAdId => model.value.calculatorInterAdId;
  String get localNotification => model.value.localNotification;
  bool get isLocalNotificationEnabled {
    try {
      return model.value.isLocalNotificationEnabled;
    } catch (_) {
      return true;
    }
  }

  String get notificationFrequency => model.value.notificationFrequency;

  AppLifecycleListener? _lifecycle;

  Future<RemoteConfigService> init() async {
    loadCachedConfig();
    await fetchRemoteConfig();
    RemoteConfig.listenForUpdates();
    // The startup fetch timed out or failed: try again in the background
    // instead of running the whole session on cached or default values.
    if (!RemoteConfig.lastFetchSucceeded) RemoteConfig.refresh();
    _lifecycle = AppLifecycleListener(onResume: RemoteConfig.refresh);
    return this;
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    super.onClose();
  }

  void loadCachedConfig() {
    if (_storage == null) return;
    try {
      final cachedJson = _storage.getRemoteButtonText();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final parsed = RemoteModel.fromRemoteConfig(decoded);
          model.value = parsed;
          remoteModel = parsed;
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[RemoteConfig] loading cached values failed: $e');
    }
  }

  /// Applies the values Firebase has activated (fetched this launch, or kept
  /// from an earlier one). Keeps the cached/default values if there are none.
  Future<void> fetchRemoteConfig() async {
    final map = RemoteConfig.getAllValuesAsMap();
    if (map.isNotEmpty) {
      updateWithMap(map);
      logValues('activated');
      return;
    }
    debugPrint('[RemoteConfig] no activated values yet; using cached/defaults');
    if (model.value.weeklyProductId.isEmpty ||
        model.value.yearlyProductId.isEmpty) {
      final defaults = RemoteModel.defaults();
      model.value = defaults;
      remoteModel = defaults;
    }
    logValues('cached/defaults');
  }

  void logValues(String source) {
    final m = model.value;
    debugPrint(
      '[RemoteConfig] values ($source): '
      'first_time_onboarding=${m.firstTimeOnboarding}, '
      'second_time_onboarding=${m.secondTimeOnboarding}, '
      'paywall_btn_text="${m.paywallBtnText}", cross_delay=${m.crossDelay}, '
      'soft_paywall_access=${m.softPaywallAccess}, '
      'show_ads_debugger=${m.showAdsDebugger}, '
      'splash_inter_ad=${m.splashInterAd}, '
      'onb_paywall_enable=${m.onbPaywallEnable}, '
      'week_paywall_enable=${m.weekPaywallEnable}, '
      'calculator_inter_ad=${m.calculatorInterAd}, '
      'language_native_ad=${m.languageNativeAd}, '
      'onboarding_native_ad=${m.onboardingNativeAd}, '
      'full_screen_native_ad=${m.fullScreenNativeAd}, '
      'app_open_ad=${m.appOpenAd}, '
      'local_notification=${m.localNotification}, '
      'show_notification_frequency=${m.notificationFrequency}',
    );
  }

  void updateWithMap(Map<String, dynamic> remoteConfigMap) {
    final parsed = RemoteModel.fromRemoteConfig(remoteConfigMap);
    model.value = parsed;
    remoteModel = parsed;
    _storage?.setRemoteButtonText(jsonEncode(parsed.toJson()));
  }

  String getProductId(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.weekly:
      case SubscriptionPlan.monthly:
        return model.value.weeklyProductId;
      case SubscriptionPlan.yearly:
        return model.value.yearlyProductId;
    }
  }
}

class RemoteConfig {
  static final FirebaseRemoteConfig remoteConfig =
      FirebaseRemoteConfig.instance;

  static const String _key = RemoteConfigService.keyRemoteConfig;

  static StreamSubscription<RemoteConfigUpdate>? _updates;
  static Future<bool>? _refreshing;
  static DateTime? _lastRefreshAt;

  /// Refetches on resume no more often than this.
  static const Duration _refreshInterval = Duration(minutes: 1);

  static bool get lastFetchSucceeded =>
      remoteConfig.lastFetchStatus == RemoteConfigFetchStatus.success;

  /// Fetches and activates the published values. Called during the splash,
  /// before [RemoteConfigService] exists, which then reads what's activated.
  static Future<String> initialize() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: Duration.zero,
        ),
      );
      final activated = await remoteConfig.fetchAndActivate();
      _lastRefreshAt = DateTime.now();
      debugPrint(
        '[RemoteConfig] fetch ${remoteConfig.lastFetchStatus.name}, '
        '${activated ? 'activated new values' : 'values unchanged'} '
        '(last fetch ${remoteConfig.lastFetchTime})',
      );
      return 'success';
    } catch (e) {
      debugPrint(
        '[RemoteConfig] fetch failed (${remoteConfig.lastFetchStatus.name}): '
        '$e',
      );
      return 'failed: $e';
    }
  }

  /// Fetches again and applies the result: when the startup fetch failed,
  /// and each time the app comes back to the foreground.
  static Future<bool> refresh() {
    final last = _lastRefreshAt;
    if (_refreshing != null ||
        (lastFetchSucceeded &&
            last != null &&
            DateTime.now().difference(last) < _refreshInterval)) {
      return _refreshing ?? Future.value(false);
    }
    _lastRefreshAt = DateTime.now();
    return _refreshing = () async {
      try {
        final activated = await remoteConfig.fetchAndActivate();
        debugPrint(
          '[RemoteConfig] refresh ${remoteConfig.lastFetchStatus.name}'
          '${activated ? ', activated new values' : ''}',
        );
        if (activated) _apply('refresh');
        return activated;
      } catch (e) {
        debugPrint('[RemoteConfig] refresh failed: $e');
        return false;
      } finally {
        _refreshing = null;
      }
    }();
  }

  /// Applies values published while the app is open, without a relaunch.
  static void listenForUpdates() {
    _updates ??= remoteConfig.onConfigUpdated.listen(
      (update) async {
        try {
          await remoteConfig.activate();
          _apply('realtime: ${update.updatedKeys.join(', ')}');
        } catch (e) {
          debugPrint('[RemoteConfig] realtime update failed: $e');
        }
      },
      onError: (Object e) =>
          debugPrint('[RemoteConfig] realtime listener error: $e'),
    );
  }

  static void _apply(String source) {
    if (!Get.isRegistered<RemoteConfigService>()) return;
    final map = getAllValuesAsMap();
    if (map.isEmpty) return;
    RemoteConfigService.to
      ..updateWithMap(map)
      ..logValues(source);
  }

  static Map<String, dynamic> getAllValuesAsMap() {
    final Map<String, dynamic> result = {};

    final val = remoteConfig.getString(_key).trim();
    if (val.isNotEmpty && val != "{}" && val != "off") {
      try {
        final decoded = json.decode(val);
        if (decoded is Map<String, dynamic>) {
          result.addAll(decoded);
        }
      } catch (e) {
        debugPrint('[RemoteConfig] $_key is not valid JSON: $e');
      }
    }

    final allParams = remoteConfig.getAll();
    for (final entry in allParams.entries) {
      if (entry.key == _key) continue;
      final rawStr = entry.value.asString().trim();
      if (rawStr.isNotEmpty) {
        if (rawStr.startsWith('{') && rawStr.endsWith('}')) {
          try {
            final parsed = json.decode(rawStr);
            if (parsed is Map && parsed.containsKey('value')) {
              result[entry.key] = parsed['value'];
              continue;
            }
          } catch (_) {}
        }
        result[entry.key] = rawStr;
      }
    }

    return result;
  }

  static String getString(String key) => remoteConfig.getString(key);
  static int getInt(String key) => remoteConfig.getInt(key);
  static bool getBool(String key) => remoteConfig.getBool(key);
  static double getDouble(String key) => remoteConfig.getDouble(key);

  static String get showNotificationFrequency {
    try {
      if (Get.isRegistered<RemoteConfigService>()) {
        final val = RemoteConfigService.to.notificationFrequency.trim();
        if (val.isNotEmpty) return val;
      }
      final val = remoteConfig.getString('show_notification_frequency').trim();
      if (val.isNotEmpty) return val;
      final alt = remoteConfig.getString('notification_frequency').trim();
      if (alt.isNotEmpty) return alt;
    } catch (_) {}
    return 'd';
  }
}
