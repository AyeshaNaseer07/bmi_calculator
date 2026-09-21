import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';
import 'ad_shimmer.dart';

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
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isFailed = false;

  // Close (X) button only appears after this many seconds; until then a
  // countdown circle is shown and swiping away this page is disabled — the
  // only way forward is tapping the X once it appears.
  static const int _closeDelaySeconds = 4;
  int _remainingSeconds = _closeDelaySeconds;
  Timer? _countdownTimer;

  bool get _isAdsEnabled {
    if (Get.isRegistered<AppController>()) {
      if (Get.find<AppController>().isPremium.value) return false;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isAdsEnabled;
    }
    return remoteModel.isAdsEnabled;
  }

  String get _effectiveAdUnitId {
    if (widget.adUnitId != null && widget.adUnitId!.isNotEmpty) {
      return widget.adUnitId!;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      final remoteAdId = RemoteConfigService.to.nativeAdId;
      if (remoteAdId.isNotEmpty) return remoteAdId;
    }
    if (remoteModel.nativeAdId.isNotEmpty) {
      return remoteModel.nativeAdId;
    }
    return Platform.isIOS
        ? 'ca-app-pub-3940256099942544/3986624511'
        : 'ca-app-pub-3940256099942544/2247696110';
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
    _startCountdown();
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

  void _loadAd() {
    if (!_isAdsEnabled) {
      _isFailed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onNext();
        }
      });
      return;
    }
    final adUnitId = _effectiveAdUnitId;
    AdLogHelper.logRequest(
      tag: 'FullScreenNativeAdPage',
      adUnitId: adUnitId,
      factoryId: 'fullScreenNativeAd',
    );

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'fullScreenNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          AdLogHelper.logLoaded(
            tag: 'FullScreenNativeAdPage',
            ad: ad as NativeAd,
          );
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _isFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          AdLogHelper.logFailed(
            tag: 'FullScreenNativeAdPage',
            ad: ad as NativeAd,
            error: error,
          );
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
        },
        onAdOpened: (ad) {
          debugPrint(
            '👀 [FullScreenNativeAdPage] onAdOpened (user opened ad overlay/content)',
          );
        },
        onAdClosed: (ad) {
          debugPrint(
            '🔒 [FullScreenNativeAdPage] onAdClosed (user closed ad overlay/content)',
          );
        },
        onAdImpression: (ad) {
          debugPrint('👁️ [FullScreenNativeAdPage] onAdImpression logged');
        },
        onAdClicked: (ad) {
          debugPrint('👆 [FullScreenNativeAdPage] onAdClicked');
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          debugPrint(
            '💰 [FullScreenNativeAdPage] onPaidEvent: $valueMicros $currencyCode',
          );
          logAdRevenue(
            adNetwork: 'AdMob',
            revenue: valueMicros,
            currency: currencyCode,
            adFormat: 'native',
            adUnitId: ad.adUnitId,
            mediationNetwork: 'GoogleAdMob',
            adType: 'FullScreenNativeAd',
          );
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nativeAd?.dispose();
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
          // Ad or Shimmer View
          Positioned.fill(
            child: _isLoaded && _nativeAd != null && !_isFailed
                ? AdWidget(
                    key: ValueKey('full_screen_ad_${_nativeAd.hashCode}'),
                    ad: _nativeAd!,
                  )
                : const FullScreenNativeAdShimmer(),
          ),

          // Top-right countdown -> close (X) control. Nothing is tappable (and
          // swiping is disabled by the parent PageView) until the countdown
          // reaches zero and the X appears; tapping the X is the only way to
          // advance.
          // Same row as the native AD badge: the native header starts at
          // max(top inset, 20) and centres its items 30pt below that.
          Positioned(
            top: math.max(MediaQuery.of(context).padding.top, 20) + 16,
            right: 15,
            child: _remainingSeconds > 0
                ? _CountdownBadge(seconds: _remainingSeconds)
                : GestureDetector(
                    onTap: widget.onNext,
                    behavior: HitTestBehavior.opaque,
                    child: const _CloseBadge(),
                  ),
          ),
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
