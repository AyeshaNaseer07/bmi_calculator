import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:bmi_calculator/views/widgets/custom_gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final WeightTrackerController _controller =
      Get.find<WeightTrackerController>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedGender = 'Select';
  bool _isGenderMenuOpen = false;

  void _onSave() async {
    final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;
    await _controller.addWeight(weight, DateTime.now());
    Get.back();
    Get.snackbar(
      'Success',
      'Weight record saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryTeal,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_isGenderMenuOpen) {
          setState(() => _isGenderMenuOpen = false);
        }
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF8),
        appBar: const CustomAppBar(title: 'Weight Tracking'),
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Weight Input Field
                    _buildInputField(
                      controller: _weightController,
                      label: 'Weight',
                      hint: '00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Gender Dropdown Field
                    Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            side: const BorderSide(color: Color(0xFFD4EFE6)),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
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
                        constraints: BoxConstraints(minWidth: 160.w),
                        itemBuilder: (context) {
                          return ['Male', 'Female', 'Other'].map((g) {
                            final isSelected = _selectedGender == g;
                            return PopupMenuItem<String>(
                              value: g,
                              height: 40.h,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    g,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF0F766E)
                                          : const Color(0xFF111827),
                                      fontSize: 15.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      CupertinoIcons.checkmark_alt,
                                      size: 14.sp,
                                      color: const Color(0xFF2FD1A6),
                                    ),
                                ],
                              ),
                            );
                          }).toList();
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
                      hint: '0,0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Save Button
                    CustomGradientButton(
                      text: 'Save Weight',
                      backgroundImage: AppAssets.calculateButton,
                      onPressed: _onSave,
                    ),
                  ],
                ),
              ),
            ],
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
