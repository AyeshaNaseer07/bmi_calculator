import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/remote_model.dart';
import '../../data/services/remote_config_service.dart';
import '../widgets/ads/full_screen_native_ad_page.dart';
import '../widgets/ads/ad_preloader.dart';
import '../widgets/ads/native_ad_card.dart';
import '../widgets/app_background.dart';
import '../widgets/animated_cta_button.dart';
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
  bool _bmiAdAvailable = true;

  // 4 steps:
  // 0: BMI Calculator with Bottom Native Ad
  // 1: Full-Screen Native Ad
  // 2: Weight Tracking
  // 3: Health Insights

  late final bool _showFullScreenAd = _resolveShowFullScreenAd();

  bool _resolveShowFullScreenAd() {
    if (Get.isRegistered<AppController>() &&
        Get.find<AppController>().isPremium.value) {
      return false;
    }
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isFullScreenNativeAdEnabled;
    }
    return remoteModel.isFullScreenNativeAdEnabled;
  }

  int get _totalPages => _showFullScreenAd ? 4 : 3;
  int get _adPageIndex => _showFullScreenAd ? 1 : -1;
  int get _firstContentIndex => _showFullScreenAd ? 2 : 1;

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
    Get.toNamed(AppRoutes.paywall, arguments: {'fromOnboarding': true});
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

              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                // Page 0: with bottom native ad when it loads, otherwise the
                // same full layout as the other content slides.
                if (_bmiAdAvailable)
                  _buildBmiAdSlide()
                else
                  _buildContentSlide(
                    imagePath: AppAssets.onboarding1,
                    titlePrefix: 'BMI ',
                    titleHighlight: 'Calculator',
                    subtitle: 'Track your BMI, monitor your progress,\nand stay healthy with personalized insights.',
                  ),

                // Page 1: Full-Screen Native Ad (iPhone 13 mini - 59)
                if (_showFullScreenAd) FullScreenNativeAdPage(onNext: _onNext),

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

            if (_currentIndex != _adPageIndex)
              // Bottom Controls (Dot indicator & Next button) for Page 2 & 3
              if (_currentIndex >= _firstContentIndex ||
                  (_currentIndex == 0 && !_bmiAdAvailable))
                Positioned(
                  left: 24.w,
                  right: 24.w,
                  bottom: 20.h,
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
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: isActive
                                    ? const Color(0xFF24CCA7)
                                    : const Color(0xFFC7F3EA),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 20.h),

                        // Next Gradient Button
                        _AnimatedGradientNextButton(onPressed: _onNext),
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

          // Bottom Native Ad (full-width light grey strip)
          Container(
            width: double.infinity,
            color: const Color(0xFFF7F7F7),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: NativeAdCard(
                  slot: AdSlots.onboarding,
                  height: 300.h,
                  backgroundColor: Colors.transparent,
                  onAdAvailabilityChanged: (available) {
                    // May fire during build (ads disabled) -> defer.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      if (_bmiAdAvailable != available) {
                        setState(() => _bmiAdAvailable = available);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
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
          top: 68.h,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.58,
          child: Image.asset(imagePath, fit: BoxFit.fitHeight),
        ),

        // Title and Subtitle positioned above the bottom controls
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: 126.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32.sp,
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
                style: TextStyle(
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

/// Full-width "Next" button used on pages 2 & 3, animated like the premium
/// screen CTA (pulse, glow, shimmer sweep, arrow nudge, press-down).
class _AnimatedGradientNextButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedGradientNextButton({required this.onPressed});

  @override
  State<_AnimatedGradientNextButton> createState() =>
      _AnimatedGradientNextButtonState();
}

class _AnimatedGradientNextButtonState
    extends State<_AnimatedGradientNextButton> {
  bool _isAnimating = false;

  void _handleTap() {
    if (_isAnimating) return;
    _isAnimating = true;
    widget.onPressed();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCtaButton(
      text: 'Next',
      backgroundImage: AppAssets.btnRectangle,
      borderRadius: BorderRadius.circular(12.r),
      trailingIcon: Image.asset(
        AppAssets.arrowIcon,
        width: 18.w,
        height: 18.w,
        color: Colors.white,
      ),
      onPressed: _handleTap,
    );
  }
}
