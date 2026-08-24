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
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7F2),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.heart_circle_fill,
                            color: const Color(0xFF2FD1A6),
                            size: 36.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Health Insights',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Add accurate details to receive better insights and track your health journey.',
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
                                        color: AppColors.textLight,
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
                                        borderRadius: BorderRadius.circular(12.r),
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
                                              padding:
                                                  EdgeInsets.symmetric(
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
                          selectedActivity?.title ?? 'Select your activity level',
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
                          color: AppColors.textLight,
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
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Save & Get Insights Button
                CustomGradientButton(
                  text: 'Save & Get Insights',
                  solidColor: const Color(0xFF1B8A7A),
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
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
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
