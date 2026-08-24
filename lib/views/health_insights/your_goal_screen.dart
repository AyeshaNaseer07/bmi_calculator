import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/health_insight_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient_button.dart';

class YourGoalScreen extends StatelessWidget {
  const YourGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthInsightController controller =
        Get.find<HealthInsightController>();

    final List<(HealthGoal goal, IconData icon, String title, String desc)>
    goals = [
      (
        HealthGoal.loseWeight,
        Icons.scale_outlined,
        'Lose Weight',
        'I want to lose weight and improve my health.',
      ),
      (
        HealthGoal.buildMuscle,
        Icons.balance_outlined,
        'Build Muscle',
        'I want to build muscle and gain strength.',
      ),
      (
        HealthGoal.maintainWeight,
        Icons.favorite_outline,
        'Maintain Weight',
        'I want to maintain my current weight and stay healthy.',
      ),
      (
        HealthGoal.improveHealth,
        Icons.fitness_center_outlined,
        'Improve Health',
        'I want to improve my overall health and wellness.',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Your Goal'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Obx(() {
            final selected = controller.selectedGoal.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F2),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.heart_circle,
                        color: const Color(0xFF1DB59B),
                        size: 32.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Choose your main goal so we can personalize your experience.',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F766E),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Goal Option Cards
                ...goals.map((item) {
                  final isSelected = selected == item.$1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
                      onTap: () => controller.setGoal(item.$1),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F7F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.$2,
                                color: const Color(0xFF1DB59B),
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$3,
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item.$4,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.textBody,
                                      height: 1.3,
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
                SizedBox(height: 20.h),

                // Continue Button
                CustomGradientButton(
                  text: 'Continue',
                  solidColor: const Color(0xFF1B8A7A),
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
