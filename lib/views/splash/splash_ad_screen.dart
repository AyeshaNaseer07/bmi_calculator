import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/ads/ad_preloader.dart';
import '../widgets/ads/ad_shimmer.dart';
import '../widgets/animated_cta_button.dart';
import '../widgets/app_background.dart';

class SplashAdScreen extends StatefulWidget {
  const SplashAdScreen({super.key});

  @override
  State<SplashAdScreen> createState() => _SplashAdScreenState();
}

class _SplashAdScreenState extends State<SplashAdScreen> {
  NativeAd? _ad;
  bool _isLoaded = false;
  bool _hasAdvanced = false;

  static const int _maxWaitSeconds = 8;
  Timer? _safetyTimer;

  static const Color _navy = Color(0xFF0F1F4B);

  @override
  void initState() {
    super.initState();
    if (!AdPreloader.instance.splashEnabled) {
      _advanceAfterFrame();
      return;
    }
    final pre = AdPreloader.instance.claimSplash();
    if (pre.failed) {
      _advanceAfterFrame();
      return;
    }
    _ad = pre.ad;
    _isLoaded = pre.loaded;
    if (!_isLoaded) {
      pre.onDone = (ok) {
        if (!mounted) return;
        if (ok) {
          setState(() => _isLoaded = true);
        } else {
          // The preloader already disposed the failed ad.
          _ad = null;
          _advance();
        }
      };
      _safetyTimer = Timer(const Duration(seconds: _maxWaitSeconds), () {
        if (mounted && !_isLoaded) _advance();
      });
    }
  }

  void _advanceAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _advance();
    });
  }

  /// Same destination the splash used before this screen existed.
  void _advance() {
    if (_hasAdvanced) return;
    _hasAdvanced = true;
    Get.offAllNamed(AppRoutes.languageSelection);
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return PopScope(
      canPop: false,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              SizedBox(height: padding.top + 8.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _isLoaded && _ad != null
                      ? AdWidget(
                          key: ValueKey('splash_ad_${_ad.hashCode}'),
                          ad: _ad!,
                        )
                      : const _SplashAdShimmer(),
                ),
              ),
              SizedBox(height: 24.h),
              _buildAppInfo(),
              SizedBox(height: 22.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AnimatedCtaButton(
                  text: 'Continue',
                  height: 54.h,
                  borderRadius: BorderRadius.circular(28.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF24CCA7), Color(0xFF168EE2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                  ),
                  trailingIcon: Image.asset(
                    AppAssets.arrowIcon,
                    width: 20.w,
                    height: 20.w,
                    color: Colors.white,
                  ),
                  onPressed: _advance,
                ),
              ),
              SizedBox(height: padding.bottom + 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2633D2AB),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(AppAssets.appIcon, width: 64.w, height: 64.w),
            ),
          ),
          SizedBox(width: 14.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BMI Calculator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _navy,
                    fontSize: 24.sp,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Know Your Body. Live Healthier',
                  maxLines: 2,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder in the shape of the native ad while it loads.
class _SplashAdShimmer extends StatelessWidget {
  const _SplashAdShimmer();

  @override
  Widget build(BuildContext context) {
    const bone = Color(0xFFDCE7E3);
    return ShimmerLoading(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        child: Container(
          color: const Color(0xFFF0FAF6),
          child: Column(
            children: [
              Expanded(child: Container(color: const Color(0xFFE0E5E5))),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: bone,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 140.w,
                                height: 16.h,
                                color: bone,
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: double.infinity,
                                height: 12.h,
                                color: bone,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: bone,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
