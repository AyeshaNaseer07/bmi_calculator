import 'package:bmi_calculator/core/constants/app_assets.dart';
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
          child: Image.asset(AppAssets.settingicon, height: 34.h, width: 34.w),
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
                      child: Image.asset(
                        AppAssets.hearticon,
                        height: 41.h,
                        width: 41.w,
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
                        color: const Color(0xFF33D2AB),
                        fontSize: 32,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Your BMI',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Status Pill
                    Container(
                      width: 61,
                      height: 26,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF33D2AB).withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          record.category.label,
                          style: TextStyle(
                            color: const Color(0xFF07A981),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Status Feedback Message Card
                    Container(
                      width: 329,
                      height: 54,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE8F9F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.asset(
                              AppAssets.shieldicon,
                              width: 19.w,
                              height: 19.h,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                record.category.feedbackMessage,
                                style: TextStyle(
                                  color: const Color(0xFF1E2D2F),
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailColumn(
                          imageAsset: AppAssets.weighticon,
                          value: '${record.weightKg.toStringAsFixed(1)} kg',
                          label: 'Weight',
                          showUnderline: true,
                        ),
                        _buildDetailDivider(),
                        _buildDetailColumn(
                          imageAsset: AppAssets.heighticon,
                          value: '${record.heightCm.toStringAsFixed(0)} cm',
                          label: 'Height',
                        ),
                        _buildDetailDivider(),
                        _buildDetailColumn(
                          imageAsset: AppAssets.ageicon,
                          value: '${record.age} Yrs',
                          label: 'Age',
                        ),
                        _buildDetailDivider(),
                        _buildDetailColumn(
                          imageAsset: AppAssets.gendericon,
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
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
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
                        Image.asset(
                          AppAssets.bmiHearticon,
                          height: 77.h,
                          width: 77.w,
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
                leadingIcon: Image.asset(
                  AppAssets.calcilatorIcon,
                  width: 16.w,
                  height: 16.w,
                ),
                backgroundImage: AppAssets.calculateButton,
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
    required String imageAsset,
    required String value,
    required String label,
    bool showUnderline = false,
  }) {
    return Column(
      children: [
        Image.asset(imageAsset, width: 39.w, height: 39.w),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1E2D2F),
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: showUnderline
                ? const Color(0xFF0284C7)
                : AppColors.textLight,
            decoration: showUnderline ? TextDecoration.underline : null,
            decorationColor: const Color(0xFF0284C7),
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
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
          child: Image.asset(AppAssets.preDown, height: 11.h, width: 11.w),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF647E80),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
