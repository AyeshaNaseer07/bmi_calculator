import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/app_startup.dart';
import '../widgets/ads/interstitial_ad_manager.dart';
import '../widgets/ads/native_ad_card.dart';
import '../widgets/app_background.dart';
import '../../core/utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  static const Duration _barDuration = Duration(seconds: 6);

  /// The ad is shown as the bar passes this point.
  static const double _adAt = 0.99;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _barDuration,
    );
  }

  bool _imagesRequested = false;
  bool _firstFrameAllowed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagesRequested) return;
    _imagesRequested = true;
    _precacheThenReveal();
  }

  Future<void> _precacheThenReveal() async {
    try {
      await Future.wait([
        precacheImage(const AssetImage(AppAssets.appBg), context),
        precacheImage(const AssetImage(AppAssets.splashBg), context),
        precacheImage(const AssetImage(AppAssets.splashLogo), context),
      ]).timeout(const Duration(seconds: 2));
    } catch (_) {
      // Show the splash anyway rather than stay on the launch screen.
    }
    _allowFirstFrame();
    if (!mounted) return;
    _startUp();
  }

  void _allowFirstFrame() {
    if (_firstFrameAllowed) return;
    _firstFrameAllowed = true;
    WidgetsBinding.instance.allowFirstFrame();
  }

  /// Completes when the bar reaches [point].
  Future<void> _barReaches(double point) {
    final reached = Completer<void>();
    void check() {
      if (_progressController.value >= point && !reached.isCompleted) {
        reached.complete();
        _progressController.removeListener(check);
      }
    }

    _progressController.addListener(check);
    check();
    return reached.future;
  }

  /// Time the bar still needs to reach [_adAt].
  Duration get _barTimeLeft {
    final left = (_adAt - _progressController.value).clamp(0.0, 1.0);
    return _barDuration * left;
  }

  Future<void> _startUp() async {
    // Linear: the same speed from start to end.
    final barDone = _barReaches(_adAt);
    _progressController.forward();
    await AppStartup.run();
    if (!mounted) return;
    // Waits for the language native at most until the bar is done.
    _languageAd = NativeAds.waitForLoad(
      NativeAdPlacement.language,
      timeout: _barTimeLeft,
    );
    if (Get.isRegistered<AppController>()) {
      await Get.find<AppController>().subscriptionVerified.timeout(
        _barTimeLeft,
        onTimeout: () {},
      );
    }
    await barDone;
    if (!mounted) return;
    final isPremium =
        Get.isRegistered<AppController>() &&
        Get.find<AppController>().isPremium.value;
    if (isPremium) {
      await _barReaches(1);
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    final ads = InterstitialAdManager.instance;
    // Load failed or still loading: no ad, so let the bar fill completely
    // first, then open the language screen without a jump.
    if (!await ads.isReady(InterstitialPlacement.splash)) {
      await _openLanguage();
      return;
    }
    // Ready: shows now, as the bar passes 99%.
    await ads.show(
      InterstitialPlacement.splash,
      onDone: _openLanguage,
    );
  }

  Future<void>? _languageAd;

  bool _leaving = false;

  /// Also the ad's onDone: runs on close, on a failed show, or on timeout.
  Future<void> _openLanguage() async {
    if (_leaving) return;
    _leaving = true;
    // Behind a shown ad the bar is already full; after a failed show it
    // finishes its last sliver first, so the screen never cuts away early.
    await Future.wait([_barReaches(1), ?_languageAd]);
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.languageSelection);
  }

  @override
  void dispose() {
    _allowFirstFrame();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // — Full Screen Background —
            Positioned(
              left: -5.w,
              right: -5.w,
              top: isTablet(context) ? 0 : null,
              bottom: isTablet(context) ? -12.h : null,
              child: Image.asset(
                AppAssets.splashBg,
                fit: isTablet(context) ? BoxFit.fill : BoxFit.cover,
              ),
            ),
            // Center Logo & Tagline
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Image.asset(
                      AppAssets.splashLogo,
                      width: 220.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text(
                        'splash_tagline'.tr,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(flex: 4),

                    // Bottom Progress Bar & Loading Text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: Column(
                        children: [
                          Container(
                            height: 8.h,
                            width: 140.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 1.h),
                                ),
                              ],
                            ),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Container(
                                    width: 140.w * _progressController.value,
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.buttonGradient,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'loading'.tr,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
