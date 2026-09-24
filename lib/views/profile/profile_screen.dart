import 'dart:io';

import 'package:bmi_calculator/core/constants/app_strings.dart';
import 'package:bmi_calculator/data/services/logger_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/mandatory_label.dart';
import 'dialogs/rate_us_dialog.dart';

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

  void _openRateUsDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const RateUsDialog());
  }

  void sendFeedback() {
    const String email = AppStrings.feedbackEmail;
    const String subject = 'BMI Calculator Feedback';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );
    _launchUrl(emailLaunchUri.toString());
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.e('Could not launch $url');
      }
    } catch (e) {
      AppLogger.e('Error launching $url', e);
    }
  }

  void _showEditProfileBottomSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    final textController = TextEditingController(
      text: controller.userProfile.value.displayName,
    );
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isNameValid = textController.text.trim().isNotEmpty;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => focusNode.unfocus(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
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
                    MandatoryLabel(
                      text: 'Edit Profile Name',
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
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      height: 51.h,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.r),
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
                        padding: EdgeInsets.all(8.0.r),
                        child: Center(
                          child: TextField(
                            controller: textController,
                            focusNode: focusNode,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onTapOutside: (_) => focusNode.unfocus(),
                            onSubmitted: (_) async {
                              if (isNameValid) {
                                focusNode.unfocus();
                                final newName = textController.text.trim();
                                await controller.updateName(newName);
                                if (ctx.mounted) Navigator.pop(ctx);
                                Get.snackbar(
                                  'Success',
                                  'Profile updated for $newName',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF10B981),
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              } else {
                                focusNode.unfocus();
                              }
                            },
                            onChanged: (_) => setSheetState(() {}),
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
                            onPressed: () {
                              focusNode.unfocus();
                              Navigator.pop(ctx);
                            },
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
                              backgroundColor: const Color(0xFF09B389),
                              disabledBackgroundColor: const Color(0xFF09B389)
                                  .withValues(alpha: 0.35),
                              disabledForegroundColor: Colors.white.withValues(
                                alpha: 0.6,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isNameValid
                                ? () async {
                                    focusNode.unfocus();
                                    final newName = textController.text.trim();
                                    await controller.updateName(newName);
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    Get.snackbar(
                                      'Success',
                                      'Profile updated for $newName',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF10B981),
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                    );
                                  }
                                : null,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      focusNode.dispose();
      textController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                          onTap: () => profileController.pickProfileImage(),
                          child: Obx(() {
                            final imgPath =
                                profileController.profileImagePath.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 56.w,
                                  height: 56.h,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF33D2AB)
                                        .withValues(alpha: 0.21),
                                    shape: OvalBorder(),
                                  ),
                                  child: imgPath != null
                                      ? ClipOval(
                                          child: Image.file(
                                            File(imgPath),
                                            width: 56.w,
                                            height: 56.h,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          CupertinoIcons.person,
                                          color: const Color(0xFF33D2AB),
                                          size: 28.sp,
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 23.w,
                                    height: 23.h,
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
                            );
                          }),
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
                                Row(
                                  children: [
                                    Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF111827),
                                        fontSize: 16.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    // Edit Profile Pill
                                    GestureDetector(
                                      onTap: () => _showEditProfileBottomSheet(
                                        context,
                                        profileController,
                                      ),
                                      child: Container(
                                        width: 24.w,
                                        height: 24.h,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF33D2AB)
                                              .withValues(alpha: 0.2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 14.sp,
                                          color: const Color(0xFF33D2AB)
                                              .withValues(alpha: 0.82),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  tagline,
                                  style: TextStyle(
                                    color: const Color(0xFF111827)
                                        .withValues(alpha: 0.82),
                                    fontSize: 11.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
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
                    fontSize: 16.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),

                // Account List Card
                Container(
                  width: double.infinity,
                  height: 368.h,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.25,
                        color: const Color(0xFF33D2AB),
                      ),
                      borderRadius: BorderRadius.circular(14.r),
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
                    padding: EdgeInsets.all(8.0.r),
                    child: Column(
                      children: [
                        // Language
                        _buildAccountRow(
                          icon: CupertinoIcons.globe,
                          title: 'Language',
                          subtitle: 'Select your app language',
                          onTap: () => Get.toNamed(AppRoutes.languagesSettings),
                        ),
                        // Notifications Switch
                        Obx(() {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 38.w,
                                  height: 38.h,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF33D2AB)
                                        .withValues(alpha: 0.15),
                                    shape: OvalBorder(),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.bell,
                                    color: const Color(0xFF33D2AB),
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Theme',
                                        style: TextStyle(
                                          color: const Color(0xFF111827),
                                          fontSize: 12.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Manage your theme preferences',
                                        style: TextStyle(
                                          color: const Color(0xFF111827)
                                              .withValues(alpha: 0.82),
                                          fontSize: 11.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoSwitch(
                                  value:
                                      appController.notificationsEnabled.value,
                                  activeTrackColor: const Color(0xFF2FD1A6),
                                  onChanged: (val) =>
                                      appController.toggleNotifications(val),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        // Rate Us
                        _buildAccountRow(
                          icon: Icons.star_outline_rounded,
                          title: 'Rate Us',
                          subtitle: 'Rate your experience with us',
                          onTap: () => _openRateUsDialog(context),
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

                        // Feedback
                        _buildAccountRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Feedback',
                          subtitle: 'Send us your suggestions & ideas',
                          onTap: () => sendFeedback(),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Unlock Premium Banner (Screenshot 19)
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.paywall),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFDFDFE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: const Color(0xFFFFD700),
                          size: 26.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlock Premium',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Get advanced insights, reports &\nmore',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.paywall),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF09B389),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                          ),
                          child: Text(
                            'Go Premium',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
              width: 38.w,
              height: 38.h,
              decoration: ShapeDecoration(
                color: const Color(0xFF33D2AB).withValues(alpha: 0.15),
                shape: OvalBorder(),
              ),
              child: Icon(icon, color: const Color(0xFF33D2AB), size: 18.sp),
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
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF111827).withValues(alpha: 0.82),
                      fontSize: 11.sp,
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
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
