import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_shimmer.dart';

/// Renders a medium native ad card matching the app design system.
/// Displays a shimmer skeleton while loading, displays AdWidget when loaded,
/// and dismisses/collapses cleanly if the ad fails to load.
class NativeAdCard extends StatefulWidget {
  final String? adUnitId;
  final EdgeInsetsGeometry? margin;

  /// Fired once the ad finishes loading (true) or fails to load (false),
  /// so a parent that wraps this in extra chrome (e.g. a bottom bar
  /// container) can collapse that chrome entirely on failure.
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
    _nativeAd = NativeAd(
      adUnitId: _effectiveAdUnitId,
      factoryId: 'mediumNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _isFailed = false;
          });
          widget.onAdAvailabilityChanged?.call(true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ NativeAd failed to load: ${error.message} (code: ${error.code})');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _isFailed = true;
          });
          widget.onAdAvailabilityChanged?.call(false);
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
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
    // If ad failed, dismiss completely and collapse space
    if (_isFailed) {
      return const SizedBox.shrink();
    }

    final content = AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState:
          _isLoaded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const MediumNativeAdShimmer(),
      secondChild: _isLoaded && _nativeAd != null
          ? Container(
              height: 270.h,
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
              child: AdWidget(ad: _nativeAd!),
            )
          : const SizedBox.shrink(),
    );

    if (widget.margin != null) {
      return Padding(
        padding: widget.margin!,
        child: content,
      );
    }
    return content;
  }
}
