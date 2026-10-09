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
      height: 95.h,
      width: 135.w,
      padding: EdgeInsets.all(6.w),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Your Age',
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Your age helps calculate your BMI accurately.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 7,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left Arrow
              GestureDetector(
                onTap: () {
                  if (currentAge > 1) onAgeChanged(currentAge - 1);
                },
                child: Image.asset(
                  AppAssets.ageBack,
                  height: 16.h,
                  width: 16.w,
                ),
              ),
              // Previous age
              Text(
                '${currentAge > 1 ? currentAge - 1 : ''}',
                style: TextStyle(
                  color: const Color(0xFFDFDFDF),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Selected age (large teal)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                child: Text(
                  '$currentAge',
                  style: TextStyle(
                    color: const Color(0xFF09B389),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Next age
              Text(
                '${currentAge < 120 ? currentAge + 1 : ''}',
                style: TextStyle(
                  color: const Color(0xFFDFDFDF),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Right Arrow
              GestureDetector(
                onTap: () {
                  if (currentAge < 120) onAgeChanged(currentAge + 1);
                },
                child: Image.asset(
                  AppAssets.ageForward,
                  height: 16.h,
                  width: 16.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
