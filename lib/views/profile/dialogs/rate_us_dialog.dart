import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_palette.dart';

class RateUsDialog extends StatefulWidget {
  const RateUsDialog({super.key});

  @override
  State<RateUsDialog> createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<RateUsDialog> {
  int _selectedRating = 5;

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'needs_work'.tr;
      case 2:
        return 'could_be_better'.tr;
      case 3:
        return 'good'.tr;
      case 4:
        return 'great'.tr;
      case 5:
        return 'loved_it'.tr;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: const Color(0xFF33D2AB).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                color: const Color(0xFF09B389),
                size: 32.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'rate_your_experience'.tr,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Instrument Sans',
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'your_rating_helps_us_improve_and'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= _selectedRating;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 36.sp,
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : AppPalette.border,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 8.h),
            Text(
              _getRatingDescription(_selectedRating),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: AppPalette.border),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'maybe_later'.tr,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF09B389),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'thank_you'.tr,
                        'rating_thanks'.trParams({
                          'rating': '$_selectedRating',
                        }),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                        margin: EdgeInsets.all(16.w),
                        borderRadius: 12.r,
                      );
                    },
                    child: Text(
                      'submit'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
