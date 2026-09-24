import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/bmi_service.dart';
import '../widgets/age_picker_popup.dart';
import '../widgets/app_background.dart';
import '../widgets/bordered_slider_thumb_shape.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/mandatory_label.dart';
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'BMI Calculator'),
        body: Stack(
          children: [
            // Background Illustration (Calculator background at top right)
            Positioned(
              top: -24.h,
              right: -6.w,
              child: Image.asset(
                AppAssets.bmiCalIcon,
                height: 170.h,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              ),
            ),

            // Main Screen Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Header: Subtitle (Non-scrollable)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 35.h),
                      Text(
                        'Enter your details below to\ncalculate your Body Mass Index.',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: 14.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.69,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),

                // Scrollable Content (Starting from Gender container)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 18.w,
                      right: 18.w,
                      top: 17.h,
                      bottom: 24.h,
                    ),
                    child: Obx(() {
                      final isMale =
                          controller.selectedGender.value == Gender.male;
                      final isFemale =
                          controller.selectedGender.value == Gender.female;
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
                        final (ft, inches) = BMIService.cmToFeetAndInches(
                          heightCm,
                        );
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

                      // Slider min/max range labels based on selected units
                      final (minFt, minInches) = BMIService.cmToFeetAndInches(
                        120.0,
                      );
                      final (maxFt, maxInches) = BMIService.cmToFeetAndInches(
                        220.0,
                      );
                      final minHeightText = isCm
                          ? '120 cm'
                          : "$minFt'$minInches\"";
                      final maxHeightText = isCm
                          ? '220 cm'
                          : "$maxFt'$maxInches\"";

                      final minWeightText = isKg
                          ? '30 kg'
                          : '${BMIService.kgToLbs(30.0).round()} lb';
                      final maxWeightText = isKg
                          ? '130 kg'
                          : '${BMIService.kgToLbs(130.0).round()} lb';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card 1: Gender
                          CustomCard(
                            padding: EdgeInsets.all(14.w),
                            borderRadius: 18.r,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MandatoryLabel(
                                  text: 'Gender',
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 15.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGenderButton(
                                        iconAsset: AppAssets.iconMale,
                                        label: 'Male',
                                        isSelected: isMale,
                                        onTap: () =>
                                            controller.setGender(Gender.male),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _buildGenderButton(
                                        iconAsset: AppAssets.iconFemale,
                                        label: 'Female',
                                        isSelected: isFemale,
                                        onTap: () =>
                                            controller.setGender(Gender.female),
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
                                MandatoryLabel(
                                  text: 'Age',
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 15.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
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
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppAssets.iconAge,
                                          width: 18.w,
                                          height: 18.w,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            '$age Years',
                                            style: TextStyle(
                                              color: const Color(0xFF111827),
                                              fontSize: 15.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          controller.isAgePickerVisible.value
                                              ? CupertinoIcons.chevron_up
                                              : CupertinoIcons.chevron_down,
                                          size: 16.sp,
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
                                      onAgeChanged: (val) =>
                                          controller.setAge(val),
                                      onClose: () =>
                                          controller.toggleAgePicker(),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MandatoryLabel(
                                      text: 'Height',
                                      style: TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 15.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    _buildUnitToggle(
                                      leftLabel: 'cm',
                                      rightLabel: 'ft',
                                      isLeftSelected: isCm,
                                      onToggle: (val) =>
                                          controller.toggleHeightUnit(val),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  heightDisplay,
                                  style: TextStyle(
                                    color: const Color(0xFF2EC4B6),
                                    fontSize: 36.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF2EC4B6),
                                    inactiveTrackColor: const Color(0xFFE2E8F0),
                                    thumbColor: Colors.white,
                                    thumbShape: BorderedRoundSliderThumbShape(
                                      enabledThumbRadius: 10.r,
                                      borderWidth: 2.5.w,
                                      borderColor: const Color(0xFF2FD1A6),
                                      elevation: 2,
                                    ),
                                    overlayColor: const Color(0xFF2FD1A6)
                                        .withValues(alpha: 0.12),
                                    overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 18.r,
                                    ),
                                    trackHeight: 6.h,
                                  ),
                                  child: Slider(
                                    value: heightCm.clamp(120.0, 220.0),
                                    min: 120.0,
                                    max: 220.0,
                                    onChanged: (val) =>
                                        controller.setHeight(val),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        minHeightText,
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 12.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        maxHeightText,
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 12.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MandatoryLabel(
                                      text: 'Weight',
                                      style: TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 15.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    _buildUnitToggle(
                                      leftLabel: 'kg',
                                      rightLabel: 'lb',
                                      isLeftSelected: isKg,
                                      onToggle: (val) =>
                                          controller.toggleWeightUnit(val),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  weightDisplay,
                                  style: TextStyle(
                                    color: const Color(0xFF2EC4B6),
                                    fontSize: 36.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF2FD1A6),
                                    inactiveTrackColor: const Color(0xFFE2E8F0),
                                    thumbColor: Colors.white,
                                    thumbShape: BorderedRoundSliderThumbShape(
                                      enabledThumbRadius: 10.r,
                                      borderWidth: 2.5.w,
                                      borderColor: const Color(0xFF2FD1A6),
                                      elevation: 2,
                                    ),
                                    overlayColor: const Color(0xFF2FD1A6)
                                        .withValues(alpha: 0.12),
                                    overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 18.r,
                                    ),
                                    trackHeight: 6.h,
                                  ),
                                  child: Slider(
                                    value: weightKg.clamp(30.0, 130.0),
                                    min: 30.0,
                                    max: 130.0,
                                    onChanged: (val) =>
                                        controller.setWeight(val),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        minWeightText,
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 12.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        maxWeightText,
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 12.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
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
                            width: double.infinity,
                            height: 68.h,
                            decoration: ShapeDecoration(
                              color: const Color(0x142EC4B6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0.r),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppAssets.tipIcon,
                                    width: 26.w,
                                    height: 27.w,
                                    color: const Color(0xFF09B389),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'Tip: Make sure to enter accurate details for precise BMI calculation.',
                                      style: TextStyle(
                                        color: const Color(0xFF1D9A8D),
                                        fontSize: 13.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Calculate BMI Button
                          CustomGradientButton(
                            text: 'Calculate BMI',
                            leadingIcon: Image.asset(
                              AppAssets.calcilatorIcon,
                              width: 16.w,
                              height: 16.w,
                            ),
                            backgroundImage: AppAssets.btnRectangle,
                            onPressed:
                                (controller.age.value > 0 &&
                                    controller.heightCm.value > 0 &&
                                    controller.weightKg.value > 0)
                                ? () => _onCalculate(controller)
                                : null,
                          ),
                          SizedBox(height: 10.h),

                          // Reset Button
                          CustomGradientButton(
                            text: 'Reset',
                            leadingIcon: Image.asset(
                              AppAssets.resetIcon,
                              width: 18.w,
                              height: 18.w,
                            ),
                            isOutlined: true,
                            outlineColor: const Color(0xFF2EC4B6),
                            onPressed: () => controller.resetInputs(),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String iconAsset,
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
            Image.asset(
              iconAsset,
              width: 18.w,
              height: 18.w,
              color: isSelected
                  ? const Color(0xFF2EC4B6)
                  : const Color(0xFF6B7280),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2EC4B6)
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
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isLeftSelected
                      ? Colors.white
                      : const Color(0xFF6B7280),
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
