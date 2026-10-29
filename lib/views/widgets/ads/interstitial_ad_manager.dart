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

/// Places in the app that show an interstitial ad, each switched on/off and
/// given its ad unit ID from Remote Config.
enum InterstitialPlacement { splash, paywallCross, calculator }

/// AppLovin MAX interstitials: loaded ahead of time for each placement and
/// shown right before the screen moves on. Never for premium users.
///
/// MAX keeps one ad per ad unit ID, so placements sharing an ID share an ad.
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  bool _listening = false;
  final Map<String, Completer<void>> _loading = {};
  VoidCallback? _onDone;

  bool get isShowing => _onDone != null;

  RemoteModel get _config => Get.isRegistered<RemoteConfigService>()
      ? RemoteConfigService.to.current
      : remoteModel;

  bool _isEnabled(InterstitialPlacement placement) {
    if (Get.isRegistered<AppController>() &&
        Get.find<AppController>().isPremium.value) {
      return false;
    }
    return switch (placement) {
      InterstitialPlacement.splash => _config.isSplashInterAdEnabled,
      InterstitialPlacement.paywallCross =>
        _config.isPaywallCrossInterAdEnabled,
      InterstitialPlacement.calculator => _config.isCalculatorInterAdEnabled,
    };
  }

  String _adUnitId(InterstitialPlacement placement) {
    final (id, fallback) = switch (placement) {
      InterstitialPlacement.splash => (
        _config.splashInterAdId,
        RemoteModel.defaultSplashInterAdId,
      ),
      InterstitialPlacement.paywallCross => (
        _config.paywallCrossInterAdId,
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
        onAdDisplayedCallback: (_) {},
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
    if (_onDone == null && _isEnabled(placement)) {
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

    _onDone = onDone;
    AppLovinMAX.showInterstitial(adUnitId, placement: placement.name);
  }

  void _finish() {
    final onDone = _onDone;
    _onDone = null;
    onDone?.call();
  }
}
