import 'dart:io';

import 'package:bmi_calculator/core/constants/app_strings.dart';
import 'package:bmi_calculator/data/services/logger_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_loader.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    return Stack(
      children: [
        _buildPage(context),
        Obx(
          () => controller.isUploading.value
              ? const LoaderOverlay(message: 'Uploading photo...')
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Profile'),
        body: SafeArea(
          // Fixed layout (no scrolling): the account list takes the space
          // left over, and its rows share it evenly.
          child: Padding(
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
                      : 'Add your name to personalize\nyour experience.';

                  return CustomCard(
                    borderRadius: 20.r,
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        // Avatar with edit icon badge
                        GestureDetector(
                          onTap: () => profileController.isUploading.value
                              ? null
                              : profileController.pickProfileImage(),
                          child: Obx(() {
                            final imgPath =
                                profileController.profileImagePath.value;
                            final uploading =
                                profileController.isUploading.value;
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
                                // Loading overlay
                                if (uploading)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24.w,
                                          height: 24.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
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
                // Already premium — nothing to upsell, so the banner is
                // removed rather than left as dead space.
                Obx(() {
                  if (appController.isPremium.value) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.paywall),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF064E3B),
                              Color(0xFF0B8F6F),
                              Color(0xFF2FD1A6),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF09B389)
                                  .withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: Stack(
                            children: [
                              // Soft decorative glows.
                              Positioned(
                                right: -30.w,
                                top: -40.h,
                                child: Container(
                                  width: 130.w,
                                  height: 130.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -24.w,
                                bottom: -46.h,
                                child: Container(
                                  width: 110.w,
                                  height: 110.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFD54F)
                                        .withValues(alpha: 0.14),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(18.r),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52.w,
                                      height: 52.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFFFE082),
                                          width: 1.4,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(11.w),
                                      child: Image.asset(
                                        AppAssets.premiumCrown,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Unlock Premium',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            'Get advanced insights, reports &\nmore',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.88,
                                              ),
                                              fontSize: 10.5.sp,
                                              height: 1.25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFE27A),
                                            Color(0xFFFFB300),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFB300)
                                                .withValues(alpha: 0.45),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Get.toNamed(AppRoutes.paywall),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: const Color(
                                            0xFF5A3A00,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 9.h,
                                          ),
                                        ),
                                        child: Text(
                                          'Go Premium',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
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
                }),

                SizedBox(height: 10.h),
                // Account List Card
                Expanded(
                  child: Container(
                    width: double.infinity,
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
                            onTap: () =>
                                Get.toNamed(AppRoutes.languagesSettings),
                          ),
                          // Notifications Switch
                          Expanded(
                            child: Obx(() {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38.w,
                                      height: 38.w,
                                      alignment: Alignment.center,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF33D2AB)
                                            .withValues(alpha: 0.15),
                                        shape: OvalBorder(),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.moon,
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
                                            'Dark Mode',
                                            style: TextStyle(
                                              color: const Color(0xFF111827),
                                              fontSize: 12.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          Text(
                                            'Switch between light and dark theme',
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
                                      value: appController
                                          .notificationsEnabled
                                          .value,
                                      activeTrackColor: const Color(0xFF2FD1A6),
                                      onChanged: (val) => appController
                                          .toggleNotifications(val),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
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

                          // Share App
                          _buildAccountRow(
                            icon: CupertinoIcons.share_up,
                            title: 'Share App',
                            subtitle: 'Share this app with friends & family',
                            onTap: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  text: 'Check out this BMI Calculator app! Track your health and stay fit. Download it now!',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          color: Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: const Color(0xFF33D2AB).withValues(alpha: 0.15),
                  shape: OvalBorder(),
                ),
                child: Icon(icon, color: const Color(0xFF33D2AB), size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final ProfileController controller;

  const _EditProfileBottomSheet({required this.controller});

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.userProfile.value.displayName,
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _textController.text.trim();
    if (newName.isEmpty) {
      _focusNode.unfocus();
      return;
    }
    _focusNode.unfocus();
    await widget.controller.updateName(newName);
    if (mounted) Navigator.pop(context);
    Get.snackbar(
      'Success',
      'Profile updated for $newName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNameValid = _textController.text.trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _focusNode.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 14.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
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
              style: TextStyle(fontSize: 12.sp, color: AppColors.textLight),
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
                    color: const Color(0x3A33D2AB),
                    blurRadius: 6.80,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0.r),
                child: Center(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onTapOutside: (_) => _focusNode.unfocus(),
                    onSubmitted: (_) => _saveName(),
                    onChanged: (_) => setState(() {}),
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
                      _focusNode.unfocus();
                      Navigator.pop(context);
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
                    onPressed: isNameValid ? _saveName : null,
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
  }
}
