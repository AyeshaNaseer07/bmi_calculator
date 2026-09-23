import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:bmi_calculator/views/widgets/custom_gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/gender_popup_menu.dart';

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
  }

  void _onSave() async {
    final current =
        double.tryParse(_currentWeightController.text.trim()) ?? 0.0;
    final goal = double.tryParse(_goalWeightController.text.trim()) ?? 0.0;

    if (current <= 0) {
      Get.snackbar(
        'Invalid',
        'Please enter your current weight.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      // Current Weight
                      _buildWeightInputField(
                        controller: _currentWeightController,
                        label: 'Current Weight',
                        hint: '00.0',
                      ),
                      SizedBox(height: 16.h),

                      // Goal Weight
                      _buildWeightInputField(
                        controller: _goalWeightController,
                        label: 'Goal Weight',
                        hint: '00.0',
                      ),
                      SizedBox(height: 16.h),

                      // Gender Dropdown Field
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
                          offset: Offset(0, 68.h),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _selectedGender,
                                      style: const TextStyle(
                                        color: Color(0xFF4B5563),
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
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Gender',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 17,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Age Input Field
                      _buildInputField(
                        controller: _ageController,
                        label: 'Age',
                        hint: '00',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),

                      // Height Input Field
                      _buildInputField(
                        controller: _heightController,
                        label: 'Height',
                        hint: '0.0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Save Button
                      CustomGradientButton(
                        text: 'Save Weight',
                        backgroundImage: AppAssets.btnRectangle,
                        onPressed: _onSave,
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
  }) {
    return _buildCardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF6B7280),
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

          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
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
  }) {
    return _buildCardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 17,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF6B7280),
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
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
