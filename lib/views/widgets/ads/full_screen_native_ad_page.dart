import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  }

  void _loadAd() {
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
          widget.onAdFailed?.call();
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
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFailed) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ad or Shimmer View
          Positioned.fill(
            child: _isLoaded && _nativeAd != null
                ? AdWidget(ad: _nativeAd!)
                : const FullScreenNativeAdShimmer(),
          ),
        ],
      ),
    );
  }
}
