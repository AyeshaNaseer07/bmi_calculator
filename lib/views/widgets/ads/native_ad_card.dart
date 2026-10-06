import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../controllers/app_controller.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';
import 'ad_preloader.dart';
import 'ad_shimmer.dart';

const double _kDefaultNativeAdHeight = 350;

class NativeAdCard extends StatefulWidget {
  final String? adUnitId;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Color? backgroundColor;

  /// Name of an ad placement preloaded on the splash screen (see AdSlots).
  final String? slot;
  final ValueChanged<bool>? onAdAvailabilityChanged;

  const NativeAdCard({
    super.key,
    this.adUnitId,
    this.margin,
    this.height,
    this.backgroundColor,
    this.slot,
    this.onAdAvailabilityChanged,
  });

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isFailed = false;

  bool get _isAdsEnabled {
    try {
      if (Get.isRegistered<AppController>()) {
        if (Get.find<AppController>().isPremium.value) return false;
      }
      if (Get.isRegistered<RemoteConfigService>()) {
        return RemoteConfigService.to.isNativeAdEnabled;
      }
      return remoteModel.isNativeAdEnabled;
    } catch (_) {
      return true;
    }
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
  }

  void _notifyAvailability(bool available) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onAdAvailabilityChanged?.call(available);
    });
  }

  /// Uses the ad preloaded on splash, if there is one for this placement.
  bool _tryUsePreloaded() {
    final key = widget.slot;
    if (key == null) return false;
    final pre = AdPreloader.instance.claim(key);
    if (pre == null) return false;

    if (pre.failed) {
      _isFailed = true;
      _notifyAvailability(false);
      return true;
    }
    _nativeAd = pre.ad;
    if (pre.loaded) {
      _isLoaded = true;
      _notifyAvailability(true);
    } else {
      // Still loading — show the shimmer and finish when it completes.
      pre.onDone = (ok) {
        if (!mounted) return;
        setState(() {
          _isLoaded = ok;
          _isFailed = !ok;
          if (!ok) _nativeAd = null;
        });
        _notifyAvailability(ok);
      };
    }
    return true;
  }

  void _loadAd() {
    if (!_isAdsEnabled) {
      _isFailed = true;
      widget.onAdAvailabilityChanged?.call(false);
      return;
    }
    if (_tryUsePreloaded()) return;
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onAdAvailabilityChanged?.call(true);
            }
          });
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onAdAvailabilityChanged?.call(false);
            }
          });
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
    if (!_isAdsEnabled || _isFailed) {
      return const SizedBox.shrink();
    }
    final effectiveHeight = widget.height ?? _kDefaultNativeAdHeight.h;
    final content = SizedBox(
      width: double.infinity,
      child: _isLoaded && _nativeAd != null
          ? Container(
              key: ValueKey('native_ad_container_${_nativeAd.hashCode}'),
              width: double.infinity,
              height: effectiveHeight,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity,
                height: effectiveHeight,
                child: AdWidget(
                  key: ValueKey('ad_widget_${_nativeAd.hashCode}'),
                  ad: _nativeAd!,
                ),
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: MediumNativeAdShimmer(
                height: effectiveHeight,
                backgroundColor: widget.backgroundColor,
              ),
            ),
    );

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: content);
    }
    return content;
  }
}
