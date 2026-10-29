import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/app_controller.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/remote_model.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../main.dart';
import 'ad_logger.dart';
import 'ad_shimmer.dart';
import 'app_open_ad_manager.dart';
import 'applovin_sdk.dart';

const double _kDefaultNativeAdHeight = 350;

/// Screens with a native ad card, each switched on/off and given its ad unit
/// ID from Remote Config.
enum NativeAdPlacement { language, onboarding }

/// AppLovin MAX native ad with media: icon, headline, AD badge + body, media
/// and a CTA button. Shows a shimmer while loading and nothing on failure.
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
  static const double _defaultMediaAspectRatio = 16 / 9;

  bool _sdkReady = false;
  bool _isLoaded = false;
  bool _isFailed = false;
  double _mediaAspectRatio = _defaultMediaAspectRatio;

  RemoteModel get _config => Get.isRegistered<RemoteConfigService>()
      ? RemoteConfigService.to.current
      : remoteModel;

  bool get _isAdsEnabled {
    try {
      if (Get.isRegistered<AppController>()) {
        if (Get.find<AppController>().isPremium.value) return false;
      }
      return switch (widget.placement) {
        NativeAdPlacement.language => _config.isLanguageNativeAdEnabled,
        NativeAdPlacement.onboarding => _config.isOnboardingNativeAdEnabled,
      };
    } catch (_) {
      return true;
    }
  }

  String get _effectiveAdUnitId {
    final (id, fallback) = switch (widget.placement) {
      NativeAdPlacement.language => (
        _config.languageNativeAdId,
        RemoteModel.defaultLanguageNativeAdId,
      ),
      NativeAdPlacement.onboarding => (
        _config.onboardingNativeAdId,
        RemoteModel.defaultOnboardingNativeAdId,
      ),
    };
    return id.isNotEmpty ? id : fallback;
  }

  @override
  void initState() {
    super.initState();
    if (!_isAdsEnabled) {
      _isFailed = true;
      // Deferred: we're inside initState, and the parent usually calls
      // setState in response, which isn't allowed mid-build.
      _notifyAvailability(false);
      return;
    }
    AppLovinSdk.ready.then((ready) {
      if (!mounted) return;
      if (!ready) {
        setState(() => _isFailed = true);
        _notifyAvailability(false);
        return;
      }
      AdLogHelper.logRequest(tag: 'NativeAdCard', adUnitId: _effectiveAdUnitId);
      setState(() => _sdkReady = true);
    });
  }

  void _notifyAvailability(bool available) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onAdAvailabilityChanged?.call(available);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdsEnabled || _isFailed) {
      return const SizedBox.shrink();
    }
    final effectiveHeight = widget.height ?? _kDefaultNativeAdHeight.h;
    final content = SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: Stack(
        children: [
          if (_sdkReady)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: MaxNativeAdView(
                  adUnitId: _effectiveAdUnitId,
                  placement: '${widget.placement.name}_native',
                  listener: NativeAdListener(
                    onAdLoadedCallback: (ad) {
                      AdLogHelper.logLoaded(tag: 'NativeAdCard', ad: ad);
                      if (!mounted) return;
                      final ratio = ad.nativeAd?.mediaContentAspectRatio;
                      setState(() {
                        _isLoaded = true;
                        if (ratio != null && ratio > 0) {
                          _mediaAspectRatio = ratio;
                        }
                      });
                      _notifyAvailability(true);
                    },
                    onAdLoadFailedCallback: (adUnitId, error) {
                      AdLogHelper.logFailed(
                        tag: 'NativeAdCard',
                        adUnitId: adUnitId,
                        error: error,
                      );
                      if (!mounted) return;
                      setState(() => _isFailed = true);
                      _notifyAvailability(false);
                    },
                    onAdClickedCallback: (_) {
                      debugPrint('👆 [NativeAdCard] onAdClicked');
                      AppOpenAdManager.instance.skipNextResume();
                    },
                    onAdRevenuePaidCallback: (ad) =>
                        logMaxAdRevenue(ad, adType: 'MediumNativeAd'),
                  ),
                  child: _buildAssetViews(),
                ),
              ),
            ),
          // Covers the ad view until it has something to show.
          if (!_isLoaded)
            Positioned.fill(
              child: MediumNativeAdShimmer(
                height: effectiveHeight,
                backgroundColor: widget.backgroundColor,
              ),
            ),
        ],
      ),
    );

    if (widget.margin != null) {
      return Padding(padding: widget.margin!, child: content);
    }
    return content;
  }

  Widget _buildAssetViews() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: MaxNativeAdIconView(width: 50.w, height: 50.w),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaxNativeAdTitleView(
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AdBadge(),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: MaxNativeAdBodyView(
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppPalette.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              // AdChoices / privacy icon, inset from the rounded corner.
              const MaxNativeAdOptionsView(width: 16, height: 16),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _mediaAspectRatio,
                child: const MaxNativeAdMediaView(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 48.h,
            child: MaxNativeAdCallToActionView(
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(
                  Color(0xFF1B92D6),
                ),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                elevation: const WidgetStatePropertyAll(0),
                shape: const WidgetStatePropertyAll(StadiumBorder()),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdBadge extends StatelessWidget {
  const _AdBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 15.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBFBFBF)),
        borderRadius: BorderRadius.circular(3.5.r),
      ),
      child: Text(
        'AD',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF808080),
        ),
      ),
    );
  }
}
