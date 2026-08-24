import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/health_insight_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/bmi_service.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Health Insight'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Understand Your Health Card
              CustomCard(
                borderRadius: 22.r,
                padding: EdgeInsets.all(18.w),
                child: Column(
                  children: [
                    Text(
                      'Understand your health better every day.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your BMI',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              bmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1DB59B),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              category.label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: category.color,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Great! You are in a healthy\nBMI range.',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: AppColors.textLight,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
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
              SizedBox(height: 16.h),

              // Health Summary Section
              Text(
                'Health Summary',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.scale_outlined,
                      label: 'Weight',
                      value: '${weight.toStringAsFixed(1)}kg',
                      valueColor: const Color(0xFF1DB59B),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.accessibility_new,
                      label: 'Height',
                      value: '${height.toStringAsFixed(0)}cm',
                      valueColor: const Color(0xFF1DB59B),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Last Updated',
                      value: 'Today',
                      valueColor: const Color(0xFF1DB59B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // What It Means Section
              Text(
                'What It Means',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
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
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F7F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.smiley,
                        color: const Color(0xFF1DB59B),
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You're doing great!",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Your BMI is in the normal range. Keep maintaining a healthy lifestyle.',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.textBody,
                              height: 1.3,
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
                icon: Icons.directions_run,
                title: 'Stay Active',
                description: '30 minutes of exercise daily can improve your overall health.',
              ),
              SizedBox(height: 10.h),
              _buildTipItem(
                icon: Icons.restaurant_outlined,
                title: 'Eat Healthy',
                description: 'Choose balanced meals with more fruits, vegetables and whole grains.',
              ),
              SizedBox(height: 10.h),
              _buildTipItem(
                icon: Icons.water_drop_outlined,
                title: 'Stay Hydrated',
                description: 'Drink enough water throughout the day to keep your body functioning well.',
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
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
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: const Color(0xFF1DB59B)),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
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
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1DB59B), size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textBody,
                    height: 1.3,
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
