import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:bmi_calculator/data/models/user_profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/health_insight_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/gender_popup_menu.dart';
import '../widgets/mandatory_label.dart';

class AddHealthDataScreen extends StatefulWidget {
  const AddHealthDataScreen({super.key});

  @override
  State<AddHealthDataScreen> createState() => _AddHealthDataScreenState();
}

class _AddHealthDataScreenState extends State<AddHealthDataScreen> {
  final HealthInsightController _controller =
      Get.find<HealthInsightController>();
  bool _isGenderMenuOpen = false;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.fullNameController.addListener(_onTextChanged);
    _controller.ageController.addListener(_onTextChanged);
    _controller.heightController.addListener(_onTextChanged);
    _controller.weightController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    _controller.fullNameController.removeListener(_onTextChanged);
    _controller.ageController.removeListener(_onTextChanged);
    _controller.heightController.removeListener(_onTextChanged);
    _controller.weightController.removeListener(_onTextChanged);
    super.dispose();
  }

  bool get _isFormValid {
    final name = _controller.fullNameController.text.trim();
    final ageText = _controller.ageController.text.trim();
    final heightText = _controller.heightController.text.trim();
    final weightText = _controller.weightController.text.trim();

    final isNameValid = name.isNotEmpty;
    final isAgeValid = ageText.isNotEmpty && (int.tryParse(ageText) ?? 0) > 0;
    final isGenderValid = _controller.selectedGender.value != null;
    final isHeightValid =
        heightText.isNotEmpty && (double.tryParse(heightText) ?? 0) > 0;
    final isWeightValid =
        weightText.isNotEmpty && (double.tryParse(weightText) ?? 0) > 0;
    final isActivityValid = _controller.selectedActivity.value != null;
    final isGoalValid = _controller.selectedGoal.value != null;

    return isNameValid &&
        isAgeValid &&
        isGenderValid &&
        isHeightValid &&
        isWeightValid &&
        isActivityValid &&
        isGoalValid;
  }

  void _onSave() async {
    FocusScope.of(context).unfocus();
    if (!_isFormValid) return;
    await _controller.saveProfileAndInsights();
    Get.toNamed(AppRoutes.healthInsightResult);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Add My Data'),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    focusNode: _nameFocusNode,
                    hint: 'Enter your full name',
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _ageFocusNode.requestFocus(),
                  ),
                  SizedBox(height: 12.h),

                  // Age
                  _buildFieldLabel('Age'),
                  _buildTextInput(
                    controller: _controller.ageController,
                    focusNode: _ageFocusNode,
                    hint: 'Enter age',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _heightFocusNode.requestFocus(),
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
                            Theme(
                              data: Theme.of(context).copyWith(
                                popupMenuTheme: const PopupMenuThemeData(
                                  color: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  menuPadding: EdgeInsets.zero,
                                ),
                              ),
                              child: PopupMenuButton<Gender>(
                                onSelected: (Gender g) {
                                  _controller.setGender(g);
                                  setState(() => _isGenderMenuOpen = false);
                                },
                                onCanceled: () {
                                  setState(() => _isGenderMenuOpen = false);
                                },
                                onOpened: () {
                                  setState(() => _isGenderMenuOpen = true);
                                },
                                offset: Offset(0, 52.h),
                                constraints: BoxConstraints(
                                  minWidth: 144.w,
                                  maxWidth: 144.w,
                                ),
                                itemBuilder: (context) {
                                  return [
                                    GenderPopupMenuEntry<Gender>(
                                      items: Gender.values.map((g) {
                                        return GenderPopupMenuItem(
                                          value: g,
                                          label: g.displayName,
                                        );
                                      }).toList(),
                                    ),
                                  ];
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 48.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: _isGenderMenuOpen
                                          ? const Color(0xFF2FD1A6)
                                          : const Color(0xFFD4EFE6),
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
                                        _isGenderMenuOpen
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        size: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                            _buildFieldLabel('Height', unit: '(cm)'),
                            _buildTextInput(
                              controller: _controller.heightController,
                              focusNode: _heightFocusNode,
                              hint: 'Enter height (152 cm)',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) =>
                                  _weightFocusNode.requestFocus(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Weight
                  _buildFieldLabel('Weight', unit: '(kg)'),
                  _buildTextInput(
                    controller: _controller.weightController,
                    focusNode: _weightFocusNode,
                    hint: 'Enter Weight (65.7 kg)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _weightFocusNode.unfocus(),
                  ),
                  SizedBox(height: 12.h),

                  // Activity Level Selector Button
                  _buildFieldLabel('Activity Level'),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.activityLevel),
                    child: Container(
                      width: double.infinity,
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
                      width: double.infinity,
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

                  // Action Button ("Continue" if no records, "Save & Get Insights" if records exist)
                  CustomGradientButton(
                    text: _controller.hasRecords
                        ? 'Save & Get Insights'
                        : 'Continue',
                    backgroundImage: AppAssets.btnRectangle,
                    onPressed: _isFormValid ? _onSave : null,
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
    String label, {
    String? unit,
    bool isMandatory = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: MandatoryLabel(
        text: label,
        unitText: unit,
        isMandatory: isMandatory,
        style: const TextStyle(
          color: Color(0xFF111827),
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
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      width: double.infinity,
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD4EFE6)),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onSubmitted: onSubmitted,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: (_) => _onTextChanged(),
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
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
