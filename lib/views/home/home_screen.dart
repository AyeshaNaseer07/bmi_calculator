import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/bmi_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/ads/native_ad_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BMIController bmiController = Get.find<BMIController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Stack(
        children: [
          // Background Illustration (Avatar on top right)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                AppAssets.homeAvatar,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topRight,
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: Obx(() {
              final hasData = bmiController.bmiHistory.isNotEmpty;
              final latest = bmiController.latestRecord.value;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Profile Avatar, Greeting, VIP Diamond
                    _buildHeader(hasData, profileController),
                    SizedBox(height: 28.h),

                    // Main BMI Card (Empty state or Active Calculated state)
                    if (!hasData || latest == null)
                      _buildEmptyBmiCard()
                    else
                      _buildActiveBmiCard(latest),

                    SizedBox(height: 16.h),

                    // Quick Parameters Pills (Weight, Height, Age, Gender)
                    if (hasData && latest != null) ...[
                      _buildParameterPills(latest, bmiController),
                      SizedBox(height: 16.h),

                      // BMI Categories Row
                      _buildBmiCategories(latest.category),
                      SizedBox(height: 18.h),
                    ],

                    // Features Heading (if empty state) or 2x2 Grid Features
                    if (!hasData) ...[
                      Text(
                        'Features',
                        style: TextStyle(
                          color: const Color(0xFF1A252C),
                          fontSize: 18,
                          fontFamily: 'Instrument Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      const NativeAdCard(),
                      SizedBox(height: 16.h),
                    ],

                    // 2x2 Feature Cards Grid
                    _buildFeatureGrid(),
                    if (hasData) ...[
                      SizedBox(height: 16.h),
                      const NativeAdCard(),
                    ],
                    SizedBox(height: 24.h),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool hasData, ProfileController profileController) {
    final userName = profileController.userProfile.value.displayName;
    final greeting = userName.isNotEmpty ? 'Hello, $userName' : 'Hello, Guest';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Profile Icon & Diamond Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: Image.asset(
                AppAssets.profileIcon,
                width: 32.w,
                height: 32.w,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.paywall),
              child: Image.asset(
                AppAssets.icDiamond,
                width: 32.w,
                height: 32.w,
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),

        // Greeting Text Section
        Row(
          children: [
            Flexible(
              child: Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF1A252C),
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
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      borderRadius: 22.r,
      child: Column(
        children: [
          BMIGaugeWidget(bmiValue: 21.5, size: 160.w, showLabels: false),
          SizedBox(height: 14.h),
          Text(
            'No BMI Record Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF1A252C),
              fontSize: 18,
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
              fontSize: 13,
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
              width: 16.w,
              height: 16.w,
            ),
            backgroundImage: AppAssets.btnRectangle,
            height: 48.h,
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

    return CustomCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: 22.r,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: "Your BMI", Large value, Category badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your BMI',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    record.bmiValue.toStringAsFixed(1),
                    style: TextStyle(
                      color: const Color(0xFF33D2AB),
                      fontSize: 36,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 4.h,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE2F7F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                    child: Text(
                      record.category.label,
                      style: TextStyle(
                        color: const Color(0xFF07A981),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              // Center: Gauge
              Expanded(
                child: Center(
                  child: BMIGaugeWidget(
                    bmiValue: record.bmiValue,
                    size: 142.w,
                    showLabels: true,
                  ),
                ),
              ),

              // Right: Last Updated & View History
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
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.history),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE2F7F2),
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
                            color: const Color(0xFF07A981),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'View History',
                            style: TextStyle(
                              color: const Color(0xFF06A981),
                              fontSize: 8,
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
          SizedBox(height: 12.h),

          // Bottom Health Banner
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.healthInsights),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 54.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F9F7),
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.shieldicon,
                    width: 22.w,
                    height: 22.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      record.category.feedbackMessage,
                      style: TextStyle(
                        color: const Color(0xFF1E2D2F),
                        fontSize: 11.5.sp,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    CupertinoIcons.arrow_right,
                    size: 18.sp,
                    color: const Color(0xFF25C6A5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterPills(BMIRecord record, BMIController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
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
            value: '${record.weightKg.toStringAsFixed(1)} kg',
            label: 'Weight',
            onTapUpdate: () => Get.toNamed(AppRoutes.addWeight),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.heighticon,
            value: '${record.heightCm.toStringAsFixed(0)} cm',
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
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF647E80),
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: onTapUpdate,
          child: Container(
            width: 52,
            height: 23,
            decoration: ShapeDecoration(
              color: const Color(0xFF33D2AB).withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Center(
              child: Text(
                'Update',
                style: TextStyle(
                  color: const Color(0xFF2EC4B6),
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
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
                  color: const Color(0xFF33D2AB),
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
                activeBg: const Color(0xFF25C6A5),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'Normal (18.5–24.9)',
                currentCategory == BMICategory.normal,
                inactiveBg: const Color(0xFFE6F8F4),
                activeBg: const Color(0xFF25C6A5),
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
                activeBg: const Color(0xFF25C6A5),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'Obese (30–34.9)',
                currentCategory == BMICategory.obese,
                inactiveBg: const Color(0xFFFFEDE6),
                activeBg: const Color(0xFF25C6A5),
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

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridTile(
                imagePath: AppAssets.homeIcon1,
                title: 'BMI Calculator',
                subtitle: 'Calculate your BMI',
                onTap: () => Get.toNamed(AppRoutes.bmiCalculator),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGridTile(
                imagePath: AppAssets.homeIcon2,
                title: 'Weight Tracker',
                subtitle: 'Record your weight',
                onTap: () => Get.toNamed(AppRoutes.weightTracking),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildGridTile(
                imagePath: AppAssets.homeIcon3,
                title: 'Health Insights',
                subtitle: 'Daily wellness advice',
                onTap: () => Get.toNamed(AppRoutes.healthInsights),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGridTile(
                imagePath: AppAssets.homeIcon4,
                title: 'History',
                subtitle: 'Monitor your journey',
                onTap: () => Get.toNamed(AppRoutes.history),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridTile({
    required String imagePath, // Changed from IconData to String
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      borderRadius: 18.r,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                imagePath,
                width: 40.w,
                height: 40.h,
                fit: BoxFit.contain,
              ),
              Image.asset(
                AppAssets.chevronIcon,
                width: 16.w,
                height: 16.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF1A252C),
              fontSize: 14,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFF7A8B94),
              fontSize: 11,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w400,
              height: 1.30,
            ),
          ),
        ],
      ),
    );
  }
}
