import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../main.dart';
import 'app_open_ad_manager.dart';
import 'applovin_sdk.dart';

enum InterstitialPlacement {
  splash,

  /// Cross on the main paywall (after onboarding and inside the app).
  onbPaywallCross,

  /// Cross on the 1 Week Meal Plan paywall.
  weekPaywallCross,
  calculator,
}

class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  bool _listening = false;
  final Map<String, Completer<void>> _loading = {};
  VoidCallback? _onDone;

  /// A show is being decided (ready check in flight); repeat calls are ignored.
  bool _starting = false;
  final ValueNotifier<bool> _showingNotifier = ValueNotifier(false);

  bool get _showing => _showingNotifier.value;
  set _showing(bool v) => _showingNotifier.value = v;

  Future<void> whenAdClosed() async {
    if (!_showing) return;
    final done = Completer<void>();
    void listener() {
      if (!_showing && !done.isCompleted) done.complete();
    }

    _showingNotifier.addListener(listener);
    try {
      await done.future;
    } finally {
      _showingNotifier.removeListener(listener);
    }
  }

  static const Duration _navigateBehindAdDelay = Duration(milliseconds: 350);

  /// If MAX reports neither "displayed" nor "failed" by then, move on anyway
  /// rather than leave the screen stuck under an ad that never came.
  static const Duration _showTimeout = Duration(seconds: 4);
  Timer? _showWatchdog;

  bool get isShowing => _showing;

  RemoteModel get _config => Get.isRegistered<RemoteConfigService>()
      ? RemoteConfigService.to.current
      : remoteModel;

  // Before AppController exists (the early splash load), read the saved flags.
  StorageService? get _storage =>
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : null;

  bool get _isOnboardingSeen => Get.isRegistered<AppController>()
      ? Get.find<AppController>().onboardingSeen.value
      : _storage?.getOnboardingSeen() ?? false;

  bool get _isPremium => Get.isRegistered<AppController>()
      ? Get.find<AppController>().isPremium.value
      : _storage?.getIsPremium() ?? false;

  bool _isEnabled(InterstitialPlacement placement) {
    if (_isPremium) return false;
    return switch (placement) {
      InterstitialPlacement.splash =>
        _isOnboardingSeen
            ? _config.isSecondTimeSplashInterAdEnabled
            : _config.isFirstTimeSplashInterAdEnabled,
      InterstitialPlacement.onbPaywallCross =>
        _config.isOnbPaywallInterAdEnabled,
      InterstitialPlacement.weekPaywallCross =>
        _config.isWeekPaywallInterAdEnabled,
      InterstitialPlacement.calculator => _config.isCalculatorInterAdEnabled,
    };
  }

  String _adUnitId(InterstitialPlacement placement) {
    final (id, fallback) = switch (placement) {
      InterstitialPlacement.splash => (
        _config.splashInterAdId,
        RemoteModel.defaultSplashInterAdId,
      ),
      InterstitialPlacement.onbPaywallCross => (
        _config.onbPaywallId,
        RemoteModel.defaultPaywallCrossInterAdId,
      ),
      InterstitialPlacement.weekPaywallCross => (
        _config.weekPaywallId,
        RemoteModel.defaultPaywallCrossInterAdId,
      ),
      InterstitialPlacement.calculator => (
        _config.calculatorInterAdId,
        RemoteModel.defaultCalculatorInterAdId,
      ),
    };
    return id.isNotEmpty ? id : fallback;
  }

  /// Call once at startup, after [AppLovinSdk.initialize].
  void initialize() {
    if (_listening) return;
    _listening = true;
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) {
          debugPrint('[InterstitialAd] loaded ${ad.adUnitId}');
          _loading.remove(ad.adUnitId)?.complete();
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          debugPrint(
            '[InterstitialAd] failed to load $adUnitId: '
            '${error.code} ${error.message}',
          );
          _loading.remove(adUnitId)?.complete();
        },
        onAdDisplayedCallback: (_) {
          _showWatchdog?.cancel();
          if (_onDone == null) return;
          Future.delayed(_navigateBehindAdDelay, _runDone);
        },
        onAdDisplayFailedCallback: (ad, error) {
          debugPrint(
            '[InterstitialAd] failed to show ${ad.adUnitId}: '
            '${error.code} ${error.message}',
          );
          _finish();
        },
        // Leaving for the advertiser shouldn't trigger an app open ad on return.
        onAdClickedCallback: (_) => AppOpenAdManager.instance.skipNextResume(),
        onAdHiddenCallback: (_) => _finish(),
        onAdRevenuePaidCallback: (ad) =>
            logMaxAdRevenue(ad, adType: 'InterstitialAd'),
      ),
    );
  }

  /// Starts loading the ad for [placement] if it isn't loaded or loading.
  Future<void> load(InterstitialPlacement placement) async {
    if (!_isEnabled(placement)) return;
    final adUnitId = _adUnitId(placement);
    if (_loading.containsKey(adUnitId)) return;

    final completer = Completer<void>();
    _loading[adUnitId] = completer;
    try {
      if (!await AppLovinSdk.ready) throw StateError('SDK not ready');
      if (await AppLovinMAX.isInterstitialReady(adUnitId) == true) {
        _loading.remove(adUnitId);
        completer.complete();
        return;
      }
      AppLovinMAX.loadInterstitial(adUnitId);
    } catch (e) {
      debugPrint('[InterstitialAd] load error: $e');
      _loading.remove(adUnitId);
      completer.complete();
    }
  }

  /// Completes when the load for [placement] reports back (loaded or failed),
  /// or after [timeout]. Completes at once if nothing is loading.
  Future<void> waitForLoad(
    InterstitialPlacement placement, {
    required Duration timeout,
  }) async {
    final pending = _loading[_adUnitId(placement)];
    if (pending == null) return;
    await pending.future.timeout(timeout, onTimeout: () {});
  }

  /// Whether [show] would display an ad for [placement] right now.
  Future<bool> isReady(InterstitialPlacement placement) async {
    if (_showing || !_isEnabled(placement)) return false;
    try {
      if (!await AppLovinSdk.ready) return false;
      return await AppLovinMAX.isInterstitialReady(_adUnitId(placement)) ??
          false;
    } catch (e) {
      debugPrint('[InterstitialAd] ready check error: $e');
      return false;
    }
  }

  Future<void> show(
    InterstitialPlacement placement, {
    required VoidCallback onDone,
    Duration? waitFor,
  }) async {
    // Double tap on close, or a second trigger: one show, one onDone.
    if (_starting || _showing) return;
    _starting = true;
    try {
      await _show(placement, onDone: onDone, waitFor: waitFor);
    } finally {
      _starting = false;
    }
  }

  Future<void> _show(
    InterstitialPlacement placement, {
    required VoidCallback onDone,
    Duration? waitFor,
  }) async {
    final adUnitId = _adUnitId(placement);
    final pending = _loading[adUnitId];
    if (waitFor != null && pending != null) {
      await pending.future.timeout(waitFor, onTimeout: () {});
    }

    var ready = false;
    if (!_showing && _isEnabled(placement)) {
      try {
        if (!await AppLovinSdk.ready) throw StateError('SDK not ready');
        ready = await AppLovinMAX.isInterstitialReady(adUnitId) ?? false;
      } catch (e) {
        debugPrint('[InterstitialAd] ready check error: $e');
      }
    }
    if (!ready) {
      onDone();
      return;
    }

    _showing = true;
    _onDone = onDone;
    _showWatchdog?.cancel();
    _showWatchdog = Timer(_showTimeout, () {
      debugPrint('[InterstitialAd] show gave no result, moving on');
      _finish();
    });
    AppLovinMAX.showInterstitial(adUnitId, placement: placement.name);
  }

  /// The ad is gone; moves on now if that hasn't already happened behind it.
  void _finish() {
    _showWatchdog?.cancel();
    _showing = false;
    // So the return that follows isn't mistaken for coming back from background.
    AppOpenAdManager.instance.noteFullScreenAdClosed();
    _runDone();
  }

  void _runDone() {
    final onDone = _onDone;
    _onDone = null;
    onDone?.call();
  }
}
