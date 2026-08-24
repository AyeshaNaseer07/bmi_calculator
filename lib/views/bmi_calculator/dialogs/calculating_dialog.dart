import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class CalculatingDialog extends StatelessWidget {
  const CalculatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Center(
        child: Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.loadingGaugeGif,
                width: 90.w,
                height: 90.w,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTealLight),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Calculating...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
