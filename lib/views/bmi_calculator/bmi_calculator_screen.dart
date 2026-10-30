import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/bmi_service.dart';
import '../widgets/ads/interstitial_ad_manager.dart';
import '../widgets/app_background.dart';
import '../widgets/bordered_slider_thumb_shape.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/mandatory_label.dart';
import 'dialogs/calculating_dialog.dart';
import 'widgets/inline_value_field.dart';
import '../widgets/number_keypad.dart';
import '../../core/theme/app_palette.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  @override
  void initState() {
    super.initState();
    InterstitialAdManager.instance.load(InterstitialPlacement.calculator);
  }

  void _onCalculate(BMIController controller) async {
    // Show Calculating Animation popup
    Get.dialog(const CalculatingDialog(), barrierDismissible: false);

    await Future.delayed(const Duration(milliseconds: 1600));
    await controller.calculateAndSave();
    Get.back(); // close dialog
    InterstitialAdManager.instance.show(
      InterstitialPlacement.calculator,
      onDone: () => Get.offAllNamed(AppRoutes.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BMIController controller = Get.find<BMIController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'BMI Calculator'),
        // Number keypad for the value fields (iOS), shown while editing.
        bottomNavigationBar: const NumberKeypadHost(),
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

                  final hasHeight = controller.hasHeight;
                  final hasWeight = controller.hasWeight;
                  final (curFt, curIn) = BMIService.cmToFeetAndInches(heightCm);

                  // Slider min/max range labels based on selected units
                  final (minFt, minInches) = BMIService.cmToFeetAndInches(
                    120.0,
                  );
                  final (maxFt, maxInches) = BMIService.cmToFeetAndInches(
                    220.0,
                  );
                  final minHeightText = isCm
                      ? '120 cm'
                      : '$minFt ft $minInches in';
                  final maxHeightText = isCm
                      ? '220 cm'
                      : '$maxFt ft $maxInches in';

                  final minWeightText = isKg
                      ? '30 kg'
                      : '${BMIService.kgToLbs(30.0).round()} lb';
                  final maxWeightText = isKg
                      ? '130 kg'
                      : '${BMIService.kgToLbs(130.0).round()} lb';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderCard(
                              asset: AppAssets.homeMale,
                              label: 'Male',
                              isSelected: isMale,
                              onTap: () => controller.setGender(Gender.male),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildGenderCard(
                              asset: AppAssets.homeFemale,
                              label: 'Female',
                              isSelected: isFemale,
                              onTap: () => controller.setGender(Gender.female),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Age, edited the same way as height and weight.
                      CustomCard(
                        padding: EdgeInsets.all(14.w),
                        borderRadius: 18.r,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: MandatoryLabel(
                                text: 'Age',
                                style: TextStyle(
                                  color: AppPalette.textPrimary,
                                  fontSize: 15.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            InlineValueField(
                              key: const ValueKey('age'),
                              value: controller.hasAge ? age.toDouble() : null,
                              unit: 'Yr',
                              min: BMIController.minAge.toDouble(),
                              max: BMIController.maxAge.toDouble(),
                              width: 70,
                              showEdit: true,
                              onChanged: (v) => controller.setAge(v.round()),
                              onCommitted: (v) => controller.setAge(v.round()),
                            ),
                            SizedBox(height: 4.h),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF2EC4B6),
                                inactiveTrackColor: AppPalette.border,
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
                                value: controller.hasAge
                                    ? age.toDouble()
                                    : BMIController.minAge.toDouble(),
                                min: BMIController.minAge.toDouble(),
                                max: BMIController.maxAge.toDouble(),
                                onChanged: (val) =>
                                    controller.setAge(val.round()),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${BMIController.minAge} Yr',
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${BMIController.maxAge} Yr',
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
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

                      // Card 3: Height Slider
                      CustomCard(
                        padding: EdgeInsets.all(14.w),
                        borderRadius: 18.r,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MandatoryLabel(
                                  text: 'Height',
                                  style: TextStyle(
                                    color: AppPalette.textPrimary,
                                    fontSize: 15.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                _buildUnitToggle(
                                  leftLabel: 'cm',
                                  rightLabel: 'ft/in',
                                  isLeftSelected: isCm,
                                  onToggle: (val) =>
                                      controller.toggleHeightUnit(val),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            // Edited in place (underlined) — no dialog.
                            isCm
                                ? InlineValueField(
                                    key: const ValueKey('h_cm'),
                                    value: hasHeight ? heightCm : null,
                                    unit: 'cm',
                                    min: 120,
                                    max: 220,
                                    showEdit: true,
                                    onChanged: controller.setHeight,
                                    onCommitted: controller.setHeightFromInput,
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InlineValueField(
                                        key: const ValueKey('h_ft'),
                                        value: hasHeight
                                            ? curFt.toDouble()
                                            : null,
                                        unit: 'ft',
                                        min: 3,
                                        max: 7,
                                        width: 44,
                                        hint: '0',
                                        onCommitted: (f) =>
                                            controller.setHeightFromInput(
                                              BMIService.inchesToCm(
                                                f * 12 +
                                                    (hasHeight ? curIn : 0),
                                              ),
                                            ),
                                      ),
                                      SizedBox(width: 10.w),
                                      InlineValueField(
                                        key: const ValueKey('h_in'),
                                        value: hasHeight
                                            ? curIn.toDouble()
                                            : null,
                                        unit: 'in',
                                        min: 0,
                                        max: 11,
                                        width: 52,
                                        showEdit: true,
                                        onCommitted: (i) =>
                                            controller.setHeightFromInput(
                                              BMIService.inchesToCm(
                                                (hasHeight ? curFt : 5) * 12 +
                                                    i,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                            SizedBox(height: 4.h),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF2EC4B6),
                                inactiveTrackColor: AppPalette.border,
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
                                value: hasHeight
                                    ? heightCm.clamp(120.0, 220.0)
                                    : 120.0,
                                min: 120.0,
                                max: 220.0,
                                onChanged: (val) => controller.setHeight(
                                  isCm
                                      ? val.roundToDouble()
                                      : BMIService.inchesToCm(
                                          (val / 2.54).roundToDouble(),
                                        ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    minHeightText,
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    maxHeightText,
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MandatoryLabel(
                                  text: 'Weight',
                                  style: TextStyle(
                                    color: AppPalette.textPrimary,
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
                            isKg
                                ? InlineValueField(
                                    key: const ValueKey('w_kg'),
                                    value: hasWeight ? weightKg : null,
                                    unit: 'kg',
                                    decimals: 1,
                                    min: 30,
                                    max: 130,
                                    width: 110,
                                    showEdit: true,
                                    onChanged: controller.setWeight,
                                    onCommitted: controller.setWeightFromInput,
                                  )
                                : InlineValueField(
                                    key: const ValueKey('w_lb'),
                                    value: hasWeight
                                        ? BMIService.kgToLbs(weightKg)
                                        : null,
                                    unit: 'lb',
                                    decimals: 1,
                                    min: BMIService.kgToLbs(30),
                                    max: BMIService.kgToLbs(130),
                                    width: 110,
                                    showEdit: true,
                                    onCommitted: (v) =>
                                        controller.setWeightFromInput(
                                          BMIService.lbsToKg(v),
                                        ),
                                  ),
                            SizedBox(height: 4.h),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF2FD1A6),
                                inactiveTrackColor: AppPalette.border,
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
                                value: hasWeight
                                    ? weightKg.clamp(30.0, 130.0)
                                    : 30.0,
                                min: 30.0,
                                max: 130.0,
                                onChanged: (val) => controller.setWeight(val),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    minWeightText,
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    maxWeightText,
                                    style: TextStyle(
                                      color: AppPalette.textSecondary,
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
                      SizedBox(height: 16.h),
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
                        onPressed: controller.canCalculate
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
                      // GestureDetector(
                      //   onTap: () {
                      //     AppLovinMAX.showMediationDebugger();
                      //   },
                      //   child: Text("show debuger"),
                      // ),
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

  Widget _buildGenderCard({
    required String asset,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const green = Color(0xFF09B389);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF8FE3C9) : AppPalette.mintBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalette.shadow(const Color(0x2633D2AB)),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? green : AppPalette.border,
                  width: 2.w,
                ),
              ),
              child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppPalette.textPrimary
                    : AppPalette.textSecondary,
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
        color: AppPalette.surfaceMuted,
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
                      : AppPalette.textSecondary,
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
                      : AppPalette.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
