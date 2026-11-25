import 'dart:async';
import 'dart:io' show Platform;

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'
    show AppState, AppStateEventNotifier;

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
  static const Duration _skipWindow = Duration(seconds: 6);
  static const Duration _lateShowWindow = Duration(seconds: 8);
  static const Duration _recentlyClosedWindow = Duration(milliseconds: 1500);
  static const Duration _returnSettle = Duration(milliseconds: 400);
  static const Duration _loadTimeout = Duration(seconds: 20);
  static const Duration _showTimeout = Duration(seconds: 6);
  static const Duration _maxRetryDelay = Duration(seconds: 30);
  static const Set<String> _blockedRoutes = {AppRoutes.splash};

  bool _started = false;
  bool _isLoading = false;
  bool _isShowing = false;
  DateTime? _skipRequestedAt;

  // One "episode" = one real trip to the background and back.
  bool _episodeActive = false;
  bool _episodeEligible = false;
  DateTime? _backgroundAt;
  DateTime? _lastAdClosedAt;

  // iOS: real background/foreground from the SDK's app-state notifier.
  bool _realStateAvailable = false;
  StreamSubscription<AppState>? _realStateSub;
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
          _lastAdClosedAt = DateTime.now();
          // The return is still owed an ad: try once more with a fresh one.
          if (!_showRetried) {
            _showRetried = true;
            _showDueUntil = DateTime.now().add(_lateShowWindow);
          }
          _load(fresh: true);
        },
        onAdClickedCallback: (_) => skipNextResume(),
        onAdHiddenCallback: (_) {
          debugPrint('[AppOpenAd] hidden, loading the next one');
          _showTimer?.cancel();
          _isShowing = false;
          _lastAdClosedAt = DateTime.now();
          _load(fresh: true);
        },
        onAdRevenuePaidCallback: (ad) =>
            logMaxAdRevenue(ad, adType: 'AppOpenAd'),
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    _listenToRealAppState();
    _load();
  }

  void noteFullScreenAdClosed() => _lastAdClosedAt = DateTime.now();
  void skipNextResume() => _skipRequestedAt = DateTime.now();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      debugPrint(
        '[AppOpenAd] flutter lifecycle ${state.name} (adShowing: $_isShowing, '
        'interShowing: ${InterstitialAdManager.instance.isShowing}, '
        'episode: $_episodeActive, realState: $_realStateAvailable)',
      );
    }
    if (Platform.isIOS && _realStateAvailable) return;
    if (state == AppLifecycleState.paused) {
      if (_isShowing || InterstitialAdManager.instance.isShowing) return;
      _onBackground('flutter_lifecycle');
    } else if (state == AppLifecycleState.resumed) {
      _onForeground('flutter_lifecycle');
    }
  }

  void _listenToRealAppState() {
    if (!Platform.isIOS || _realStateSub != null) return;
    try {
      _realStateSub = AppStateEventNotifier.appStateStream.listen(
        (event) {
          debugPrint('[AppOpenAd] real app state: $event');
          if (event == AppState.foreground) {
            _onForeground('app_state');
          } else if (event == AppState.background) {
            _onBackground('app_state');
          }
        },
        onError: (Object e) {
          debugPrint('[AppOpenAd] app state stream error: $e');
          _realStateAvailable = false;
        },
      );
      _realStateAvailable = true;
      unawaited(
        AppStateEventNotifier.startListening()
            .timeout(const Duration(milliseconds: 500), onTimeout: () {})
            .catchError((Object e) {
              debugPrint('[AppOpenAd] app state listening failed: $e');
              _realStateAvailable = false;
            }),
      );
    } catch (e) {
      debugPrint('[AppOpenAd] app state notifier unavailable: $e');
      _realStateAvailable = false;
    }
  }

  void _onBackground(String source) {
    final eligibleNow =
        !_isShowing && !InterstitialAdManager.instance.isShowing;
    if (!_episodeActive) {
      _episodeActive = true;
      _backgroundAt = DateTime.now();
      _episodeEligible = eligibleNow;
      final req = _skipRequestedAt;
      if (req != null && _backgroundAt!.difference(req) > _skipWindow) {
        _skipRequestedAt = null;
      }
      debugPrint(
        '[AppOpenAd] app backgrounded (source: $source, eligible: $eligibleNow)',
      );
      if (!_isShowing) _load();
    } else {
      _episodeEligible = _episodeEligible && eligibleNow;
    }
  }

  Future<void> _onForeground(String source) async {
    if (!_episodeActive) {
      debugPrint('[AppOpenAd] foreground without background ignored ($source)');
      return;
    }
    final start = _backgroundAt;
    final closedAt = _lastAdClosedAt;
    final adClosedDuringEpisode =
        start != null && closedAt != null && closedAt.isAfter(start);
    final eligible = _episodeEligible && !adClosedDuringEpisode;
    _episodeActive = false;
    _episodeEligible = false;
    _backgroundAt = null;

    final skipAt = _skipRequestedAt;
    _skipRequestedAt = null;
    if (skipAt != null) {
      debugPrint('[AppOpenAd] skipped: user left the app on purpose');
      return;
    }
    if (!eligible) {
      debugPrint(
        '[AppOpenAd] skipped: not a plain return '
        '(adClosedDuringEpisode: $adClosedDuringEpisode, source: $source)',
      );
      return;
    }
    debugPrint('[AppOpenAd] real return from background ($source)');
    await Future<void>.delayed(_returnSettle);
    if (_episodeActive) {
      debugPrint('[AppOpenAd] skipped: went back to the background');
      return;
    }
    await _showForReturn();
  }

  Future<void> _showForReturn() async {
    if (!_canShowNow()) return;
    final closedAt = _lastAdClosedAt;
    if (closedAt != null &&
        DateTime.now().difference(closedAt) < _recentlyClosedWindow) {
      debugPrint('[AppOpenAd] skipped: an ad was just dismissed');
      return;
    }
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
    } else if (_episodeActive) {
      reason = 'app is in the background';
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
