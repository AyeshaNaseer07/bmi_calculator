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
/// appear the moment the app returns. If it is still loading at that moment
/// it gets a short grace period; after that it is kept for next time rather
/// than popping up late.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  /// How long a [skipNextResume] request stays valid.
  static const Duration _skipWindow = Duration(minutes: 10);

  /// How long a return waits for an ad that is still loading.
  static const Duration _lateShowWindow = Duration(seconds: 3);

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

  /// Completed with the result of the load in progress, so a return can
  /// wait briefly for it.
  Completer<bool>? _pendingLoad;
  DateTime? _loadStartedAt;

  String get _loadTime => _loadStartedAt == null
      ? ''
      : ' after ${DateTime.now().difference(_loadStartedAt!).inMilliseconds}ms';

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
          debugPrint('[AppOpenAd] loaded$_loadTime');
          _finishLoad(true);
        },
        onAdLoadFailedCallback: (_, error) {
          debugPrint(
            '[AppOpenAd] failed to load$_loadTime: '
            '${error.code} ${error.message}',
          );
          _finishLoad(false);
        },
        onAdDisplayedCallback: (_) {
          debugPrint('[AppOpenAd] displayed');
          _isShowing = true;
        },
        onAdDisplayFailedCallback: (_, error) {
          debugPrint(
            '[AppOpenAd] failed to show: ${error.code} ${error.message}',
          );
          _isShowing = false;
          _load(fresh: true);
        },
        onAdClickedCallback: (_) => skipNextResume(),
        // The shown ad is used up; always fetch a new one, even if MAX still
        // briefly reports one as ready.
        onAdHiddenCallback: (_) {
          debugPrint('[AppOpenAd] hidden, loading the next one');
          _isShowing = false;
          _load(fresh: true);
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      debugPrint(
        '[AppOpenAd] lifecycle ${state.name} (adShowing: $_isShowing, '
        'interShowing: ${InterstitialAdManager.instance.isShowing}, '
        'wasInBackground: $_wentToBackground, loading: $_isLoading)',
      );
    }
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
      debugPrint('[AppOpenAd] skipped: user left the app on purpose');
      return;
    }
    if (!_canShowNow()) return;

    final readyNow = await _isReady();
    debugPrint(
      '[AppOpenAd] back in app, ready: $readyNow, loading: $_isLoading',
    );
    if (!readyNow) {
      // Still loading (e.g. the user came straight back after the last ad):
      // give it a moment rather than missing this return altogether.
      _load();
      final ok = await (_pendingLoad?.future ?? Future.value(false)).timeout(
        _lateShowWindow,
        onTimeout: () => false,
      );
      if (!ok || !_canShowNow() || !await _isReady()) {
        debugPrint('[AppOpenAd] skipped: no ad ready in time');
        return;
      }
    }
    debugPrint('[AppOpenAd] showing');
    _isShowing = true;
    AppLovinMAX.showAppOpenAd(_adUnitId);
  }

  /// Whether an ad may appear right now; logs the reason when not.
  bool _canShowNow() {
    String? reason;
    if (!_isEnabled) {
      reason = 'disabled or premium';
    } else if (_isShowing || InterstitialAdManager.instance.isShowing) {
      reason = 'another ad is showing';
    } else if (_blockedRoutes.contains(Get.currentRoute)) {
      reason = 'on ${Get.currentRoute}';
    } else if (WidgetsBinding.instance.lifecycleState !=
        AppLifecycleState.resumed) {
      reason = 'app not in the foreground';
    }
    if (reason != null) debugPrint('[AppOpenAd] skipped: $reason');
    return reason == null;
  }

  Future<bool> _isReady() async {
    try {
      return await AppLovinMAX.isAppOpenAdReady(_adUnitId) == true;
    } catch (e) {
      debugPrint('[AppOpenAd] ready check error: $e');
      return false;
    }
  }

  void _finishLoad(bool loaded) {
    _isLoading = false;
    final pending = _pendingLoad;
    _pendingLoad = null;
    if (pending != null && !pending.isCompleted) pending.complete(loaded);
  }

  /// Starts loading unless a load is already running. With [fresh] it loads
  /// even when MAX reports an ad as ready (right after one was shown).
  Future<void> _load({bool fresh = false}) async {
    if (_isLoading || !_isEnabled) return;
    _isLoading = true;
    _pendingLoad = Completer<bool>();
    _loadStartedAt = DateTime.now();
    debugPrint('[AppOpenAd] loading${fresh ? ' (fresh)' : ''}');
    try {
      if (!await AppLovinSdk.ready) throw StateError('SDK not ready');
      if (!fresh && await _isReady()) {
        _finishLoad(true);
        return;
      }
      AppLovinMAX.loadAppOpenAd(_adUnitId);
    } catch (e) {
      debugPrint('[AppOpenAd] load error: $e');
      _finishLoad(false);
    }
  }
}
