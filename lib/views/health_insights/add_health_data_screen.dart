import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/health_insight_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class AddHealthDataScreen extends StatefulWidget {
  const AddHealthDataScreen({super.key});

  @override
  State<AddHealthDataScreen> createState() => _AddHealthDataScreenState();
}

class _AddHealthDataScreenState extends State<AddHealthDataScreen> {
  final HealthInsightController _controller =
      Get.find<HealthInsightController>();
  bool _isGenderMenuOpen = false;

  void _onSave() async {
    await _controller.saveProfileAndInsights();
    Get.toNamed(AppRoutes.healthInsightResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Add My Data'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Obx(() {
            final selectedGender = _controller.selectedGender.value;
            final selectedActivity = _controller.selectedActivity.value;
            final selectedGoal = _controller.selectedGoal.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Insights Intro Card
                CustomCard(
                  borderRadius: 20.r,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 98.w,
                        height: 98.h,
                        child: OverflowBox(
                          maxWidth: 190.w,
                          maxHeight: 190.h,
                          child: Image.asset(
                            AppAssets.addDataicon,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Your Health Insights',
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Add accurate details to receive\nbetter insights and track your\nhealth journey.',
                              style: TextStyle(
                                color: const Color(0xFF4B5563),
                                fontSize: 12.5.sp,
                                height: 1.35,
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

                // Full Name
                _buildFieldLabel('Full Name'),
                _buildTextInput(
                  controller: _controller.fullNameController,
                  hint: 'Enter your full name',
                ),
                SizedBox(height: 12.h),

                // Age
                _buildFieldLabel('Age'),
                _buildTextInput(
                  controller: _controller.ageController,
                  hint: 'Enter age',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),

                // Gender & Height Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gender Dropdown
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Gender'),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: () => setState(
                                  () => _isGenderMenuOpen = !_isGenderMenuOpen,
                                ),
                                child: Container(
                                  height: 48.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: const Color(0xFFD4EFE6),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedGender?.displayName ?? 'Select',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: selectedGender != null
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: selectedGender != null
                                              ? AppColors.textDark
                                              : AppColors.textLight,
                                        ),
                                      ),
                                      Icon(
                                        CupertinoIcons.chevron_down,
                                        size: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Gender Dropdown Menu
                              if (_isGenderMenuOpen)
                                Positioned(
                                  top: 52.h,
                                  left: 0,
                                  right: 0,
                                  child: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: const Color(0xFFF0FAF6),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FAF6),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFD4EFE6),
                                        ),
                                      ),
                                      child: Column(
                                        children: Gender.values.map((g) {
                                          return GestureDetector(
                                            onTap: () {
                                              _controller.setGender(g);
                                              setState(
                                                () => _isGenderMenuOpen = false,
                                              );
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.h,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  g.displayName,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Height
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Height'),
                          _buildTextInput(
                            controller: _controller.heightController,
                            hint: 'Enter height',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Weight
                _buildFieldLabel('Weight'),
                _buildTextInput(
                  controller: _controller.weightController,
                  hint: 'Enter Weight',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: 12.h),

                // Activity Level Selector Button
                _buildFieldLabel('Activity Level'),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.activityLevel),
                  child: Container(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFD4EFE6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedActivity?.title ??
                              'Select your activity level',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: selectedActivity != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedActivity != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 14.sp,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Goal Selector Button
                _buildFieldLabel('Goal'),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.yourGoal),
                  child: Container(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFD4EFE6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedGoal?.title ?? 'Select your goal',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: selectedGoal != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedGoal != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 14.sp,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Save & Get Insights Button
                CustomGradientButton(
                  text: 'Save & Get Insights',
                  backgroundImage: AppAssets.calculateButton,
                  onPressed: _onSave,
                ),
                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD4EFE6)),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}
