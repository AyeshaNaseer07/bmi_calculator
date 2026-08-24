import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

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
        color: const Color(0xFFF1F5F5),
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
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Icon(
                  CupertinoIcons.xmark,
                  size: 14.sp,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Your age helps calculate your BMI accurately.',
            style: AppTypography.bodySmall.copyWith(
              fontSize: 10.sp,
              color: AppColors.textBody,
              height: 1.2,
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
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    size: 14.sp,
                    color: AppColors.textDark,
                  ),
                ),
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
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTeal,
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
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    size: 14.sp,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
