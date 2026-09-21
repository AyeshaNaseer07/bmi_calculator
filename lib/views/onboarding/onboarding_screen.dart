import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/ads/full_screen_native_ad_page.dart';
import '../widgets/ads/native_ad_card.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/next_button.dart';

class OnboardingItem {
  final String imagePath;
  final String titlePrefix;
  final String titleHighlight;
  final String subtitle;

  const OnboardingItem({
    required this.imagePath,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 4 steps:
  // 0: BMI Calculator with Bottom Native Ad
  // 1: Full-Screen Native Ad
  // 2: Weight Tracking
  // 3: Health Insights
  static const int _totalPages = 4;

  void _onNext() {
    if (_pageController.hasClients) {
      if (_currentIndex < _totalPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        _navigateToPaywall();
      }
    } else {
      _navigateToPaywall();
    }
  }

  void _navigateToPaywall() {
    Get.toNamed(AppRoutes.paywall);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                // Page 0: BMI Screen with Bottom Native Ad (iPhone 13 mini - 55)
                _buildBmiAdSlide(),

                // Page 1: Full-Screen Native Ad (iPhone 13 mini - 59)
                FullScreenNativeAdPage(onNext: _onNext),

                // Page 2: Weight Tracking (iPhone 13 mini - 65)
                _buildContentSlide(
                  imagePath: AppAssets.onboarding2,
                  titlePrefix: 'Weight ',
                  titleHighlight: 'Tracking',
                  subtitle: 'Monitor your daily, weekly and monthly\nweight journey effortlessly',
                ),

                // Page 3: Health Insights (iPhone 13 mini - 63)
                _buildContentSlide(
                  imagePath: AppAssets.onboarding3,
                  titlePrefix: 'Health ',
                  titleHighlight: 'Insights',
                  subtitle: 'Get personalized insights to build\nhealthier habits every day.',
                ),
              ],
            ),

            if (_currentIndex != 1)
              // Bottom Controls (Dot indicator & Next button) for Page 2 & 3
              if (_currentIndex >= 2)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 20,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dot Indicator (4 dots matching Figma)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_totalPages, (index) {
                            final isActive = index == _currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isActive
                                    ? const Color(0xFF24CCA7)
                                    : const Color(0xFFC7F3EA),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 20),

                        // Next Gradient Button
                        CustomGradientButton(
                          text: 'Next',
                          backgroundImage: AppAssets.btnRectangle,
                          borderRadius: BorderRadius.circular(12.r),
                          trailingIcon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: _onNext,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// Builds Onboarding Slide 1 with illustration at top and native ad card at bottom
  Widget _buildBmiAdSlide() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(height: 6.h),
          // Top Illustration
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Image.asset(AppAssets.onboarding1, fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 8.h),

          // Title: BMI Calculator
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 28.sp,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              children: const [
                TextSpan(text: 'BMI '),
                TextSpan(
                  text: 'Calculator',
                  style: TextStyle(color: Color(0xFF24CCA7)),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Track your BMI, monitor your progress,\nand stay healthy with personalized insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.85),
                fontSize: 13.sp,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Controls Row: 4 Indicator Dots on Left & NextButton on Right
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dot Indicator (4 circular dots)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_totalPages, (index) {
                    final isActive = index == 0;
                    return Container(
                      margin: EdgeInsets.only(
                        right: index < _totalPages - 1 ? 6.w : 0,
                      ),
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF24CCA7)
                            : const Color(0xFFC7F3EA),
                      ),
                    );
                  }),
                ),

                // Next Action Button
                NextButton(onNext: _onNext),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Bottom Native Ad Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const NativeAdCard(),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  /// Builds standard Onboarding Content Slide (Weight Tracking, Health Insights)
  Widget _buildContentSlide({
    required String imagePath,
    required String titlePrefix,
    required String titleHighlight,
    required String subtitle,
  }) {
    return Stack(
      children: [
        // Full background illustration - Top to Middle
        Positioned(
          top: 56,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.58,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),

        // Title and Subtitle positioned above the bottom controls
        Positioned(
          left: 24,
          right: 24,
          bottom: 126,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(text: titlePrefix),
                    TextSpan(
                      text: titleHighlight,
                      style: const TextStyle(color: Color(0xFF24CCA7)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 22.h),
            ],
          ),
        ),
      ],
    );
  }
}
