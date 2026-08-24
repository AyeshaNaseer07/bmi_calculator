import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/custom_gradient_button.dart';

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

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      imagePath: AppAssets.onboarding1,
      titlePrefix: 'BMI ',
      titleHighlight: 'Calculator',
      subtitle: 'Track your BMI, monitor your progress,\nand stay healthy with personalized insights.',
    ),
    OnboardingItem(
      imagePath: AppAssets.onboarding2,
      titlePrefix: 'Weight ',
      titleHighlight: 'Tracking',
      subtitle:
          'Monitor your daily, weekly and monthly\nweight journey effortlessly',
    ),
    OnboardingItem(
      imagePath: AppAssets.onboarding3,
      titlePrefix: 'Health ',
      titleHighlight: 'Insights',
      subtitle:
          'Get personalized insights to build\nhealthier habits every day.',
    ),
  ];

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView for full-bleed artwork & animated title/subtitle
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                children: [
                  // Full background illustration
                  Positioned(
                    left: -5,
                    right: -5,

                    child: Image.asset(slide.imagePath, fit: BoxFit.cover),
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(text: slide.titlePrefix),
                              TextSpan(
                                text: slide.titleHighlight,
                                style: const TextStyle(
                                  color: Color(0xFF24CCA7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 22.h),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Right Skip Button Chip
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: GestureDetector(
                  onTap: _navigateToPaywall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: ShapeDecoration(
                      color: const Color(0x4F33D2AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'skip'.tr,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F6E60),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 15,
                          color: Color(0xFF0F6E60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls: 6 Dots Indicator & Next Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 6-Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFF24CCA7)
                              : const Color(0xFFC7F3EA),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Next Gradient Button
                  CustomGradientButton(
                    text: 'Next',
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
    );
  }
}
