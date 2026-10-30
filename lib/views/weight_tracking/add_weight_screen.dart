import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/storage_service.dart';
import '../widgets/age_popup_menu.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/gender_popup_menu.dart';
import '../widgets/mandatory_label.dart';
import '../widgets/number_keypad.dart';
import '../../core/theme/app_palette.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final WeightTrackerController _controller =
      Get.find<WeightTrackerController>();

  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final FocusNode _currentWeightFocusNode = FocusNode();
  final FocusNode _goalWeightFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();

  late final NumberKeypadBinding _currentWeightKeypad;
  late final NumberKeypadBinding _goalWeightKeypad;
  late final NumberKeypadBinding _heightKeypad;

  int? _selectedAge;
  bool _isAgeMenuOpen = false;
  Gender? _selectedGender;
  bool _isGenderMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _prefillFromLastEntry();
    _currentWeightController.addListener(_onFieldChanged);
    _goalWeightController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _currentWeightKeypad = NumberKeypadBinding(
      controller: _currentWeightController,
      focus: _currentWeightFocusNode,
      allowDecimal: true,
      maxLength: 5,
      onOk: _goalWeightFocusNode.requestFocus,
    );
    _goalWeightKeypad = NumberKeypadBinding(
      controller: _goalWeightController,
      focus: _goalWeightFocusNode,
      allowDecimal: true,
      maxLength: 5,
      onOk: _heightFocusNode.requestFocus,
    );
    _heightKeypad = NumberKeypadBinding(
      controller: _heightController,
      focus: _heightFocusNode,
      allowDecimal: true,
      maxLength: 5,
    );
  }

  /// First time the form is empty (hints only); after a save it opens with
  /// the values the user saved last, which they can still edit.
  void _prefillFromLastEntry() {
    final last = Get.find<StorageService>().getLastWeightEntry();
    if (last == null) return;
    String fmt(Object? v) {
      if (v is! num || v <= 0) return '';
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }

    _currentWeightController.text = fmt(last['weightKg']);
    _goalWeightController.text = fmt(last['goalWeightKg']);
    _heightController.text = fmt(last['heightCm']);
    final age = last['age'];
    if (age is int && age > 0) _selectedAge = age;
    final gender = last['gender'];
    _selectedGender = Gender.values.where((g) => g.name == gender).firstOrNull;
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _isCurrentWeightExceeded {
    final currentText = _currentWeightController.text.trim();
    if (currentText.isEmpty) return false;
    final current = double.tryParse(currentText) ?? 0.0;
    return current > 120.0;
  }

  bool get _isGoalWeightExceeded {
    final goalText = _goalWeightController.text.trim();
    if (goalText.isEmpty) return false;
    final goal = double.tryParse(goalText) ?? 0.0;
    return goal > 120.0;
  }

  bool get _isFormValid {
    final currentText = _currentWeightController.text.trim();
    final goalText = _goalWeightController.text.trim();
    final heightText = _heightController.text.trim();

    final current = double.tryParse(currentText) ?? 0.0;
    final goal = double.tryParse(goalText) ?? 0.0;
    final height = double.tryParse(heightText) ?? 0.0;

    final isCurrentValid =
        currentText.isNotEmpty && current > 0 && current <= 120.0;
    final isGoalValid = goalText.isNotEmpty && goal > 0 && goal <= 120.0;
    final isAgeValid = _selectedAge != null && _selectedAge! > 0;
    final isHeightValid = heightText.isNotEmpty && height > 0;

    return isCurrentValid && isGoalValid && isAgeValid && isHeightValid;
  }

  void _onSave() async {
    FocusScope.of(context).unfocus();
    if (!_isFormValid) return;

    final current =
        double.tryParse(_currentWeightController.text.trim()) ?? 0.0;
    final goal = double.tryParse(_goalWeightController.text.trim()) ?? 0.0;
    final ageVal = _selectedAge;
    final heightVal = double.tryParse(_heightController.text.trim());
    final genderVal = _selectedGender;

    if (current <= 0 ||
        current > 120.0 ||
        goal <= 0 ||
        goal > 120.0 ||
        ageVal == null ||
        ageVal <= 0 ||
        heightVal == null ||
        heightVal <= 0) {
      return;
    }

    // Update profile age, height, gender if entered
    try {
      final storage = Get.find<StorageService>();
      // Prefills the form next time.
      await storage.setLastWeightEntry({
        'weightKg': current,
        'goalWeightKg': goal,
        'age': ageVal,
        'heightCm': heightVal,
        if (genderVal != null) 'gender': genderVal.name,
      });
      final profile = storage.getUserProfile();
      storage.saveUserProfile(
        profile.copyWith(
          age: ageVal,
          heightCm: heightVal,
          gender: genderVal ?? profile.gender,
          weightKg: current,
          goalWeightKg: goal,
        ),
      );
    } catch (_) {}

    await _controller.addWeight(current, DateTime.now(), goalWeight: goal);
    Get.back();
    Get.snackbar(
      'Saved',
      'Weight record saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryTeal,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    _currentWeightKeypad.dispose();
    _goalWeightKeypad.dispose();
    _heightKeypad.dispose();
    _currentWeightFocusNode.dispose();
    _goalWeightFocusNode.dispose();
    _heightFocusNode.dispose();
    _currentWeightController.removeListener(_onFieldChanged);
    _goalWeightController.removeListener(_onFieldChanged);
    _heightController.removeListener(_onFieldChanged);
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_isGenderMenuOpen) {
            setState(() => _isGenderMenuOpen = false);
          }
          if (_isAgeMenuOpen) {
            setState(() => _isAgeMenuOpen = false);
          }
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(title: 'Add Weight'),
          bottomNavigationBar: const NumberKeypadHost(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      'Track your weight journey by entering your details below.',
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],
                ),
              ),

              // Scrollable Form Fields
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: 18.w,
                    right: 18.w,
                    bottom: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Weight (Mandatory)
                      _buildFieldLabel(
                        'Current Weight',
                        unit: '(kg)',
                        isMandatory: true,
                      ),
                      _buildTextInput(
                        controller: _currentWeightController,
                        focusNode: _currentWeightFocusNode,
                        hint: 'Enter Weight (65.7 kg)',
                        isError: _isCurrentWeightExceeded,
                        keyboardType: _currentWeightKeypad.keyboardType,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _goalWeightFocusNode.requestFocus(),
                      ),
                      if (_isCurrentWeightExceeded) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              color: const Color(0xFFEF4444),
                              size: 14.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Weight cannot exceed 120 kg.',
                              style: TextStyle(
                                color: const Color(0xFFEF4444),
                                fontSize: 12.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // Goal Weight (Mandatory)
                      _buildFieldLabel(
                        'Goal Weight',
                        unit: '(kg)',
                        isMandatory: true,
                      ),
                      _buildTextInput(
                        controller: _goalWeightController,
                        focusNode: _goalWeightFocusNode,
                        hint: 'Enter goal weight (60.0 kg)',
                        isError: _isGoalWeightExceeded,
                        keyboardType: _goalWeightKeypad.keyboardType,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _heightFocusNode.requestFocus(),
                      ),
                      if (_isGoalWeightExceeded) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              color: const Color(0xFFEF4444),
                              size: 14.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Goal weight cannot exceed 120 kg.',
                              style: TextStyle(
                                color: const Color(0xFFEF4444),
                                fontSize: 12.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 12.h),

                      // Age (Mandatory)
                      _buildFieldLabel('Age', isMandatory: true),
                      _buildAgeDropdown(context),
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
                                _buildFieldLabel('Gender', isMandatory: false),
                                _buildGenderDropdown(context),
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
                                _buildFieldLabel(
                                  'Height',
                                  unit: '(cm)',
                                  isMandatory: true,
                                ),
                                _buildTextInput(
                                  controller: _heightController,
                                  focusNode: _heightFocusNode,
                                  hint: 'Enter height (152 cm)',
                                  keyboardType: _heightKeypad.keyboardType,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) =>
                                      _heightFocusNode.unfocus(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Save Button
                      CustomGradientButton(
                        text: 'Save Weight',
                        backgroundImage: AppAssets.btnRectangle,
                        onPressed: _isFormValid ? _onSave : null,
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
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
        style: TextStyle(
          color: AppPalette.textPrimary,
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
    bool isError = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: isError
            ? (AppPalette.isDark
                  ? const Color(0x33EF4444)
                  : const Color(0xFFFEF2F2))
            : AppPalette.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isError ? const Color(0xFFEF4444) : AppPalette.mintBorder,
          width: isError ? 1.5.w : 1.w,
        ),
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
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: isError ? const Color(0xFFDC2626) : AppColors.textDark,
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

  Widget _buildAgeDropdown(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          menuPadding: EdgeInsets.zero,
        ),
      ),
      child: PopupMenuButton<int>(
        onSelected: (int a) {
          setState(() {
            _selectedAge = a;
            _isAgeMenuOpen = false;
          });
        },
        onCanceled: () {
          setState(() => _isAgeMenuOpen = false);
        },
        onOpened: () {
          setState(() => _isAgeMenuOpen = true);
        },
        offset: Offset(0, 52.h),
        constraints: BoxConstraints(minWidth: 144.w, maxWidth: 144.w),
        itemBuilder: (context) {
          return [
            AgePopupMenuEntry(
              items: List.generate(120, (i) => i + 1),
              selectedAge: _selectedAge,
            ),
          ];
        },
        child: Container(
          width: double.infinity,
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: _isAgeMenuOpen
                  ? const Color(0xFF2FD1A6)
                  : AppPalette.mintBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedAge != null ? '$_selectedAge' : 'Select',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: _selectedAge != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _selectedAge != null
                      ? AppColors.textDark
                      : AppColors.textLight,
                ),
              ),
              Icon(
                _isAgeMenuOpen
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 14.sp,
                color: AppPalette.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(BuildContext context) {
    return Theme(
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
          setState(() {
            _selectedGender = g;
            _isGenderMenuOpen = false;
          });
        },
        onCanceled: () {
          setState(() => _isGenderMenuOpen = false);
        },
        onOpened: () {
          setState(() => _isGenderMenuOpen = true);
        },
        offset: Offset(0, 52.h),
        constraints: BoxConstraints(minWidth: 144.w, maxWidth: 144.w),
        itemBuilder: (context) {
          return [
            GenderPopupMenuEntry<Gender>(
              items: Gender.values.map((g) {
                return GenderPopupMenuItem(value: g, label: g.displayName);
              }).toList(),
            ),
          ];
        },
        child: Container(
          width: double.infinity,
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: _isGenderMenuOpen
                  ? const Color(0xFF2FD1A6)
                  : AppPalette.mintBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedGender?.displayName ?? 'Select',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: _selectedGender != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _selectedGender != null
                      ? AppColors.textDark
                      : AppColors.textLight,
                ),
              ),
              Icon(
                _isGenderMenuOpen
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 14.sp,
                color: AppPalette.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
