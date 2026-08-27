import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgePickerPopup extends StatelessWidget {
  final int currentAge;
  final ValueChanged<int> onAgeChanged;
  final VoidCallback onClose;

  const AgePickerPopup({
    super.key,
    required this.currentAge,
    required this.onAgeChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Age',
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Your age helps calculate your BMI\naccurately.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left Arrow
              GestureDetector(
                onTap: () {
                  if (currentAge > 1) onAgeChanged(currentAge - 1);
                },
                child: Image.asset(AppAssets.ageBack, height: 24, width: 24),
              ),
              // Previous age
              Text(
                '${currentAge > 1 ? currentAge - 1 : ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB0BEC5),
                ),
              ),
              // Selected age (large teal)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                child: Text(
                  '$currentAge',
                  style: TextStyle(
                    color: const Color(0xFF33D2AB),
                    fontSize: 48,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Next age
              Text(
                '${currentAge < 120 ? currentAge + 1 : ''}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB0BEC5),
                ),
              ),
              // Right Arrow
              GestureDetector(
                onTap: () {
                  if (currentAge < 120) onAgeChanged(currentAge + 1);
                },
                child: Image.asset(AppAssets.ageForward, height: 24, width: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
