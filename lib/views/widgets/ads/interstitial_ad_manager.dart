import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
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

  bool get isShowing => _showing;

  RemoteModel get _config => Get.isRegistered<RemoteConfigService>()
      ? RemoteConfigService.to.current
      : remoteModel;

  bool get _isOnboardingSeen =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().onboardingSeen.value;

  bool _isEnabled(InterstitialPlacement placement) {
    if (Get.isRegistered<AppController>() &&
        Get.find<AppController>().isPremium.value) {
      return false;
    }
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

  /// Shows the ad for [placement] if one is ready, then calls [onDone] once
  /// it's closed, or straight away if there's nothing to show.
  ///
  /// With [waitFor], an ad that is still loading gets that long to finish.
  Future<void> show(
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
    AppLovinMAX.showInterstitial(adUnitId, placement: placement.name);
  }

  /// The ad is gone; moves on now if that hasn't already happened behind it.
  void _finish() {
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
