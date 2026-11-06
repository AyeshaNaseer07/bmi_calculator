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

class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  /// How long a [skipNextResume] request stays valid.
  static const Duration _skipWindow = Duration(minutes: 10);

  /// How long after a return an ad is still owed: it shows as soon as one is
  /// ready inside this window, then it is dropped rather than popping up late.
  static const Duration _lateShowWindow = Duration(seconds: 8);

  /// A load that never reports back is treated as failed after this long.
  static const Duration _loadTimeout = Duration(seconds: 20);

  /// If a requested show never reports displayed or failed, stop waiting.
  static const Duration _showTimeout = Duration(seconds: 6);

  /// Longest pause between retries of a failed load.
  static const Duration _maxRetryDelay = Duration(seconds: 30);

  /// Screens where an ad on return would get in the way.
  static const Set<String> _blockedRoutes = {AppRoutes.splash};

  bool _started = false;
  bool _isLoading = false;
  bool _isShowing = false;
  bool _wentToBackground = false;
  DateTime? _skipRequestedAt;
  DateTime? _showDueUntil;
  bool _showRetried = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;
  Timer? _showTimer;

  Timer? _loadWatchdog;
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
          _retryAttempt = 0;
          _retryTimer?.cancel();
          _finishLoad(true);
          _showIfDue();
        },
        onAdLoadFailedCallback: (_, error) {
          debugPrint(
            '[AppOpenAd] failed to load$_loadTime: '
            '${error.code} ${error.message}',
          );
          _finishLoad(false);
          _scheduleRetry();
        },
        onAdDisplayedCallback: (_) {
          debugPrint('[AppOpenAd] displayed');
          _showTimer?.cancel();
          _isShowing = true;
        },
        onAdDisplayFailedCallback: (_, error) {
          debugPrint(
            '[AppOpenAd] failed to show: ${error.code} ${error.message}',
          );
          _showTimer?.cancel();
          _isShowing = false;
          // The return is still owed an ad: try once more with a fresh one.
          if (!_showRetried) {
            _showRetried = true;
            _showDueUntil = DateTime.now().add(_lateShowWindow);
          }
          _load(fresh: true);
        },
        onAdClickedCallback: (_) => skipNextResume(),
        // The shown ad is used up; always fetch a new one, even if MAX still
        // briefly reports one as ready.
        onAdHiddenCallback: (_) {
          debugPrint('[AppOpenAd] hidden, loading the next one');
          _showTimer?.cancel();
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
      // Have the next ad ready (or on its way) before the user comes back.
      _load();
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

    // This return is owed an ad. Show it now if one is ready; otherwise it
    // shows the moment one finishes loading (also after a failed load is
    // retried), as long as that happens within [_lateShowWindow].
    _showRetried = false;
    _showDueUntil = DateTime.now().add(_lateShowWindow);
    final readyNow = await _isReady();
    debugPrint(
      '[AppOpenAd] back in app, ready: $readyNow, loading: $_isLoading',
    );
    if (readyNow) {
      _showIfDue();
    } else {
      _load();
    }
  }

  /// Shows the ad if this return is still owed one and one is ready.
  Future<void> _showIfDue() async {
    final due = _showDueUntil;
    if (due == null) return;
    if (DateTime.now().isAfter(due)) {
      debugPrint('[AppOpenAd] skipped: no ad ready in time');
      _showDueUntil = null;
      return;
    }
    if (_isShowing || !_canShowNow() || !await _isReady()) return;
    if (_showDueUntil == null) return;
    _showDueUntil = null;
    debugPrint('[AppOpenAd] showing');
    _isShowing = true;
    // Never stay "showing" forever if MAX reports neither displayed nor failed.
    _showTimer?.cancel();
    _showTimer = Timer(_showTimeout, () {
      if (!_isShowing) return;
      debugPrint('[AppOpenAd] show gave no result, resetting');
      _isShowing = false;
      _load(fresh: true);
    });
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

  /// After a failed load (no fill, network), try again with a growing pause
  /// so an ad is ready for the next return instead of every other one.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    if (!_isEnabled) return;
    final seconds = (2 << _retryAttempt)
        .clamp(2, _maxRetryDelay.inSeconds)
        .toInt();
    if (_retryAttempt < 10) _retryAttempt++;
    debugPrint('[AppOpenAd] retrying the load in ${seconds}s');
    _retryTimer = Timer(Duration(seconds: seconds), _load);
  }

  void _finishLoad(bool loaded) {
    _isLoading = false;
    _loadWatchdog?.cancel();
  }

  /// Starts loading the next ad. A plain call does nothing while a load is
  /// already running. With [fresh] (right after an ad was shown or failed) it
  /// always asks MAX for a new ad, even if a load seems to be running or MAX
  /// still reports the used ad as ready, so every dismissal gets a new ad.
  Future<void> _load({bool fresh = false}) async {
    if (!_isEnabled) return;
    if (_isLoading && !fresh) return;
    _isLoading = true;
    _loadStartedAt = DateTime.now();
    // A load that never reports back would block every later one.
    _loadWatchdog?.cancel();
    _loadWatchdog = Timer(_loadTimeout, () {
      if (!_isLoading) return;
      debugPrint('[AppOpenAd] load never reported back$_loadTime');
      _finishLoad(false);
      _scheduleRetry();
    });
    debugPrint('[AppOpenAd] loading${fresh ? ' (fresh)' : ''}');
    try {
      if (!await AppLovinSdk.ready) throw StateError('SDK not ready');
      if (!fresh && await _isReady()) {
        _finishLoad(true);
        _showIfDue();
        return;
      }
      AppLovinMAX.loadAppOpenAd(_adUnitId);
    } catch (e) {
      debugPrint('[AppOpenAd] load error: $e');
      _finishLoad(false);
      _scheduleRetry();
    }
  }
}
