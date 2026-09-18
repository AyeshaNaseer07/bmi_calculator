import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient_button.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Change Password'),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Current Password'),
                _buildPasswordInput(
                  controller: controller.currentPasswordController,
                  hint: 'Enter your current password',
                ),
                SizedBox(height: 16.h),

                _buildFieldLabel('New Password'),
                _buildPasswordInput(
                  controller: controller.newPasswordController,
                  hint: 'Enter your new password',
                ),
                SizedBox(height: 16.h),

                _buildFieldLabel('Confirm Password'),
                _buildPasswordInput(
                  controller: controller.confirmPasswordController,
                  hint: 'Re-enter your new password',
                ),
                SizedBox(height: 32.h),

                Obx(() {
                  return CustomGradientButton(
                    text: controller.isPasswordUpdating.value
                        ? 'Updating...'
                        : 'Confirm',
                    solidColor: const Color(0xFF1B8A7A),
                    onPressed: controller.isPasswordUpdating.value
                        ? null
                        : () async {
                            final ok = await controller.changePassword();
                            if (ok) Get.back();
                          },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD4EFE6)),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: true,
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
          ),
        ),
      ),
    );
  }
}
