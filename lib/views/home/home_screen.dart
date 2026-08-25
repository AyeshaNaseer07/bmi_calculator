import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/native_ad_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BMIController bmiController = Get.find<BMIController>();

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
                    _buildHeader(hasData),
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
                      const NativeAdPlaceholder(),
                      SizedBox(height: 24.h),
                    ],

                    // 2x2 Feature Cards Grid
                    _buildFeatureGrid(),
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

  Widget _buildHeader(bool hasData) {
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
                width: 30.w,
                height: 30.w,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.paywall),
              child: Image.asset(
                AppAssets.icDiamond,
                width: 30.w,
                height: 30.w,
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),

        // Greeting Text Section
        Row(
          children: [
            Text(
              'Hello, Alex',
              style: TextStyle(
                color: const Color(0xFF1A252C),
                fontSize: 24,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w700,
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
            color: const Color(0xFF7A8B94),
            fontSize: 12,
            fontFamily: 'Instrument Sans',
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
            backgroundImage: AppAssets.btnCalculateCta,
            height: 48.h,
            onPressed: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBmiCard(BMIRecord record) {
    final formattedTime = DateFormat('Today, h:mm a').format(record.date);

    return CustomCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: 22.r,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: "Your BMI", Large value, Category badge
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      record.bmiValue.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1DB59B),
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        record.category.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: record.category.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center-Right: Gauge & Last Updated / View History
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last Updated',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.history),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 10.sp,
                                  color: AppColors.primaryTeal,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'View History',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    BMIGaugeWidget(
                      bmiValue: record.bmiValue,
                      size: 150.w,
                      showLabels: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Bottom Health Banner
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.healthInsights),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFD4EFE6)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.shield_lefthalf_fill,
                    size: 16.sp,
                    color: const Color(0xFF1DB59B),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      record.category.feedbackMessage,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    CupertinoIcons.arrow_right,
                    size: 14.sp,
                    color: const Color(0xFF1DB59B),
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
            icon: Icons.scale,
            iconBg: const Color(0xFFD3F4EA),
            iconColor: const Color(0xFF0F766E),
            value: '${record.weightKg.toStringAsFixed(1)} kg',
            label: 'Weight',
            onTapUpdate: () => Get.toNamed(AppRoutes.addWeight),
          ),
          _buildDivider(),
          _buildParamItem(
            icon: Icons.straighten,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            value: '${record.heightCm.toStringAsFixed(0)} cm',
            label: 'Height',
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
          _buildDivider(),
          _buildParamItem(
            icon: Icons.cake_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            value: '${record.age} Yrs',
            label: 'Age',
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
          _buildDivider(),
          _buildParamItem(
            icon: Icons.person_outline,
            iconBg: const Color(0xFFCCFBF1),
            iconColor: const Color(0xFF0D9488),
            value: record.gender,
            label: 'Gender',
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
        ],
      ),
    );
  }

  Widget _buildParamItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTapUpdate,
  }) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: onTapUpdate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Update',
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w700,
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
        RichText(
          text: TextSpan(
            style: AppTypography.titleMedium.copyWith(fontSize: 15.sp),
            children: const [
              TextSpan(text: 'BMI '),
              TextSpan(
                text: 'Categories',
                style: TextStyle(color: Color(0xFF1DB59B)),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'Underweight (<18.5)',
                currentCategory == BMICategory.underweight,
                const Color(0xFFE0F2FE),
                const Color(0xFF0369A1),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildCategoryBadge(
                'Normal (18.5–24.9)',
                currentCategory == BMICategory.normal,
                const Color(0xFF1DB59B),
                Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'Overweight (25–29.9)',
                currentCategory == BMICategory.overweight,
                const Color(0xFFFEF3C7),
                const Color(0xFFB45309),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildCategoryBadge(
                'Obese (30–34.9)',
                currentCategory == BMICategory.obese,
                const Color(0xFFFEE2E2),
                const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(
    String text,
    bool isCurrent,
    Color activeBg,
    Color textColor,
  ) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: isCurrent ? activeBg : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCurrent ? Colors.transparent : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: isCurrent ? textColor : const Color(0xFF64748B),
          ),
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
