import 'dart:io';
import 'dart:math' as math;

import 'package:applovin_max/applovin_max.dart';
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
import '../insights/bmi_insight_screen.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';
import '../../core/theme/app_palette.dart';

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
                    AppAssets.themed(bgImage),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        _buildTopBar(),
                        SizedBox(height: 28.h),
                        Obx(() {
                          final hasData = bmiController.bmiHistory.isNotEmpty;
                          return _buildGreeting(hasData, profileController);
                        }),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Obx(() {
                      final hasData = bmiController.bmiHistory.isNotEmpty;
                      final latest = bmiController.latestRecord.value;

                      if (!hasData || latest == null) {
                        final isPremium =
                            Get.find<AppController>().isPremium.value;
                        return Padding(
                          // Bottom clears the nav bar's raised + button.
                          padding: EdgeInsets.fromLTRB(18.w, 2.h, 18.w, 24.h),
                          child: Column(
                            children: [
                              // Shrinks on small screens; the premium card
                              // follows directly under it.
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width -
                                        36.w,
                                    child: _buildEmptyBmiCard(),
                                  ),
                                ),
                              ),
                              if (!isPremium) ...[
                                SizedBox(height: 16.h),
                                const _RemoveAdsCard(),
                              ],
                            ],
                          ),
                        );
                      }

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
                            // Main BMI Card
                            _buildActiveBmiCard(latest),
                            SizedBox(height: 8.h),

                            // Quick Parameters Pills (Weight, Height, Age, Gender)
                            _buildParameterPills(latest, bmiController),
                            SizedBox(height: 8.h),

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
                                    child: _buildBmiCategories(latest.category),
                                  ),
                                ),
                              ),
                            ),
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
            color: AppPalette.textSecondary,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBmiCard({bool showLabels = true}) {
    return CustomCard(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      borderRadius: 22.r,
      child: Column(
        children: [
          BMIGaugeWidget(bmiValue: 25.0, size: 200.w, showLabels: showLabels),
          Text(
            'No BMI Record Yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppPalette.textPrimary,
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
                      color: AppPalette.textPrimary,
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
                          color: AppPalette.textPrimary,
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
                        color: AppPalette.surfaceMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.viewHistory,
                            width: 10.w,
                            height: 10.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'View History',
                            style: TextStyle(
                              color: AppPalette.textPrimary,
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
        _FeedbackBanner(record: record),
      ],
    );
  }

  Widget _buildParameterPills(BMIRecord record, BMIController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppPalette.surfaceMint),
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
            color: AppPalette.textPrimary,
            fontSize: 12.sp,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: AppPalette.textSecondary,
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
    return Container(height: 44.h, width: 1.w, color: AppPalette.surfaceMuted);
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
                  color: AppPalette.textPrimary,
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
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'Underweight (<18.5)',
                currentCategory == BMICategory.underweight,
                inactiveBg: const Color(0xFFCDEBF8),
                activeBg: AppColors.underweight,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'Obese (30–34.9)',
                currentCategory == BMICategory.obese,
                inactiveBg: const Color(0xFFFFB1B2),
                activeBg: AppColors.obese,
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
                inactiveBg: const Color(0xFFFEDFC1),
                activeBg: AppColors.overweight,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'Normal (18.5–24.9)',
                currentCategory == BMICategory.normal,
                inactiveBg: const Color(0xFFC0ECE6),
                activeBg: AppColors.normal,
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
        // Pastel fills are light-only; dark mode tints with the category colour.
        color: isCurrent
            ? activeBg
            : AppPalette.isDark
            ? activeBg.withValues(alpha: 0.22)
            : inactiveBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: 'Outfit',
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
          color: isCurrent ? Colors.white : AppPalette.textPrimary,
        ),
      ),
    );
  }
}

/// Category feedback banner that opens the BMI insight screen. Eases in, then
/// breathes a soft category-coloured glow while its arrow nudges forward.
class _FeedbackBanner extends StatefulWidget {
  final BMIRecord record;

  const _FeedbackBanner({required this.record});

  @override
  State<_FeedbackBanner> createState() => _FeedbackBannerState();
}

