import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class BMIResultScreen extends StatelessWidget {
  const BMIResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BMIRecord record =
        Get.arguments as BMIRecord? ??
        BMIRecord(
          id: '0',
          bmiValue: 22.4,
          weightKg: 70.0,
          heightCm: 175.0,
          age: 25,
          gender: 'Male',
          category: BMICategory.normal,
          date: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: CustomAppBar(
        title: 'BMI Result',
        trailing: GestureDetector(
          onTap: () {
            Get.snackbar(
              'Share',
              'Sharing BMI Result (${record.bmiValue})',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primaryTeal,
              colorText: Colors.white,
            );
          },
          child: Container(
            height: 42.w,
            width: 42.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.share,
              size: 18.sp,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Gauge & BMI Result Card
              CustomCard(
                borderRadius: 22.r,
                padding: EdgeInsets.all(18.w),
                child: Column(
                  children: [
                    // Top Right Heart Icon Badge
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F7F2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.heart_circle,
                          color: const Color(0xFF1DB59B),
                          size: 20.sp,
                        ),
                      ),
                    ),

                    // Gauge Widget
                    BMIGaugeWidget(
                      bmiValue: record.bmiValue,
                      size: 200.w,
                      showLabels: true,
                    ),
                    SizedBox(height: 8.h),

                    // BMI Numeric Value
                    Text(
                      record.bmiValue.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1DB59B),
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Status Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        record.category.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: record.category.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Status Feedback Message Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FAF6),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFD4EFE6)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.shield_lefthalf_fill,
                            size: 18.sp,
                            color: const Color(0xFF1DB59B),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              record.category.feedbackMessage,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Your Details Card
              CustomCard(
                borderRadius: 20.r,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailColumn(
                          icon: Icons.scale,
                          iconBg: const Color(0xFFD3F4EA),
                          iconColor: const Color(0xFF0F766E),
                          value: '${record.weightKg.toStringAsFixed(1)} kg',
                          label: 'Weight',
                          showUnderline: true,
                        ),
                        _buildDetailDivider(),
                        _buildDetailColumn(
                          icon: Icons.straighten,
                          iconBg: const Color(0xFFE0F2FE),
                          iconColor: const Color(0xFF0284C7),
                          value: '${record.heightCm.toStringAsFixed(0)} cm',
                          label: 'Height',
                        ),
                        _buildDetailDivider(),
                        _buildDetailColumn(
                          icon: Icons.cake_outlined,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          value: '${record.age} Yrs',
                          label: 'Age',
                        ),
                        _buildDetailDivider(),
                        _buildDetailColumn(
                          icon: Icons.person_outline,
                          iconBg: const Color(0xFFCCFBF1),
                          iconColor: const Color(0xFF0D9488),
                          value: record.gender,
                          label: 'Gender',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Health Advice Card
              CustomCard(
                borderRadius: 20.r,
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Advice',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAdviceBullet(
                                'Eat a balanced diet rich in nutrients.',
                              ),
                              SizedBox(height: 6.h),
                              _buildAdviceBullet(
                                'Stay active for at least 30 minutes daily.',
                              ),
                              SizedBox(height: 6.h),
                              _buildAdviceBullet(
                                'Drink plenty of water and get enough sleep.',
                              ),
                              SizedBox(height: 6.h),
                              _buildAdviceBullet(
                                'Track your progress regularly.',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 54.w,
                          height: 54.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F7F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: const Color(0xFF2FD1A6),
                            size: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Recalculate Button
              CustomGradientButton(
                text: 'Recalculate',
                leadingIcon: Icon(
                  Icons.calculate_outlined,
                  color: Colors.white,
                  size: 20.sp,
                ),
                solidColor: const Color(0xFF1B8A7A),
                onPressed: () => Get.offNamed(AppRoutes.bmiCalculator),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    bool showUnderline = false,
  }) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: showUnderline
                ? const Color(0xFF0284C7)
                : AppColors.textLight,
            decoration: showUnderline ? TextDecoration.underline : null,
            decorationColor: const Color(0xFF0284C7),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailDivider() {
    return Container(height: 38.h, width: 1.w, color: const Color(0xFFF1F5F9));
  }

  Widget _buildAdviceBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(
            CupertinoIcons.checkmark_circle,
            size: 14.sp,
            color: const Color(0xFF1DB59B),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textBody,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
