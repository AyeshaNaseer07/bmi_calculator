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
  late Animation<double> _progressAnimation;
  static const int _splashSeconds = 3;
  static const Duration _splashAdWait = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _splashSeconds),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
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
    _progressController.forward();
    _startUp();
  }

  void _allowFirstFrame() {
    if (_firstFrameAllowed) return;
    _firstFrameAllowed = true;
    WidgetsBinding.instance.allowFirstFrame();
  }

  Future<void> _startUp() async {
    await Future.wait([
      AppStartup.run(),
      Future<void>.delayed(const Duration(seconds: _splashSeconds)),
    ]);
    if (!mounted) return;
    if (Get.isRegistered<AppController>()) {
      await Get.find<AppController>().subscriptionVerified.timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
    }
    if (!mounted) return;
    final isPremium =
        Get.isRegistered<AppController>() &&
        Get.find<AppController>().isPremium.value;
    if (isPremium) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    await InterstitialAdManager.instance.show(
      InterstitialPlacement.splash,
      waitFor: _splashAdWait,
      onDone: _openLanguage,
    );
  }

  Future<void> _openLanguage() async {
    await NativeAds.waitForLoad(
      NativeAdPlacement.language,
      timeout: _splashAdWait,
    );
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
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Container(
                                    width: 140.w * _progressAnimation.value,
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