class _FeedbackBannerState extends State<_FeedbackBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.record.category;
    final still = MediaQuery.disableAnimationsOf(context);

    final message = Text(
      category.feedbackMessage,
      style: TextStyle(
        color: AppPalette.textPrimary,
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        height: 1.40,
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 10.h * (1 - t)),
          child: child,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () => Get.to(() => BmiInsightScreen(record: widget.record)),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              // 0 → 1 → 0 once per cycle.
              final pulse = 0.5 - 0.5 * math.cos(t * 2 * math.pi);
              // Shine crosses during the first half, then rests.
              final shine = (t / 0.5).clamp(0.0, 1.0);
              final radius = BorderRadius.circular(16.r);

              return Transform.scale(
                scale: 1 + 0.015 * pulse,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 48.h),
                  decoration: BoxDecoration(
                    // Pastel fills are light-only; dark mode tints with the category colour.
                    color: AppPalette.isDark
                        ? category.color.withValues(alpha: 0.10)
                        : category.feedbackBackground,
                    borderRadius: radius,
                    border: Border.all(
                      color: category.color.withValues(
                        alpha: 0.15 + 0.45 * pulse,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      ...AppColors.cardShadow,
                      BoxShadow(
                        color: category.color.withValues(alpha: 0.45 * pulse),
                        blurRadius: (8 + 14 * pulse).r,
                        spreadRadius: 1.5 * pulse,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final bandWidth = width * 0.3;
                        return Stack(
                          children: [
                            if (shine < 1)
                              Positioned(
                                top: 0,
                                bottom: 0,
                                width: bandWidth,
                                left: -bandWidth + (width + bandWidth) * shine,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: const Alignment(-1, -0.4),
                                        end: const Alignment(1, 0.4),
                                        colors: [
                                          Colors.white.withValues(alpha: 0),
                                          Colors.white.withValues(
                                            alpha: AppPalette.isDark
                                                ? 0.18
                                                : 0.7,
                                          ),
                                          Colors.white.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  category.buildFeedbackIcon(size: 24.w),
                                  SizedBox(width: 10.w),
                                  Expanded(child: message),
                                  SizedBox(width: 6.w),
                                  // Arrow nudges forward with the pulse.
                                  Transform.translate(
                                    offset: Offset(7.w * pulse, 0),
                                    child: Image.asset(
                                      AppAssets.ageForward,
                                      height: 16.h,
                                      width: 16.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Shown under the empty BMI card for free users; opens the paywall.
class _RemoveAdsCard extends StatelessWidget {
  const _RemoveAdsCard();

  static const Color _gold = Color(0xFFFFC93C);
  static const Color _goldDeep = Color(0xFFFFA800);
  static const Color _onGold = Color(0xFF3D2A00);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    return Semantics(
      button: true,
      label: 'Remove annoying ads. Upgrade to Premium',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(AppRoutes.paywall),
        child: Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF06302B), Color(0xFF0B5A52), Color(0xFF0F766E)],
            ),
            border: Border.all(color: _gold.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: AppPalette.shadow(
                  const Color(0xFF06302B).withValues(alpha: 0.35),
                ),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned(
                  left: -40.w,
                  top: -40.w,
                  child: _glow(150.w, _gold.withValues(alpha: 0.20)),
                ),
                Positioned(
                  right: -30.w,
                  bottom: -50.w,
                  child: _glow(150.w, Colors.white.withValues(alpha: 0.07)),
                ),
                // Large faded crown watermark.
                Positioned(
                  right: -14.w,
                  top: -6.h,
                  child: Transform.rotate(
                    angle: 0.25,
                    child: Opacity(
                      opacity: 0.16,
                      child: Image.asset(AppAssets.crown, width: 110.w),
                    ),
                  ),
                ),
                Positioned(
                  right: 110.w,
                  top: 18.h,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 14.sp,
                    color: _gold.withValues(alpha: 0.7),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46.w,
                            height: 46.w,
                            padding: EdgeInsets.all(9.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.10),
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                            child: Image.asset(AppAssets.crown),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: _gold,
                                    fontSize: 10.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // Scales down rather than truncating.
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Remove Annoying Ads',
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19.sp,
                                      fontFamily: 'Instrument Sans',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Enjoy a faster, distraction-free experience. Track your BMI and weight with no interruptions, plus detailed reports and smart insights.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12.sp,
                          fontFamily: 'Instrument Sans',
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          AppLovinMAX.showMediationDebugger();
                        },
                        child: Text("show debuger"),
                      ),
                      const _UpgradeButton(),
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

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// Gold CTA that gently pulses and has a shine sweeping across it.
class _UpgradeButton extends StatefulWidget {
  const _UpgradeButton();

  @override
  State<_UpgradeButton> createState() => _UpgradeButtonState();
}

class _UpgradeButtonState extends State<_UpgradeButton>
    with SingleTickerProviderStateMixin {
  static const Color _gold = _RemoveAdsCard._gold;
  static const Color _goldDeep = _RemoveAdsCard._goldDeep;
  static const Color _onGold = _RemoveAdsCard._onGold;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honour the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22.r);
    final label = Text(
      'Upgrade to Premium',
      style: TextStyle(
        color: _onGold,
        fontSize: 14.sp,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // 0 → 1 → 0 once per cycle.
        final pulse = 0.5 - 0.5 * math.cos(t * 2 * math.pi);
        // Shine crosses during the first half, then rests.
        final shine = (t / 0.5).clamp(0.0, 1.0);

        return Transform.scale(
          scale: 1 + 0.03 * pulse,
          child: Container(
            width: double.infinity,
            height: 46.h,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE08A), _gold, _goldDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: _goldDeep.withValues(alpha: 0.3 + 0.3 * pulse),
                  blurRadius: (8 + 8 * pulse).r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final bandWidth = width * 0.35;
                  return Stack(
                    children: [
                      if (shine < 1)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          width: bandWidth,
                          left: -bandWidth + (width + bandWidth) * shine,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(-1, -0.4),
                                end: const Alignment(1, 0.4),
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.6),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            label,
                            SizedBox(width: 2.w),
                            // Arrow nudges forward with the pulse.
                            Transform.translate(
                              offset: Offset(3.w * pulse, 0),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: _onGold,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
