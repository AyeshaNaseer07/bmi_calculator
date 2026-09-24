import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:bmi_calculator/views/widgets/custom_gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/storage_service.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/gender_popup_menu.dart';
import '../widgets/mandatory_label.dart';

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
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final FocusNode _currentWeightFocusNode = FocusNode();
  final FocusNode _goalWeightFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();

  String _selectedGender = 'Select';
  bool _isGenderMenuOpen = false;

  @override
  void initState() {
    super.initState();
    if (_controller.currentWeight.value > 0) {
      _currentWeightController.text = _controller.currentWeight.value
          .toStringAsFixed(1);
    }
    if (_controller.goalWeight.value > 0) {
      _goalWeightController.text = _controller.goalWeight.value.toStringAsFixed(
        1,
      );
    }

    // Prefill profile info if available
    try {
      final storage = Get.find<StorageService>();
      final profile = storage.getUserProfile();
      if (profile.age > 0) {
        _ageController.text = profile.age.toString();
      }
      if (profile.heightCm > 0) {
        _heightController.text = profile.heightCm.toStringAsFixed(0);
      }
      if (profile.gender == Gender.male) {
        _selectedGender = 'Male';
      } else if (profile.gender == Gender.female) {
        _selectedGender = 'Female';
      }
    } catch (_) {}

    _currentWeightController.addListener(_onFieldChanged);
    _goalWeightController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _isFormValid {
    final current =
        double.tryParse(_currentWeightController.text.trim()) ?? 0.0;
    return current > 0;
  }

  void _onSave() async {
    FocusScope.of(context).unfocus();
    if (!_isFormValid) return;

    final current =
        double.tryParse(_currentWeightController.text.trim()) ?? 0.0;
    final goal = double.tryParse(_goalWeightController.text.trim()) ?? 0.0;

    // Update profile age, height, gender if entered
    final ageVal = int.tryParse(_ageController.text.trim());
    final heightVal = double.tryParse(_heightController.text.trim());
    Gender? genderVal;
    if (_selectedGender == 'Male') genderVal = Gender.male;
    if (_selectedGender == 'Female') genderVal = Gender.female;

    if (ageVal != null || heightVal != null || genderVal != null) {
      try {
        final storage = Get.find<StorageService>();
        final profile = storage.getUserProfile();
        storage.saveUserProfile(
          profile.copyWith(
            age: (ageVal != null && ageVal > 0) ? ageVal : profile.age,
            heightCm: (heightVal != null && heightVal > 0)
                ? heightVal
                : profile.heightCm,
            gender: genderVal ?? profile.gender,
          ),
        );
      } catch (_) {}
    }

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
    _currentWeightFocusNode.dispose();
    _goalWeightFocusNode.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _currentWeightController.removeListener(_onFieldChanged);
    _goalWeightController.removeListener(_onFieldChanged);
    _ageController.removeListener(_onFieldChanged);
    _heightController.removeListener(_onFieldChanged);
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _ageController.dispose();
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
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(title: 'Add Weight'),
          body: SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      // Current Weight
                      _buildWeightInputField(
                        controller: _currentWeightController,
                        focusNode: _currentWeightFocusNode,
                        label: 'Current Weight',
                        hint: '00.0',
                        isMandatory: true,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _goalWeightFocusNode.requestFocus(),
                      ),
                      SizedBox(height: 16.h),

                      // Goal Weight
                      _buildWeightInputField(
                        controller: _goalWeightController,
                        focusNode: _goalWeightFocusNode,
                        label: 'Goal Weight',
                        hint: '00.0',
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _ageFocusNode.requestFocus(),
                      ),
                      SizedBox(height: 16.h),

                      // Gender Dropdown Field
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double offsetX =
                              constraints.maxWidth - 144.w - 20.w;
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
                            child: PopupMenuButton<String>(
                              onSelected: (String gender) {
                                setState(() {
                                  _selectedGender = gender;
                                  _isGenderMenuOpen = false;
                                });
                              },
                              onCanceled: () {
                                setState(() => _isGenderMenuOpen = false);
                              },
                              onOpened: () {
                                setState(() => _isGenderMenuOpen = true);
                              },
                              offset: Offset(offsetX > 0 ? offsetX : 0, 68.h),
                              constraints: BoxConstraints(
                                minWidth: 144.w,
                                maxWidth: 144.w,
                              ),
                              itemBuilder: (context) {
                                return const [
                                  GenderPopupMenuEntry<String>(
                                    items: [
                                      GenderPopupMenuItem(
                                        value: 'Male',
                                        label: 'Male',
                                      ),
                                      GenderPopupMenuItem(
                                        value: 'Female',
                                        label: 'Female',
                                      ),
                                      GenderPopupMenuItem(
                                        value: 'Other',
                                        label: 'Other',
                                      ),
                                    ],
                                  ),
                                ];
                              },
                              child: _buildCardContainer(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Gender',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _selectedGender,
                                          style: TextStyle(
                                            color: _selectedGender != 'Select'
                                                ? Colors.black
                                                : Colors.grey.withValues(
                                                    alpha: 0.5,
                                                  ),
                                            fontSize: 17,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(
                                          _isGenderMenuOpen
                                              ? CupertinoIcons.chevron_up
                                              : CupertinoIcons.chevron_down,
                                          size: 13.sp,
                                          color: Colors.grey.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Age Input Field
                      _buildInputField(
                        controller: _ageController,
                        focusNode: _ageFocusNode,
                        label: 'Age',
                        hint: '00',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _heightFocusNode.requestFocus(),
                      ),
                      SizedBox(height: 16.h),

                      // Height Input Field
                      _buildInputField(
                        controller: _heightController,
                        focusNode: _heightFocusNode,
                        label: 'Height',
                        hint: '0.0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _heightFocusNode.unfocus(),
                      ),
                      SizedBox(height: 32.h),

                      // Save Button
                      CustomGradientButton(
                        text: 'Save Weight',
                        backgroundImage: AppAssets.btnRectangle,
                        onPressed: _isFormValid ? _onSave : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3833D2AB),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Weight field with teal "kg" unit
  Widget _buildWeightInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    bool isMandatory = false,
  }) {
    return _buildCardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MandatoryLabel(
            text: label,
            isMandatory: isMandatory,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.5),
                  fontSize: 17,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generic input field for Age and Height
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    bool isMandatory = false,
  }) {
    return _buildCardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MandatoryLabel(
            text: label,
            isMandatory: isMandatory,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textAlign: TextAlign.end,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.5),
                  fontSize: 17,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
