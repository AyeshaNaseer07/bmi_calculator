import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';
import 'ad_shimmer.dart';

const double _kNativeAdHeight = 285;

class NativeAdCard extends StatefulWidget {
  final String? adUnitId;
  final EdgeInsetsGeometry? margin;
  final ValueChanged<bool>? onAdAvailabilityChanged;

  const NativeAdCard({
    super.key,
    this.adUnitId,
    this.margin,
    this.onAdAvailabilityChanged,
  });

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
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
      tag: 'NativeAdCard',
      adUnitId: adUnitId,
      factoryId: 'mediumNativeAd',
    );

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'mediumNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          AdLogHelper.logLoaded(tag: 'NativeAdCard', ad: ad as NativeAd);
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _isFailed = false;
          });
          widget.onAdAvailabilityChanged?.call(true);
        },
        onAdFailedToLoad: (ad, error) {
          AdLogHelper.logFailed(
            tag: 'NativeAdCard',
            ad: ad as NativeAd,
            error: error,
          );
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
          widget.onAdAvailabilityChanged?.call(false);
        },
        onAdOpened: (ad) {
          debugPrint(
            '👀 [NativeAdCard] onAdOpened (user opened ad overlay/content)',
          );
        },
        onAdClosed: (ad) {
          debugPrint(
            '🔒 [NativeAdCard] onAdClosed (user closed ad overlay/content)',
          );
        },
        onAdImpression: (ad) {
          debugPrint('👁️ [NativeAdCard] onAdImpression logged');
        },
        onAdClicked: (ad) {
          debugPrint('👆 [NativeAdCard] onAdClicked');
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          debugPrint(
            '💰 [NativeAdCard] onPaidEvent: $valueMicros $currencyCode',
          );
          logAdRevenue(
            adNetwork: 'AdMob',
            revenue: valueMicros,
            currency: currencyCode,
            adFormat: 'native',
            adUnitId: _effectiveAdUnitId,
            mediationNetwork: 'GoogleAdMob',
            adType: 'MediumNativeAd',
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
    final content = SizedBox(
      width: double.infinity,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: _isLoaded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox(
          width: double.infinity,
          child: MediumNativeAdShimmer(),
        ),
        secondChild: _isLoaded && _nativeAd != null
            ? Container(
                width: double.infinity,
                height: _kNativeAdHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFE8F7F2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: double.infinity,
                  height: _kNativeAdHeight,
                  child: AdWidget(ad: _nativeAd!),
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: content);
    }
    return content;
  }
}
