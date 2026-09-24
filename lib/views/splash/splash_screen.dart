import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _navigationTimer;

  /// Splash screen wait — was 10s, trimmed down so the app feels snappier.
  static const int _splashSeconds = 3;

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

    _progressController.forward();

    _navigationTimer = Timer(const Duration(seconds: _splashSeconds), () {
      if (!mounted) return;

      // A premium user has already been through Language Selection,
      // Onboarding and the Paywall once — never show that flow again.
      // Every launch, they go straight to Home.
      final isPremium = Get.isRegistered<AppController>() &&
          Get.find<AppController>().isPremium.value;
      if (isPremium) {
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      // Non-premium: every app flow (first launch and every one after)
      // starts at Language Selection. Whether the Onboarding slides show
      // next, and the Paywall shown after that, is decided from there —
      // same check on every flow, no first-launch/later-launch distinction.
      Get.offAllNamed(AppRoutes.languageSelection);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
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
              child: Image.asset(AppAssets.splashBg, fit: BoxFit.cover),
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
                        'Know Your Body. Live Healthier',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
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
                                  alignment: Alignment.centerLeft,
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
                            'Loading...',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: 12.sp,
                            ),
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
