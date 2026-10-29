import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'applovin_sdk.dart';
import 'interstitial_ad_manager.dart';

/// Shows an AppLovin MAX App Open ad when the user comes back to the app from
/// the background. Never on a cold start, never for premium users.
///
/// The ad is loaded ahead of time (at startup and after each show) so it can
/// appear the moment the app returns; if none is ready, one is loaded for
/// next time instead of showing late.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  /// How long a [skipNextResume] request stays valid.
  static const Duration _skipWindow = Duration(minutes: 10);

  /// Screens where an ad on return would get in the way.
  static const Set<String> _blockedRoutes = {
    AppRoutes.splash,
    AppRoutes.paywall,
  };

  bool _started = false;
  bool _isLoading = false;
  bool _isShowing = false;
  bool _wentToBackground = false;
  DateTime? _skipRequestedAt;

  bool get _isEnabled {
    if (Get.isRegistered<AppController>() &&
        Get.find<AppController>().isPremium.value) {
      return false;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isAppOpenAdEnabled;
    }
    return remoteModel.isAppOpenAdEnabled;
  }

  String get _adUnitId {
    if (Get.isRegistered<RemoteConfigService>()) {
      final id = RemoteConfigService.to.appOpenAdId;
      if (id.isNotEmpty) return id;
    }
    return RemoteModel.defaultAppOpenAdId;
  }

  /// Call once at startup, after Remote Config, AppController and
  /// [AppLovinSdk.initialize].
  void start() {
    if (_started) return;
    _started = true;
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (_) {
          debugPrint('[AppOpenAd] loaded');
          _isLoading = false;
        },
        onAdLoadFailedCallback: (_, error) {
          debugPrint(
            '[AppOpenAd] failed to load: ${error.code} ${error.message}',
          );
          _isLoading = false;
        },
        onAdDisplayedCallback: (_) => _isShowing = true,
        onAdDisplayFailedCallback: (_, error) {
          debugPrint(
            '[AppOpenAd] failed to show: ${error.code} ${error.message}',
          );
          _isShowing = false;
          _load();
        },
        onAdClickedCallback: (_) => skipNextResume(),
        onAdHiddenCallback: (_) {
          _isShowing = false;
          _load();
        },
        onAdRevenuePaidCallback: (ad) =>
            logMaxAdRevenue(ad, adType: 'AppOpenAd'),
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  /// Call before deliberately sending the user out of the app (tapping an
  /// ad, opening mail or a web page) so coming back doesn't show an ad.
  void skipNextResume() => _skipRequestedAt = DateTime.now();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only a real trip to the background counts. System dialogs just make the
    // app "inactive", and on Android our own full-screen ads pause it, so a
    // pause while one of those is up is ignored.
    if (state == AppLifecycleState.paused) {
      if (_isShowing || InterstitialAdManager.instance.isShowing) return;
      _wentToBackground = true;
    } else if (state == AppLifecycleState.resumed && _wentToBackground) {
      _wentToBackground = false;
      _onForeground();
    }
  }

  Future<void> _onForeground() async {
    final skipAt = _skipRequestedAt;
    _skipRequestedAt = null;
    if (skipAt != null && DateTime.now().difference(skipAt) < _skipWindow) {
      return;
    }
    if (!_isEnabled || _isShowing) return;
    if (_blockedRoutes.contains(Get.currentRoute)) return;

    final adUnitId = _adUnitId;
    try {
      if (await AppLovinMAX.isAppOpenAdReady(adUnitId) == true) {
        _isShowing = true;
        AppLovinMAX.showAppOpenAd(adUnitId);
        return;
      }
    } catch (e) {
      debugPrint('[AppOpenAd] ready check error: $e');
    }
    _load();
  }

  Future<void> _load() async {
    if (_isLoading || !_isEnabled) return;
    _isLoading = true;
    try {
      if (!await AppLovinSdk.ready) throw StateError('SDK not ready');
      final adUnitId = _adUnitId;
      if (await AppLovinMAX.isAppOpenAdReady(adUnitId) == true) {
        _isLoading = false;
        return;
      }
      AppLovinMAX.loadAppOpenAd(adUnitId);
    } catch (e) {
      debugPrint('[AppOpenAd] load error: $e');
      _isLoading = false;
    }
  }
}
