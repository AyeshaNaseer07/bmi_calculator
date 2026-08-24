import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import 'custom_card.dart';

class NativeAdPlaceholder extends StatelessWidget {
  final double? height;

  const NativeAdPlaceholder({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(12.w),
      borderRadius: 18.r,
      backgroundColor: Colors.white,
      borderColor: const Color(0xFFE2E8F0),
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10.r,
          offset: Offset(0, 2.h),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Ad',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.info_circle,
                size: 14.sp,
                color: const Color(0xFF94A3B8),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Content Row
          Row(
            children: [
              // Icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.navigation,
                    color: const Color(0xFF38BDF8),
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Title and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MetroNav Pro',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            size: 11.sp,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '4.9 (12.4k)',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Install Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Install',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            'Smart GPS route planner with real-time alerts. Get instant turn-by-turn navigation.',
            style: TextStyle(
              fontSize: 10.5.sp,
              color: AppColors.textBody,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
