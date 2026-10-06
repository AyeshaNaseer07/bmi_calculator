import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/bmi_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/quick_actions_service.dart';
import '../../notifications/notification_service.dart';
import '../widgets/app_background.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationService.instance.requestPermission();
        QuickActionsService.instance.consumePendingAction();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BMIController bmiController = Get.find<BMIController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              top: 10.h,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Obx(() {
                  final latestRecord = bmiController.latestRecord.value;
                  final profile = profileController.userProfile.value;
                  final String bgImage;

                  if (latestRecord != null) {
                    final gender = latestRecord.gender.trim().toLowerCase();
                    if (gender == 'female') {
                      bgImage = AppAssets.homeImgFemale;
                    } else if (gender == 'male') {
                      bgImage = AppAssets.homeAvatar;
                    } else {
                      bgImage = AppAssets.homeAvatar;
                    }
                  } else if (profile.displayName.isNotEmpty) {
                    if (profile.gender == Gender.female) {
                      bgImage = AppAssets.homeImgFemale;
                    } else {
                      bgImage = AppAssets.homeAvatar;
                    }
                  } else {
                    bgImage = AppAssets.homeAvatarDefault;
                  }

                  return Image.asset(
                    bgImage,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topRight,
                  );
                }),
              ),
            ),

            // Main Screen Content
            SafeArea(
              child: Column(
                children: [
                  // Fixed Header: Profile & Diamond Icons + Greeting & Welcome (Non-scrollable)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        _buildTopBar(),
                        SizedBox(height: 30.h),
                        Obx(() {
                          final hasData = bmiController.bmiHistory.isNotEmpty;
                          return _buildGreeting(hasData, profileController);
                        }),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),

                  // Content (fixed, no scrolling)
                  Expanded(
                    child: Obx(() {
                      final hasData = bmiController.bmiHistory.isNotEmpty;
                      final latest = bmiController.latestRecord.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          left: 18.w,
                          right: 18.w,
                          top: 2.h,
                          bottom: 6.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!hasData || latest == null)
                              // Empty state: just the prompt card, centered
                              Expanded(
                                child: Center(child: _buildEmptyBmiCard()),
                              )
                            else ...[
                              // Main BMI Card
                              _buildActiveBmiCard(latest),
                              SizedBox(height: 10.h),

                              // Quick Parameters Pills (Weight, Height, Age, Gender)
                              _buildParameterPills(latest, bmiController),
                              SizedBox(height: 10.h),

                              // BMI Categories Row (scales down to fit if space is tight)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          36.w,
                                      child: _buildBmiCategories(
                                        latest.category,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final ProfileController profileController = Get.find<ProfileController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.toNamed(AppRoutes.profile),
          child: Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final imgPath = profileController.profileImagePath.value;
              if (imgPath != null) {
                return ClipOval(
                  child: Image.file(
                    File(imgPath),
                    width: 38.w,
                    height: 38.w,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return Image.asset(
                AppAssets.profileIcon,
                width: 38.w,
                height: 38.w,
                fit: BoxFit.contain,
              );
            }),
          ),
        ),
        Obx(() {
          final appController = Get.find<AppController>();
          if (appController.isPremium.value) {
            return SizedBox(width: 36.w, height: 36.w);
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(AppRoutes.paywall),
            child: Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: Offset(0, -3.5.w),
                child: Lottie.asset(
                  AppAssets.premiumLottie,
                  width: 38.w,
                  height: 38.w,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGreeting(bool hasData, ProfileController profileController) {
    final userName = profileController.userProfile.value.displayName;
    final greeting = userName.isNotEmpty ? 'Hello, $userName' : 'Hello, Guest';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Text Section
        Row(
          children: [
            Flexible(
              child: Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF63C9B7),
                  fontSize: 24,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text('👋', style: TextStyle(fontSize: 24.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          hasData
              ? "Let's track your health today."
              : "Welcome! Let's begin your health journey.",
          style: TextStyle(
            color: const Color(0xFF647E80),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBmiCard() {
    return CustomCard(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      borderRadius: 22.r,
      child: Column(
        children: [
          BMIGaugeWidget(bmiValue: 25.0, size: 200.w, showLabels: true),
          Text(
            'No BMI Record Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF1A252C),
              fontSize: 18.sp,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "You haven't calculated your BMI yet. Enter your\ndetails to discover your health status.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF7A8B94),
              fontSize: 13.sp,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
          SizedBox(height: 18.h),
          CustomGradientButton(
            text: 'Calculate Your BMI',
            leadingIcon: Image.asset(
              AppAssets.calcilatorIcon,
              width: 18.w,
              height: 18.w,
            ),
            solidColor: const Color(0xFF00BD8E),
            borderRadius: BorderRadius.circular(26.r),
            height: 48.h,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w700,
            ),
            onPressed: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBmiCard(BMIRecord record) {
    final isToday = DateUtils.isSameDay(record.date, DateTime.now());
    final formattedTime = isToday
        ? 'Today, ${DateFormat('h:mm a').format(record.date)}'
        : DateFormat('MMM d, h:mm a').format(record.date);

    return Column(
      children: [
        // Main Gauge Card
        CustomCard(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          borderRadius: 22.r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: "Your BMI" + Last Updated
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your BMI',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Last Updated',
                        style: TextStyle(
                          color: const Color(0xFF96ADB0),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: const Color(0xFF1E2D2F),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Gauge
              Center(
                child: BMIGaugeWidget(
                  bmiValue: record.bmiValue,
                  size: 170.w,
                  showLabels: true,
                ),
              ),
              SizedBox(height: 2.h),

              // Value, Category badge & View History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    record.bmiValue.toStringAsFixed(1),
                    style: TextStyle(
                      color: record.category.color,
                      fontSize: 36,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 4.h,
                    ),
                    decoration: ShapeDecoration(
                      color: record.category.color.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                    child: Text(
                      record.category.label,
                      style: TextStyle(
                        color: record.category.color,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.history),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF1F5F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 10.sp,
                            color: const Color(0xFF1E2D2F),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'View History',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Health Feedback Banner
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 48.h),
          decoration: BoxDecoration(
            color: record.category.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: AppColors.cardShadow,
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              record.category.buildFeedbackIcon(size: 24.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  record.category.feedbackMessage,
                  style: TextStyle(
                    color: const Color(0xFF1E2D2F),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Image.asset(AppAssets.ageForward, height: 16.h, width: 16.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParameterPills(BMIRecord record, BMIController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE8F7F2)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildParamItem(
            imageAsset: AppAssets.weighticon,
            value: record.weightDisplay,
            label: 'Weight',
            onTapUpdate: () => Get.toNamed(AppRoutes.addWeight),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.heighticon,
            value: record.heightDisplay,
            label: 'Height',
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.ageicon,
            value: '${record.age} Yrs',
            label: 'Age',
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.gendericon,
            value: record.gender,
            label: 'Gender',
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
        ],
      ),
    );
  }

  Widget _buildParamItem({
    required String imageAsset,
    required String value,
    required String label,
    required VoidCallback onTapUpdate,
  }) {
    return Column(
      children: [
        Image.asset(imageAsset, width: 39.w, height: 39.w),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1E2D2F),
            fontSize: 12.sp,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF647E80),
            fontSize: 11.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 44.h, width: 1.w, color: const Color(0xFFF1F5F9));
  }

  Widget _buildBmiCategories(BMICategory currentCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'BMI ',
                style: TextStyle(
                  color: const Color(0xFF1E2D2F),
                  fontSize: 20,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'Categories',
                style: TextStyle(
                  color: const Color(0xFF09B389),
                  fontSize: 20,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'Underweight (<18.5)',
                currentCategory == BMICategory.underweight,
                inactiveBg: const Color(0xFFEAF5FD),
                activeBg: const Color(0xFF5AC1E9),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'Obese (30–34.9)',
                currentCategory == BMICategory.obese,
                inactiveBg: const Color(0xFFFFEDE6),
                activeBg: const Color(0xFFFF0100),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'Overweight (25–29.9)',
                currentCategory == BMICategory.overweight,
                inactiveBg: const Color(0xFFFEF6E9),
                activeBg: const Color(0xFFFE9B20),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'Normal (18.5–24.9)',
                currentCategory == BMICategory.normal,
                inactiveBg: const Color(0xFFE6F8F4),
                activeBg: const Color(
                  0xFF25C6A5,
                ), // already full opacity, unchanged
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(
    String text,
    bool isCurrent, {
    required Color inactiveBg,
    required Color activeBg,
  }) {
    return Container(
      height: 40.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCurrent ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: 'Outfit',
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
          color: isCurrent ? Colors.white : const Color(0xFF1E2D2F),
        ),
      ),
    );
  }
}
