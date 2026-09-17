import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
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
    _nativeAd = NativeAd(
      adUnitId: _effectiveAdUnitId,
      factoryId: 'fullScreenNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _isFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ FullScreen NativeAd failed to load: ${error.message}');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
          widget.onAdFailed?.call();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          logAdRevenue(
            adNetwork: 'AdMob',
            revenue: valueMicros,
            currency: currencyCode,
            adFormat: 'native',
            adUnitId: _effectiveAdUnitId,
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

          // Top Left Skip / Close Action (pill matching onboarding style)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, left: 18),
                child: GestureDetector(
                  onTap: widget.onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0x4F33D2AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'skip'.tr,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
