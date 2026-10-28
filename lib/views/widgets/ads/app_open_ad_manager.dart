import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/app_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';

/// Shows an App Open ad when the user comes back to the app from the
/// background. Never on a cold start, never for premium users.
///
/// The ad is loaded ahead of time (at startup and after each show) so it can
/// appear the moment the app returns; if none is ready, one is loaded for
/// next time instead of showing late.
class AppOpenAdManager {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  /// Google's guidance: app open ads older than 4 hours may not pay out.
  static const Duration _maxAdAge = Duration(hours: 4);

  /// How long a [skipNextResume] request stays valid.
  static const Duration _skipWindow = Duration(minutes: 10);

  /// Screens where an ad on return would get in the way.
  static const Set<String> _blockedRoutes = {
    AppRoutes.splash,
    AppRoutes.paywall,
  };

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  bool _isLoading = false;
  bool _isShowing = false;
  DateTime? _skipRequestedAt;
  StreamSubscription<AppState>? _subscription;

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

  bool get _isAdFresh =>
      _ad != null &&
      _loadedAt != null &&
      DateTime.now().difference(_loadedAt!) < _maxAdAge;

  /// Call once at startup, after Remote Config and AppController are ready.
  void start() {
    if (_subscription != null) return;
    AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.foreground) _onForeground();
    });
    _load();
  }

  /// Call before deliberately sending the user out of the app (tapping an
  /// ad, opening mail or a web page) so coming back doesn't show an ad.
  void skipNextResume() => _skipRequestedAt = DateTime.now();

  void _onForeground() {
    final skipAt = _skipRequestedAt;
    _skipRequestedAt = null;
    if (skipAt != null && DateTime.now().difference(skipAt) < _skipWindow) {
      return;
    }
    if (!_isEnabled || _isShowing) return;
    if (_blockedRoutes.contains(Get.currentRoute)) return;

    if (!_isAdFresh) {
      _ad?.dispose();
      _ad = null;
      _load();
      return;
    }
    _show();
  }

  void _load() {
    if (_isLoading || _isAdFresh || !_isEnabled) return;
    _isLoading = true;
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AppOpenAd] loaded');
          _isLoading = false;
          _ad = ad;
          _loadedAt = DateTime.now();
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            logAdRevenue(
              adNetwork: 'AdMob',
              revenue: valueMicros,
              currency: currencyCode,
              adFormat: 'app_open',
              adUnitId: ad.adUnitId,
              mediationNetwork: 'GoogleAdMob',
              adType: 'AppOpenAd',
            );
          };
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AppOpenAd] failed to load: $error');
          _isLoading = false;
        },
      ),
    );
  }

  void _show() {
    final ad = _ad!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowing = true,
      onAdClicked: (_) => skipNextResume(),
      onAdDismissedFullScreenContent: (ad) {
        _isShowing = false;
        ad.dispose();
        _ad = null;
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AppOpenAd] failed to show: $error');
        _isShowing = false;
        ad.dispose();
        _ad = null;
        _load();
      },
    );
    ad.show();
  }
}
