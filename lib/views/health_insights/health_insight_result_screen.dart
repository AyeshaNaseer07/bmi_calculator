import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/health_insight_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/bmi_service.dart';
import '../widgets/app_background.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_app_bar.dart';

class HealthInsightResultScreen extends StatelessWidget {
  const HealthInsightResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthInsightController controller =
        Get.find<HealthInsightController>();

    final weight =
        double.tryParse(controller.weightController.text.trim()) ?? 70.0;
    final height =
        double.tryParse(controller.heightController.text.trim()) ?? 175.0;
    final bmi = BMIService.calculateBMI(weightKg: weight, heightCm: height);
    final category = BMIService.getCategory(bmi);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Health Insight'),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Understand Your Health Card
                Container(
                  width: double.infinity,
                  height: 187.h,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF33D2AB).withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.25,
                        color: Color(0xFF33D2AB),
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3A33D2AB).withValues(alpha: 0.05),
                        blurRadius: 6.80,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Column(
                      children: [
                        Text(
                          'Understand your health better every day.',
                          style: TextStyle(
                            color: const Color(0xFF111827)
                                .withValues(alpha: 0.64),
                            fontSize: 13.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your BMI',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 14.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    bmi.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: category.color,
                                      fontSize: 32.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    category.label,
                                    style: TextStyle(
                                      color: category.color,
                                      fontSize: 14.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    category.bmiRangeDescription,
                                    style: TextStyle(
                                      color: const Color(0xFF111827)
                                          .withValues(alpha: 0.64),
                                      fontSize: 10.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            BMIGaugeWidget(
                              bmiValue: bmi,
                              size: 150.w,
                              showLabels: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Health Summary Section
                Text(
                  'Health Summary',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        imagePath: AppAssets.healthWeight,
                        label: 'Weight',
                        value: '${weight.toStringAsFixed(1)}kg',
                        valueColor: const Color(0xFF09B389),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildSummaryCard(
                        imagePath: AppAssets.healthHeight,
                        label: 'Height',
                        value: '${height.toStringAsFixed(0)}cm',
                        valueColor: const Color(0xFF09B389),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildSummaryCard(
                        imagePath: AppAssets.lastUpdated,
                        label: 'Last Updated',
                        value: 'Today',
                        valueColor: const Color(0xFF09B389),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // What It Means Section
                Text(
                  'What It Means',
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: 14.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFD4EFE6)),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAssets.happyHealth,
                        fit: BoxFit.contain,
                        height: 42.h,
                        width: 42.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "You're doing great!",
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 11.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              category.feedbackMessage,
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 10.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Tips For You Section
                Text(
                  'Tips For You',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildTipItem(
                  imagePath: AppAssets.veryActiveIcon,
                  title: 'Stay Active',
                  description: '30 minutes of exercise daily can improve your overall health.',
                ),
                SizedBox(height: 10.h),
                _buildTipItem(
                  imagePath: AppAssets.eatHealthy,
                  title: 'Eat Healthy',
                  description: 'Choose balanced meals with more fruits, vegetables and whole grains.',
                ),
                SizedBox(height: 10.h),
                _buildTipItem(
                  imagePath: AppAssets.stayHydrated,
                  title: 'Stay Hydrated',
                  description: 'Drink enough water throughout the day to keep your body functioning well.',
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String imagePath,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD4EFE6)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.contain,
            height: 42.h,
            width: 42.w,
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF111827),
              fontSize: 10.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF33D2AB),
              fontSize: 12.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD4EFE6)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.contain,
            height: 42.h,
            width: 42.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: 11.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: 10.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
