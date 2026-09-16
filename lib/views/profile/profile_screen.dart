import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import 'dialogs/units_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showInfoDialog(String title, String content) {
    Get.defaultDialog(
      title: title,
      middleText: content,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryTeal,
      onConfirm: () => Get.back(),
    );
  }

  void _openUnitsDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const UnitsDialog());
  }

  void _showEditProfileBottomSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    final textController = TextEditingController(
      text: controller.userProfile.value.displayName,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 14.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Edit Profile Name',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Instrument Sans',
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Enter your name to personalize your health journey.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textLight),
              ),
              SizedBox(height: 16.h),
              Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFD4EFE6)),
                ),
                child: Center(
                  child: TextField(
                    controller: textController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(color: Color(0xFFD4EFE6)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB59B),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final newName = textController.text.trim();
                        await controller.updateName(newName);
                        if (ctx.mounted) Navigator.pop(ctx);
                        Get.snackbar(
                          'Success',
                          newName.isNotEmpty
                              ? 'Profile updated for $newName'
                              : 'Profile name cleared',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF10B981),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.toNamed(AppRoutes.healthInsights);
                  },
                  icon: Icon(
                    Icons.tune,
                    size: 16.sp,
                    color: const Color(0xFF1DB59B),
                  ),
                  label: Text(
                    'Update Full Health & Body Details',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1DB59B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Obx(() {
                final name = profileController.userProfile.value.displayName;
                final displayName = name.isNotEmpty ? name : 'Guest User';
                final tagline = name.isNotEmpty
                    ? 'Manage your health profile'
                    : 'Start your health journey\nby adding your details.';

                return CustomCard(
                  borderRadius: 20.r,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // Avatar with edit icon badge
                      GestureDetector(
                        onTap: () => _showEditProfileBottomSheet(
                          context,
                          profileController,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF33D2AB)
                                    .withValues(alpha: 0.21),
                                shape: OvalBorder(),
                              ),

                              child: Icon(
                                CupertinoIcons.person,
                                color: const Color(0xFF33D2AB),
                                size: 28.sp,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 23,
                                height: 23,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF33D2AB)
                                      .withValues(alpha: 0.8),
                                  shape: OvalBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),

                      // Name and Tagline
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showEditProfileBottomSheet(
                            context,
                            profileController,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF111827),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                tagline,
                                style: TextStyle(
                                  color: const Color(0xFF111827)
                                      .withOpacity(0.82),
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Edit Profile Pill
                      GestureDetector(
                        onTap: () => _showEditProfileBottomSheet(
                          context,
                          profileController,
                        ),
                        child: Container(
                          width: 81,
                          height: 25,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF33D2AB)
                                    .withOpacity(0.82),
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 12.sp,
                                  color: const Color(0xFF33D2AB)
                                      .withOpacity(0.82),
                                ),
                                SizedBox(width: 4.w),
                                Opacity(
                                  opacity: 0.82,
                                  child: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: const Color(0xFF33D2AB),
                                      fontSize: 10,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 18.h),

              // Account Section
              Text(
                'Account',
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),

              // Account List Card
              Container(
                width: 337.w,
                height: 350.h,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.25,
                      color: const Color(0xFF33D2AB),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3A33D2AB),
                      blurRadius: 6.80,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Change Password
                      _buildAccountRow(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () => Get.toNamed(AppRoutes.changePassword),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      // Privacy Policy
                      _buildAccountRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () => _showInfoDialog(
                          'Privacy Policy',
                          'Your health data is stored securely on your local device. We respect your privacy and do not sell personal health information.',
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      // Terms of Use
                      _buildAccountRow(
                        icon: Icons.description_outlined,
                        title: 'Terms of Use',
                        subtitle: 'Read our terms and conditions',
                        onTap: () => _showInfoDialog(
                          'Terms of Use',
                          'BMI calculations are provided for general informational and wellness tracking purposes only and should not replace professional medical advice.',
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      // Notifications Switch
                      Obx(() {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F7F2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.bell,
                                  color: const Color(0xFF1DB59B),
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notifications',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Manage your notification preferences',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: appController.notificationsEnabled.value,
                                activeTrackColor: const Color(0xFF2FD1A6),
                                onChanged: (val) =>
                                    appController.toggleNotifications(val),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      // Units
                      _buildAccountRow(
                        icon: Icons.square_foot_outlined,
                        title: 'Units',
                        subtitle: 'Choose your preferred units',
                        onTap: () => _openUnitsDialog(context),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      // Language
                      _buildAccountRow(
                        icon: CupertinoIcons.globe,
                        title: 'Language',
                        subtitle: 'Select your app language',
                        onTap: () => Get.toNamed(AppRoutes.languagesSettings),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Log Out Button
              GestureDetector(
                onTap: () => profileController.logout(),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        size: 18.sp,
                        color: const Color(0xFFEF4444),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F7F2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1DB59B), size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF111827),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF111827).withOpacity(0.82),
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14.sp,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
