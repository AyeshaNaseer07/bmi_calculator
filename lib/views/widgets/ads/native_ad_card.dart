import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';
import 'ad_shimmer.dart';
import 'app_open_ad_manager.dart';
import 'applovin_sdk.dart';
import 'max_native_ad.dart';

const double _kDefaultNativeAdHeight = 350;

enum NativeAdPlacement { language, onboarding, fullScreen }

class NativeAds {
  NativeAds._();

  static final Map<NativeAdPlacement, MaxNativeAd> _ads = {
    for (final placement in NativeAdPlacement.values)
      placement: MaxNativeAd(switch (placement) {
        NativeAdPlacement.language => 'language_native',
        NativeAdPlacement.onboarding => 'onboarding_native',
        NativeAdPlacement.fullScreen => 'full_screen_native',
      }),
  };

  static bool _callbacksSet = false;

  static MaxNativeAd of(NativeAdPlacement placement) => _ads[placement]!;

  static RemoteModel get _config => Get.isRegistered<RemoteConfigService>()
      ? RemoteConfigService.to.current
      : remoteModel;

  static bool isEnabled(NativeAdPlacement placement) {
    if (!Platform.isIOS) return false;
    try {
      if (Get.isRegistered<AppController>()) {
        if (Get.find<AppController>().isPremium.value) return false;
      }
      return switch (placement) {
        NativeAdPlacement.language => _config.isLanguageNativeAdEnabled,
        NativeAdPlacement.onboarding => _config.isOnboardingNativeAdEnabled,
        NativeAdPlacement.fullScreen => _config.isFullScreenNativeAdEnabled,
      };
    } catch (_) {
      return true;
    }
  }

  static String adUnitIdFor(NativeAdPlacement placement) {
    final (id, fallback) = switch (placement) {
      NativeAdPlacement.language => (
        _config.languageNativeAdId,
        RemoteModel.defaultLanguageNativeAdId,
      ),
      NativeAdPlacement.onboarding => (
        _config.onboardingNativeAdId,
        RemoteModel.defaultOnboardingNativeAdId,
      ),
      NativeAdPlacement.fullScreen => (
        _config.fullScreenNativeAdId,
        RemoteModel.defaultFullScreenNativeAdId,
      ),
    };
    return id.isNotEmpty ? id : fallback;
  }

  static Future<bool> preload(
    NativeAdPlacement placement, {
    String? adUnitId,
  }) async {
    if (!isEnabled(placement)) return false;
    if (!await AppLovinSdk.ready) return false;
    _setCallbacks();

    final ad = of(placement);
    final id = (adUnitId != null && adUnitId.isNotEmpty)
        ? adUnitId
        : adUnitIdFor(placement);
    if (!ad.isLoadingOrLoaded) {
      AdLogHelper.logRequest(tag: 'NativeAd(${placement.name})', adUnitId: id);
    }
    ad.preload(id);
    return true;
  }

  static Future<void> waitForLoad(
    NativeAdPlacement placement, {
    required Duration timeout,
  }) async {
    if (!isEnabled(placement)) return;
    final ad = of(placement);
    if (ad.state.value == MaxNativeAdState.loaded) return;

    final done = Completer<void>();
    void onState() {
      final s = ad.state.value;
      if ((s == MaxNativeAdState.loaded || s == MaxNativeAdState.failed) &&
          !done.isCompleted) {
        done.complete();
      }
    }

    ad.state.addListener(onState);
    try {
      if (!await preload(placement)) return;
      onState();
      await done.future.timeout(timeout, onTimeout: () {});
    } finally {
      ad.state.removeListener(onState);
    }
  }

  static void _setCallbacks() {
    if (_callbacksSet) return;
    _callbacksSet = true;
    MaxNativeAd.onAdClicked = (_) => AppOpenAdManager.instance.skipNextResume();
    MaxNativeAd.onRevenuePaid = (ad, networkName, revenue) => logAdRevenue(
      networkName: networkName,
      revenue: revenue,
      adUnitId: ad.adUnitId ?? '',
      adType: ad == of(NativeAdPlacement.fullScreen)
          ? 'FullScreenNativeAd'
          : 'MediumNativeAd',
    );
  }
}

class NativeAdCard extends StatefulWidget {
  final NativeAdPlacement placement;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Color? backgroundColor;
  final ValueChanged<bool>? onAdAvailabilityChanged;

  const NativeAdCard({
    super.key,
    required this.placement,
    this.margin,
    this.height,
    this.backgroundColor,
    this.onAdAvailabilityChanged,
  });

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  late final MaxNativeAd _ad = NativeAds.of(widget.placement);
  bool _isFailed = false;

  /// Ads were off when the card was built: it never takes any space.
  bool _off = false;
  int _retries = 0;
  Timer? _retryTimer;

  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 3);

  /// On a failed load the placeholder folds away over this long, instead of
  /// vanishing in one frame and making the screen jump.
  static const Duration _collapseDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    if (!NativeAds.isEnabled(widget.placement)) {
      _isFailed = true;
      _off = true;
      _notifyAvailability(false);
      return;
    }
    _ad.state.addListener(_onAdStateChanged);
    NativeAds.preload(widget.placement).then((started) {
      if (!mounted) return;
      if (!started) {
        _retryOrFail();
      } else if (_ad.state.value == MaxNativeAdState.loaded) {
        _notifyAvailability(true);
      }
    });
  }

  void _onAdStateChanged() {
    if (!mounted) return;
    switch (_ad.state.value) {
      case MaxNativeAdState.loaded:
        _notifyAvailability(true);
        setState(() {});
      case MaxNativeAdState.failed:
        _retryOrFail();
      case MaxNativeAdState.idle:
      case MaxNativeAdState.loading:
        setState(() {});
    }
  }

  void _retryOrFail() {
    if (_isFailed || _retryTimer != null) return;
    if (_retries >= _maxRetries) {
      _fail();
      return;
    }
    _retries++;
    _retryTimer = Timer(_retryDelay, () {
      _retryTimer = null;
      if (!mounted || _isFailed) return;
      NativeAds.preload(widget.placement).then((started) {
        if (mounted && !started) _retryOrFail();
      });
    });
  }

  void _fail() {
    if (_isFailed) return;
    setState(() => _isFailed = true);
    // Tell the screen once the fold is done, so its own change comes after.
    Future.delayed(_collapseDuration, () {
      if (mounted) _notifyAvailability(false);
    });
  }

  void _notifyAvailability(bool available) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onAdAvailabilityChanged?.call(available);
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad.state.removeListener(_onAdStateChanged);
    if (!_isFailed) _ad.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Off from the start (premium, remote config): nothing to fold away.
    if (_off || !NativeAds.isEnabled(widget.placement)) {
      return const SizedBox.shrink();
    }
    final effectiveHeight = widget.height ?? _kDefaultNativeAdHeight.h;
    final content = SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: _ad.state.value == MaxNativeAdState.loaded
          ? MaxNativeAdView(ad: _ad)
          : MediumNativeAdShimmer(
              height: effectiveHeight,
              backgroundColor: widget.backgroundColor,
            ),
    );

    final card = widget.margin != null
        ? Padding(padding: widget.margin!, child: content)
        : content;
    if (!_isFailed) return card;

    // Failed: the placeholder fades and folds up smoothly, then is gone.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: _collapseDuration,
      curve: Curves.easeInOut,
      child: card,
      builder: (context, t, child) => t == 0
          ? const SizedBox(width: double.infinity)
          : ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: t,
                child: Opacity(opacity: t, child: child),
              ),
            ),
    );
  }
}
