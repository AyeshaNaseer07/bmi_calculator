import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/bmi_service.dart';
import '../widgets/age_picker_popup.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import 'dialogs/calculating_dialog.dart';

class BMICalculatorScreen extends StatelessWidget {
  const BMICalculatorScreen({super.key});

  void _onCalculate(BMIController controller) async {
    // Show Calculating Animation popup
    Get.dialog(const CalculatingDialog(), barrierDismissible: false);

    await Future.delayed(const Duration(milliseconds: 1600));
    final record = await controller.calculateAndSave();
    Get.back(); // close dialog
    Get.toNamed(AppRoutes.bmiResult, arguments: record);
  }

  @override
  Widget build(BuildContext context) {
    final BMIController controller = Get.find<BMIController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'BMI Calculator'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Obx(() {
            final isMale = controller.selectedGender.value == Gender.male;
            final isFemale = controller.selectedGender.value == Gender.female;
            final age = controller.age.value;
            final heightCm = controller.heightCm.value;
            final weightKg = controller.weightKg.value;
            final isCm = controller.isCm.value;
            final isKg = controller.isKg.value;

            // Height display text
            String heightDisplay;
            if (isCm) {
              heightDisplay = '${heightCm.toStringAsFixed(0)} cm';
            } else {
              final (ft, inches) = BMIService.cmToFeetAndInches(heightCm);
              heightDisplay = "$ft'$inches\"";
            }

            // Weight display text
            String weightDisplay;
            if (isKg) {
              weightDisplay = '${weightKg.toStringAsFixed(1)} kg';
            } else {
              final lb = BMIService.kgToLbs(weightKg);
              weightDisplay = '${lb.toStringAsFixed(1)} lb';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner: Subtitle & 3D Calculator illustration
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Enter your details below to\ncalculate your Body Mass Index.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textBody,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      width: 54.w,
                      height: 54.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.calculate,
                          size: 34.sp,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Card 1: Gender
                CustomCard(
                  padding: EdgeInsets.all(14.w),
                  borderRadius: 18.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderButton(
                              icon: Icons.person_outline,
                              label: 'Male',
                              isSelected: isMale,
                              onTap: () => controller.setGender(Gender.male),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildGenderButton(
                              icon: Icons.person_outline,
                              label: 'Female',
                              isSelected: isFemale,
                              onTap: () => controller.setGender(Gender.female),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Card 2: Age (with interactive tooltip stepper)
                CustomCard(
                  padding: EdgeInsets.all(14.w),
                  borderRadius: 18.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () => controller.toggleAgePicker(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                size: 18.sp,
                                color: AppColors.textBody,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  '$age Years',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              Icon(
                                controller.isAgePickerVisible.value
                                    ? CupertinoIcons.chevron_up
                                    : CupertinoIcons.chevron_down,
                                size: 14.sp,
                                color: AppColors.textLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.isAgePickerVisible.value) ...[
                        SizedBox(height: 10.h),
                        Center(
                          child: AgePickerPopup(
                            currentAge: age,
                            onAgeChanged: (val) => controller.setAge(val),
                            onClose: () => controller.toggleAgePicker(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Card 3: Height Slider
                CustomCard(
                  padding: EdgeInsets.all(14.w),
                  borderRadius: 18.r,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Height',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          _buildUnitToggle(
                            leftLabel: 'cm',
                            rightLabel: 'ft',
                            isLeftSelected: isCm,
                            onToggle: (val) => controller.toggleHeightUnit(val),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        heightDisplay,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1DB59B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF2FD1A6),
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: Colors.white,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 10.r,
                            elevation: 2,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 18.r,
                          ),
                          trackHeight: 6.h,
                        ),
                        child: Slider(
                          value: heightCm.clamp(120.0, 220.0),
                          min: 120.0,
                          max: 220.0,
                          onChanged: (val) => controller.setHeight(val),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '120 cm',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              '220 cm',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Card 4: Weight Slider
                CustomCard(
                  padding: EdgeInsets.all(14.w),
                  borderRadius: 18.r,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weight',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          _buildUnitToggle(
                            leftLabel: 'kg',
                            rightLabel: 'lb',
                            isLeftSelected: isKg,
                            onToggle: (val) => controller.toggleWeightUnit(val),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        weightDisplay,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1DB59B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF2FD1A6),
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: Colors.white,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 10.r,
                            elevation: 2,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 18.r,
                          ),
                          trackHeight: 6.h,
                        ),
                        child: Slider(
                          value: weightKg.clamp(30.0, 130.0),
                          min: 30.0,
                          max: 130.0,
                          onChanged: (val) => controller.setWeight(val),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '30 kg',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              '130 kg',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Tip Banner
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF6),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFD4EFE6)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb,
                        size: 18.sp,
                        color: const Color(0xFF1DB59B),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Tip: Make sure to enter accurate details for precise BMI calculation.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF0F766E),
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Calculate BMI Button
                CustomGradientButton(
                  text: 'Calculate BMI',
                  leadingIcon: Icon(
                    Icons.calculate_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  solidColor: const Color(0xFF1B8A7A),
                  onPressed: () => _onCalculate(controller),
                ),
                SizedBox(height: 10.h),

                // Reset Button
                CustomGradientButton(
                  text: 'Reset',
                  leadingIcon: Icon(
                    Icons.refresh,
                    color: const Color(0xFF1DB59B),
                    size: 18.sp,
                  ),
                  isOutlined: true,
                  outlineColor: const Color(0xFF1DB59B),
                  onPressed: () => controller.resetInputs(),
                ),
                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2FD1A6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5.w : 1.0.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? const Color(0xFF1DB59B) : AppColors.textBody,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1DB59B)
                    : AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle({
    required String leftLabel,
    required String rightLabel,
    required bool isLeftSelected,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onToggle(true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isLeftSelected
                    ? const Color(0xFF2FD1A6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                leftLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isLeftSelected
                      ? Colors.white
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: !isLeftSelected
                    ? const Color(0xFF2FD1A6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                rightLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: !isLeftSelected
                      ? Colors.white
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
