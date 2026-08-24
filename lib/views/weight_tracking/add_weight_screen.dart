import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient_button.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Weight Tracking'),
      body: SafeArea(
        child: SingleChildScrollView(
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
              SizedBox(height: 14.h),

              // Gender Dropdown Field (with popup)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isGenderMenuOpen = !_isGenderMenuOpen),
                    child: Container(
                      height: 56.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFD4EFE6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedGender,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                CupertinoIcons.chevron_down,
                                size: 14.sp,
                                color: AppColors.textLight,
                              ),
                            ],
                          ),
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gender Dropdown Popup
                  if (_isGenderMenuOpen)
                    Positioned(
                      top: 60.h,
                      left: 40.w,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(14.r),
                        color: const Color(0xFFF0FAF6),
                        child: Container(
                          width: 140.w,
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FAF6),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFD4EFE6)),
                          ),
                          child: Column(
                            children: ['Male', 'Female', 'Other'].map((gender) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGender = gender;
                                    _isGenderMenuOpen = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.h,
                                  ),
                                  child: Center(
                                    child: Text(
                                      gender,
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
              SizedBox(height: 14.h),

              // Age Input Field
              _buildInputField(
                controller: _ageController,
                label: 'Age',
                hint: '00',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14.h),

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
                solidColor: const Color(0xFF1B8A7A),
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD4EFE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
