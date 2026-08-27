import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/health_insight_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient_button.dart';

class ActivityLevelScreen extends StatelessWidget {
  const ActivityLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthInsightController controller =
        Get.find<HealthInsightController>();

    final List<
      (ActivityLevel level, String assetPath, String title, String desc)
    >
    levels = [
      (
        ActivityLevel.sedentary,
        AppAssets.sedentaryIcon,
        'Sedentary',
        'Little or no exercise. Desk job or spending most of the day sitting.',
      ),
      (
        ActivityLevel.lightlyActive,
        AppAssets.lightActiveIcon,
        'Lightly Active',
        'Light exercise or sports 1-3 days per week.',
      ),
      (
        ActivityLevel.moderatelyActive,
        AppAssets.moderateActiveIcon,
        'Moderately Active',
        'Moderate exercise or sports 3-5 days per week.',
      ),
      (
        ActivityLevel.veryActive,
        AppAssets.veryActiveIcon,
        'Very Active',
        'Hard exercise or sports 6-7 days per week.',
      ),
      (
        ActivityLevel.extraActive,
        AppAssets.extraActiveIcon,
        'Extra Active',
        'Very hard exercise, physical job or training twice a day',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Activity Level'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Obx(() {
            final selected = controller.selectedActivity.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9FAF5),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.bmiHearticon,
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          'Select your daily activity level\nto get better insights.',
                          style: TextStyle(
                            color: const Color(0xFF4B5563),
                            fontSize: 14.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Option Cards
                ...levels.map((item) {
                  final isSelected = selected == item.$1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
                      onTap: () => controller.setActivity(item.$1),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2FD1A6)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5.w : 1.0.w,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              item.$2,
                              width: 46.w,
                              height: 46.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$3,
                                    style: TextStyle(
                                      color: const Color(0xFF111827),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item.$4,
                                    style: TextStyle(
                                      color: const Color(0xFF111827)
                                          .withOpacity(0.64),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF2FD1A6)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2FD1A6)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5.w,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 12.sp,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 16.h),

                // Continue Button
                CustomGradientButton(
                  text: 'Continue',
                  backgroundImage: AppAssets.calculateButton,
                  onPressed: () => Get.back(),
                ),
                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }
}
