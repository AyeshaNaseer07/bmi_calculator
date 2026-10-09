import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_assets.dart';
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
import '../widgets/manual_input_dialog.dart';
import 'dialogs/calculating_dialog.dart';

class BMICalculatorScreen extends StatelessWidget {
  const BMICalculatorScreen({super.key});

  void _onCalculate(BMIController controller) async {
    // Show Calculating Animation popup
    Get.dialog(const CalculatingDialog(), barrierDismissible: false);

    await Future.delayed(const Duration(milliseconds: 1600));
    await controller.calculateAndSave();
    Get.back(); // close dialog
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final BMIController controller = Get.find<BMIController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'BMI Calculator'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Header: Subtitle & Background Illustration (Non-scrollable)
            SizedBox(
              height: 116.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background Illustration (Calculator background at top right)
                  Positioned(
                    top: -20.h,
                    right: -145.w,
                    child: Image.asset(
                      AppAssets.bmiCalIcon,
                      height: 160.h,
                      fit: BoxFit.contain,
                      alignment: Alignment.topRight,
                    ),
                  ),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        SizedBox(
                          width: 193,
                          child: Text(
                            'Make sure to enter accurate details for precise BMI calculation.',
                            style: TextStyle(
                              color: const Color(0xFF6F6F6F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.38,
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

            // Scrollable Content (Starting from Gender container)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 24.h),
                child: Obx(() {
                  final isMale = controller.selectedGender.value == Gender.male;
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

                  // Slider min/max range labels based on selected units
                  final (minFt, minInches) = BMIService.cmToFeetAndInches(
                    120.0,
                  );
                  final (maxFt, maxInches) = BMIService.cmToFeetAndInches(
                    220.0,
                  );
                  final minHeightText = isCm ? '120 cm' : "$minFt'$minInches\"";
                  final maxHeightText = isCm ? '220 cm' : "$maxFt'$maxInches\"";

                  final minWeightText = isKg
                      ? '30 kg'
                      : '${BMIService.kgToLbs(30.0).round()} lb';
                  final maxWeightText = isKg
                      ? '130 kg'
                      : '${BMIService.kgToLbs(130.0).round()} lb';

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gender cards (avatar + age badge)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildGenderCard(
                                asset: AppAssets.homeMale,
                                label: 'Male',
                                isSelected: isMale,
                                ageText: isMale ? '$age' : null,
                                onTap: () => controller.setGender(Gender.male),
                                onAgeTap: () {
                                  controller.setGender(Gender.male);
                                  controller.toggleAgePicker();
                                },
                              ),
                              _buildGenderCard(
                                asset: AppAssets.homeFemale,
                                label: 'Female',
                                isSelected: isFemale,
                                ageText: isFemale ? '$age' : null,
                                onTap: () =>
                                    controller.setGender(Gender.female),
                                onAgeTap: () {
                                  controller.setGender(Gender.female);
                                  controller.toggleAgePicker();
                                },
                              ),
                            ],
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      heightDisplay,
                                      style: TextStyle(
                                        color: const Color(0xFF08B289),
                                        fontSize: 36.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildEditButton(
                                      onTap: () {
                                        if (isCm) {
                                          ManualInputDialog.show(
                                            title: 'Enter Height',
                                            unitLabel: 'cm',
                                            initialValue: heightCm
                                                .toStringAsFixed(0),
                                            min: 120,
                                            max: 220,
                                            onSubmit:
                                                controller.setHeightFromInput,
                                          );
                                        } else {
                                          final (
                                            ft,
                                            inches,
                                          ) = BMIService.cmToFeetAndInches(
                                            heightCm,
                                          );
                                          ManualInputDialog.showFeetInches(
                                            title: 'Enter Height',
                                            initialFeet: ft,
                                            initialInches: inches,
                                            onSubmit: (feet, inchesVal) {
                                              final cm = BMIService.inchesToCm(
                                                (feet * 12) + inchesVal,
                                              );
                                              controller.setHeightFromInput(cm);
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
                                      borderColor: const Color(0xFF08B289),
                                      elevation: 2,
                                    ),
                                    overlayColor: const Color(0xFF08B289)
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      weightDisplay,
                                      style: TextStyle(
                                        color: const Color(0xFF08B289),
                                        fontSize: 36.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildEditButton(
                                      onTap: () {
                                        if (isKg) {
                                          ManualInputDialog.show(
                                            title: 'Enter Weight',
                                            unitLabel: 'kg',
                                            initialValue: weightKg
                                                .toStringAsFixed(1),
                                            min: 30,
                                            max: 130,
                                            onSubmit:
                                                controller.setWeightFromInput,
                                          );
                                        } else {
                                          final lb = BMIService.kgToLbs(
                                            weightKg,
                                          );
                                          ManualInputDialog.show(
                                            title: 'Enter Weight',
                                            unitLabel: 'lb',
                                            initialValue: lb.toStringAsFixed(1),
                                            min: BMIService.kgToLbs(30),
                                            max: BMIService.kgToLbs(130),
                                            onSubmit: (val) =>
                                                controller.setWeightFromInput(
                                                  BMIService.lbsToKg(val),
                                                ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
                                      borderColor: const Color(0xFF08B289),
                                      elevation: 2,
                                    ),
                                    overlayColor: const Color(0xFF08B289)
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
                          _buildActivitySelector(controller),
                          SizedBox(height: 12.h),
                          // Calculate BMI Button
                          CustomGradientButton(
                            text: 'Calculate BMI',
                            leadingIcon: Image.asset(
                              AppAssets.calcilatorIcon,
                              width: 18.w,
                              height: 18.w,
                            ),
                            solidColor: const Color(0xFF00BD8E),
                            borderRadius: BorderRadius.circular(26.r),
                            height: 48.h,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w700,
                            ),
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
                              color: const Color(0xFF00BD8E),
                            ),
                            isOutlined: true,
                            outlineColor: const Color(0xFF00BD8E),
                            borderRadius: BorderRadius.circular(26.r),
                            height: 48.h,
                            textStyle: TextStyle(
                              color: const Color(0xFF00BD8E),
                              fontSize: 15.sp,
                              fontFamily: 'Instrument Sans',
                              fontWeight: FontWeight.w700,
                            ),
                            onPressed: () => controller.resetInputs(),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                      if (controller.isAgePickerVisible.value)
                        Positioned(
                          top: 85.h,
                          left: 20,
                          right: 0,
                          child: Center(
                            child: AgePickerPopup(
                              currentAge: age,
                              onAgeChanged: (val) => controller.setAge(val),
                              onClose: () => controller.toggleAgePicker(),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Activity level picker — used to personalise the daily calorie target.
  Widget _buildActivitySelector(BMIController controller) {
    final selected = controller.activity.value;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity level',
            style: TextStyle(
              color: const Color(0xFF141B2B),
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            selected.description,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 12.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final level in ActivityLevel.values)
                GestureDetector(
                  onTap: () => controller.setActivity(level),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: level == selected
                          ? const Color(0xFF00BD8E)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      level.title,
                      style: TextStyle(
                        color: level == selected
                            ? Colors.white
                            : const Color(0xFF374151),
                        fontSize: 12.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required String asset,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onAgeTap,
    String? ageText,
  }) {
    const green = Color(0xFF09B389);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 140.w,
        padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFD8F3EC), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2633D2AB),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88.w,
                  height: 88.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? green : const Color(0xFFD1D5DB),
                      width: 2.w,
                    ),
                  ),
                  child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
                ),
                Positioned(
                  right: 0,
                  bottom: 2.h,
                  child: GestureDetector(
                    onTap: onAgeTap,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280),
                  ),
                ),
                if (ageText != null) ...[
                  SizedBox(width: 10.w),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: ageText,
                          style: TextStyle(
                            color: const Color(0xFF09B389),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Yr',
                          style: TextStyle(
                            color: const Color(0xFF09B389),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      color: green,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: const BoxDecoration(
          color: Color(0xFFE6F8F4),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.edit, size: 14.sp, color: const Color(0xFF08B289)),
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
                    ? const Color(0xFF08B289)
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
                    ? const Color(0xFF08B289)
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
