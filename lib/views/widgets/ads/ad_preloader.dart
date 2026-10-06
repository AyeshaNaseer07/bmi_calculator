import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';

/// Names of the preloadable native ad placements.
class AdSlots {
  static const String language = 'language';
  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String fullScreen = 'fullscreen';
}

/// One preloaded (or still loading) native ad.
class PreloadedAd {
  final NativeAd ad;
  bool loaded = false;
  bool failed = false;

  /// Set by the widget that claims this ad while it is still loading.
  void Function(bool success)? onDone;

  PreloadedAd(this.ad);
}

/// Loads every native ad once while the splash screen is showing, so the
/// screens that follow can display them instantly instead of waiting on a
/// network request. A placement is consumed (claimed) by the first widget
/// that asks for it; if nothing is waiting for it, that widget just loads
/// its own ad the normal way.
class AdPreloader {
  AdPreloader._();
  static final AdPreloader instance = AdPreloader._();

  final Map<String, PreloadedAd> _slots = {};
  bool _started = false;

  static const _mediumFactory = 'mediumNativeAd';
  static const _fullFactory = 'fullScreenNativeAd';

  bool get _isPremium =>
      Get.isRegistered<AppController>() &&
      Get.find<AppController>().isPremium.value;

  bool get _mediumEnabled {
    if (_isPremium) return false;
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isNativeAdEnabled;
    }
    return remoteModel.isNativeAdEnabled;
  }

  bool get _fullEnabled {
    if (_isPremium) return false;
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isFullScreenNativeAdEnabled;
    }
    return remoteModel.isFullScreenNativeAdEnabled;
  }

  String get _mediumId {
    if (Get.isRegistered<RemoteConfigService>()) {
      final id = RemoteConfigService.to.nativeAdId;
      if (id.isNotEmpty) return id;
    }
    if (remoteModel.nativeAdId.isNotEmpty) return remoteModel.nativeAdId;
    return _testId;
  }

  String get _fullId {
    if (Get.isRegistered<RemoteConfigService>()) {
      final id = RemoteConfigService.to.fullScreenNativeAdId;
      if (id.isNotEmpty) return id;
    }
    if (remoteModel.fullScreenNativeAdId.isNotEmpty) {
      return remoteModel.fullScreenNativeAdId;
    }
    return _testId;
  }

  String get _testId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';

  /// Call once from the splash screen.
  void preloadAll() {
    if (_started) return;
    _started = true;
    try {
      if (_mediumEnabled) {
        _preload(AdSlots.language, _mediumFactory, _mediumId);
        _preload(AdSlots.onboarding, _mediumFactory, _mediumId);
        _preload(AdSlots.home, _mediumFactory, _mediumId);
      }
      if (_fullEnabled) {
        _preload(AdSlots.fullScreen, _fullFactory, _fullId);
      }
    } catch (e) {
      debugPrint('[AdPreloader] preloadAll error: $e');
    }
  }

  void _preload(String slot, String factoryId, String adUnitId) {
    AdLogHelper.logRequest(
      tag: 'AdPreloader/$slot',
      adUnitId: adUnitId,
      factoryId: factoryId,
    );
    late final PreloadedAd holder;
    final ad = NativeAd(
      adUnitId: adUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          AdLogHelper.logLoaded(tag: 'AdPreloader/$slot', ad: ad as NativeAd);
          holder.loaded = true;
          holder.onDone?.call(true);
        },
        onAdFailedToLoad: (ad, error) {
          AdLogHelper.logFailed(
            tag: 'AdPreloader/$slot',
            ad: ad as NativeAd,
            error: error,
          );
          ad.dispose();
          holder.failed = true;
          holder.onDone?.call(false);
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          logAdRevenue(
            adNetwork: 'AdMob',
            revenue: valueMicros,
            currency: currencyCode,
            adFormat: 'native',
            adUnitId: adUnitId,
            mediationNetwork: 'GoogleAdMob',
            adType: factoryId == _fullFactory
                ? 'FullScreenNativeAd'
                : 'MediumNativeAd',
          );
        },
      ),
    );
    holder = PreloadedAd(ad);
    _slots[slot] = holder;
    ad.load();
  }

  /// Hands the placement over to the caller (who now owns and must dispose
  /// the ad). Returns null if it was never preloaded or already claimed.
  PreloadedAd? claim(String slot) => _slots.remove(slot);
}
