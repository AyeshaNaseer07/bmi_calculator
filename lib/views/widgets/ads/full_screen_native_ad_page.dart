import 'dart:async';
import 'dart:math' as math;

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';
import 'ad_shimmer.dart';
import 'app_open_ad_manager.dart';
import 'applovin_sdk.dart';

/// Full-screen AppLovin MAX native ad shown between onboarding pages.
///
/// Layout (from the 375 x 812 design): white header with the AD badge (the
/// countdown / close control is drawn on the same row), media filling the
/// middle at its own aspect ratio, then a centered 80pt icon, star rating,
/// headline, body and a gradient CTA pill above the bottom safe area.
class FullScreenNativeAdPage extends StatefulWidget {
  final String? adUnitId;
  final VoidCallback onNext;
  final VoidCallback? onAdFailed;

  const FullScreenNativeAdPage({
    super.key,
    this.adUnitId,
    required this.onNext,
    this.onAdFailed,
  });

  @override
  State<FullScreenNativeAdPage> createState() => _FullScreenNativeAdPageState();
}

class _FullScreenNativeAdPageState extends State<FullScreenNativeAdPage> {
  static const double _defaultMediaAspectRatio = 16 / 9;

  bool _sdkReady = false;
  bool _isLoaded = false;
  bool _isFailed = false;
  double _mediaAspectRatio = _defaultMediaAspectRatio;
  bool _hasStarRating = false;

  // Close (X) button only appears after this many seconds; until then a
  // countdown circle is shown and swiping away this page is disabled — the
  // only way forward is tapping the X once it appears.
  static const int _closeDelaySeconds = 4;
  int _remainingSeconds = _closeDelaySeconds;
  Timer? _countdownTimer;

  // Hard safety net: if the ad never finishes loading (no fill, no network,
  // or the platform ad view never renders) the user must not be stuck on a
  // blank/black screen with no way forward. Auto-advance once this fires,
  // regardless of ad state.
  static const int _maxWaitSeconds = 8;
  Timer? _safetyTimer;
  bool _hasAdvanced = false;

  bool get _isAdsEnabled {
    if (Get.isRegistered<AppController>()) {
      if (Get.find<AppController>().isPremium.value) return false;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isFullScreenNativeAdEnabled;
    }
    return remoteModel.isFullScreenNativeAdEnabled;
  }

  String get _effectiveAdUnitId {
    if (widget.adUnitId != null && widget.adUnitId!.isNotEmpty) {
      return widget.adUnitId!;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      final remoteAdId = RemoteConfigService.to.fullScreenNativeAdId;
      if (remoteAdId.isNotEmpty) return remoteAdId;
    }
    if (remoteModel.fullScreenNativeAdId.isNotEmpty) {
      return remoteModel.fullScreenNativeAdId;
    }
    return RemoteModel.defaultFullScreenNativeAdId;
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
    _startCountdown();
    _safetyTimer = Timer(const Duration(seconds: _maxWaitSeconds), () {
      if (mounted && !_isLoaded) {
        _advance();
      }
    });
  }

  /// Moves to the next onboarding page exactly once, however we got here
  /// (ad failed, ad never loaded, or the user tapped the close button).
  void _advance() {
    if (_hasAdvanced) return;
    _hasAdvanced = true;
    widget.onNext();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  /// No ad to show — don't leave the user staring at a blank screen waiting
  /// out the close-button countdown; move on now.
  void _fail() {
    if (!mounted) return;
    setState(() => _isFailed = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _advance();
    });
  }

  void _loadAd() {
    if (!_isAdsEnabled) {
      _isFailed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _advance();
      });
      return;
    }
    AppLovinSdk.ready.then((ready) {
      if (!mounted) return;
      if (!ready) {
        _fail();
        return;
      }
      AdLogHelper.logRequest(
        tag: 'FullScreenNativeAdPage',
        adUnitId: _effectiveAdUnitId,
      );
      setState(() => _sdkReady = true);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdsEnabled) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (_sdkReady && !_isFailed)
            Positioned.fill(
              child: MaxNativeAdView(
                adUnitId: _effectiveAdUnitId,
                placement: 'full_screen_native',
                listener: NativeAdListener(
                  onAdLoadedCallback: (ad) {
                    AdLogHelper.logLoaded(
                      tag: 'FullScreenNativeAdPage',
                      ad: ad,
                    );
                    if (!mounted) return;
                    final ratio = ad.nativeAd?.mediaContentAspectRatio;
                    final rating = ad.nativeAd?.starRating;
                    setState(() {
                      _isLoaded = true;
                      if (ratio != null && ratio > 0) _mediaAspectRatio = ratio;
                      // Only show a rating the advertiser actually supplied.
                      _hasStarRating = rating != null && rating > 0;
                    });
                  },
                  onAdLoadFailedCallback: (adUnitId, error) {
                    AdLogHelper.logFailed(
                      tag: 'FullScreenNativeAdPage',
                      adUnitId: adUnitId,
                      error: error,
                    );
                    _fail();
                  },
                  onAdClickedCallback: (_) {
                    debugPrint('👆 [FullScreenNativeAdPage] onAdClicked');
                    AppOpenAdManager.instance.skipNextResume();
                  },
                  onAdRevenuePaidCallback: (ad) =>
                      logMaxAdRevenue(ad, adType: 'FullScreenNativeAd'),
                ),
                child: _buildAssetViews(context),
              ),
            ),
          if (!_isLoaded)
            const Positioned.fill(child: FullScreenNativeAdShimmer()),

          Positioned(
            top: math.max(MediaQuery.of(context).padding.top, 20) + 16,
            right: 15,
            child: _remainingSeconds > 0
                ? _CountdownBadge(seconds: _remainingSeconds)
                : GestureDetector(
                    onTap: _advance,
                    behavior: HitTestBehavior.opaque,
                    child: const _CloseBadge(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetViews(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: math.max(padding.top, 20)),
          // Header: AD badge (countdown / close sits on this row too).
          SizedBox(
            height: 52,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 21),
                child: Container(
                  width: 36,
                  height: 23,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26F1A5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _mediaAspectRatio,
                    child: const MaxNativeAdMediaView(),
                  ),
                ),
                const Positioned(
                  top: 4,
                  right: 4,
                  child: MaxNativeAdOptionsView(width: 20, height: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: const MaxNativeAdIconView(width: 80, height: 80),
            ),
          ),
          if (_hasStarRating) ...[
            const SizedBox(height: 10),
            const Center(
              child: MaxNativeAdStarRatingView(
                size: 12,
                color: Color(0xFFF9AE0E),
                shadowColor: Color(0xFFE8E7E8),
              ),
            ),
          ],
          const SizedBox(height: 9),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: MaxNativeAdTitleView(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 11),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: MaxNativeAdBodyView(
              style: TextStyle(fontSize: 13, color: Color(0xFF101010)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 54,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2FD1A6), Color(0xFF168EE2)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(27)),
              ),
              child: const MaxNativeAdCallToActionView(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  shadowColor: WidgetStatePropertyAll(Colors.transparent),
                  elevation: WidgetStatePropertyAll(0),
                  shape: WidgetStatePropertyAll(StadiumBorder()),
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: padding.bottom + 15),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final int seconds;

  const _CountdownBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF8E8E8E),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$seconds',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CloseBadge extends StatelessWidget {
  const _CloseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF8E8E8E),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.close, size: 16, color: Colors.white),
    );
  }
}
