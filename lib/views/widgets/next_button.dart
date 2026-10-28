import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import 'animated_cta_button.dart';

class NextButton extends StatefulWidget {
  final VoidCallback onNext;

  const NextButton({required this.onNext, super.key});

  @override
  State<NextButton> createState() => _NextButtonState();
}

/// Compact "Next" pill, animated like the premium screen CTA (pulse, glow,
/// shimmer sweep, arrow nudge, press-down).
class _NextButtonState extends State<NextButton> {
  bool _isNavigating = false;

  void _handleTap() {
    if (_isNavigating) return;
    _isNavigating = true;
    widget.onNext();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCtaButton(
      text: 'Next',
      width: 112.w,
      height: 42.h,
      borderRadius: BorderRadius.circular(24.r),
      gradient: const LinearGradient(
        colors: [Color(0xFF24CCA7), Color(0xFF168EE2)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w800,
      ),
      // Keep text and arrow together (the pill is too narrow for the
      // full-width layout that pins the arrow to the right edge).
      alignTrailingToEnd: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
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
