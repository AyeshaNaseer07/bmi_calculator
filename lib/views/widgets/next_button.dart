import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'animated_cta_button.dart';
import '../../core/constants/app_colors.dart';
import 'cta_arrow_lottie.dart';

class NextButton extends StatefulWidget {
  final VoidCallback onNext;

  const NextButton({required this.onNext, super.key});

  @override
  State<NextButton> createState() => _NextButtonState();
}

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
      text: 'next'.tr,
      width: 112.w,
      height: 42.h,
      borderRadius: BorderRadius.circular(24.r),
      gradient: AppColors.ctaGradient,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w800,
      ),
      alignTrailingToEnd: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      trailingIcon: CtaArrowLottie(size: 26.w),
      onPressed: _handleTap,
    );
  }
}
