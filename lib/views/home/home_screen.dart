import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
import '../widgets/ads/interstitial_ad_manager.dart';
import '../widgets/app_background.dart';
import '../insights/nutrition_screens.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_card.dart';
import '../widgets/animated_cta_button.dart';
import '../widgets/custom_gradient_button.dart';
import '../widgets/language_button.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/rtl.dart';
import '../../core/utils/responsive.dart';
import '../widgets/cta_arrow_lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      QuickActionsService.instance.consumePendingAction();
      await InterstitialAdManager.instance.whenAdClosed();
      if (!mounted) return;
      NotificationService.instance.requestPermission();
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
            Positioned.fill(
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

                  Widget art = Image.asset(
                    bgImage,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topRight,
                  );
                  if (isTablet(context)) {
                    art = ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) => const LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.0, 0.5],
                      ).createShader(rect),
                      child: art,
                    );
                  }
                  Widget artBox() => MirrorOnRtl(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(width: 375.w, child: art),
                    ),
                  );

                  final artTop = isTablet(context)
                      ? 10.h + MediaQuery.paddingOf(context).top - 44.h
                      : MediaQuery.paddingOf(context).top;
                  final gap = math.max(0.0, artTop);
                  return Stack(
                    children: [
                      if (gap > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: gap + 1,
                          child: ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: Transform.scale(
                                alignment: Alignment.topCenter,
                                scaleX: 1,
                                scaleY: (gap + 1) / 2,
                                child: artBox(),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: artTop,
                        child: artBox(),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // Main Screen Content
            SafeArea(
              child: ScrollOnShortPhones(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          // Nudged up without moving the content below.
                          Transform.translate(
                            offset: Offset(0, -8.h),
                            child: _buildTopBar(),
                          ),
                          SizedBox(height: 28.h),
                          Obx(() {
                            final hasData = bmiController.bmiHistory.isNotEmpty;
                            return _buildGreeting(
                              hasData,
                              profileController,
                              bmiController.latestRecord.value?.category,
                            );
                          }),
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
                            padding: EdgeInsets.fromLTRB(
                              18.w,
                              24.h,
                              18.w,
                              isPremium ? 145.h : 24.h,
                            ),
                            child: Column(
                              mainAxisAlignment: isPremium
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
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

                        final profile = profileController.userProfile.value;
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(18.w, 2.h, 18.w, 14.h),
                          child: _buildDashboard(latest, profile),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final ProfileController profileController = Get.find<ProfileController>();
    final size = 48.w;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          label: 'profile'.tr,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Obx(() {
              final imgPath = profileController.profileImagePath.value;
              return Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9F5EC),
                ),
                child: imgPath != null
                    ? ClipOval(
                        child: Image.file(
                          File(imgPath),
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _tintedSvg(AppAssets.dashProfile, 24.w, _navy),
              );
            }),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPremiumButton(size),
            SizedBox(width: 10.w),
            LanguageButton(size: 40.w),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumButton(double size) {
    return Obx(() {
      final appController = Get.find<AppController>();
      if (appController.isPremium.value) {
        return const SizedBox.shrink();
      }
      return Semantics(
        button: true,
        label: 'upgrade_to_premium'.tr,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.toNamed(AppRoutes.paywall),
          child: Container(
            width: 38.w,
            height: 38.w,
            alignment: AlignmentDirectional.centerEnd,
            child: Transform.translate(
              offset: Offset(0, -3.5.w),
              child: Lottie.asset(
                AppAssets.premiumLottie,
                width: 38.w,
                height: 38.w,
                fit: BoxFit.contain,
                alignment: AlignmentDirectional.centerEnd,
              ),
            ),
          ),
        ),
      );
    });
  }

  String _categoryHeadline(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return 'bmi_in_underweight_range'.tr;
      case BMICategory.normal:
        return 'bmi_in_normal_range'.tr;
      case BMICategory.overweight:
        return 'bmi_in_overweight_range'.tr;
      case BMICategory.obese:
        return 'bmi_in_obese_range'.tr;
    }
  }

  Widget _buildGreeting(
    bool hasData,
    ProfileController profileController,
    BMICategory? category,
  ) {
    final userName = profileController.userProfile.value.homeDisplayName;
    final greeting = userName.isNotEmpty
        ? 'hello_name'.trParams({'name': '\u2068$userName\u2069'})
        : 'hello_guest'.tr;
    final dashboard = hasData && category != null;

    return ConstrainedBox(
      // Keeps long names and long translations clear of the avatar art.
      constraints: BoxConstraints(maxWidth: dashboard ? 215.w : 260.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Text Section
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    greeting,
                    maxLines: 1,
                    style: TextStyle(
                      color: dashboard ? _navy : const Color(0xFF63C9B7),
                      fontSize: dashboard ? 28.sp : 24.sp,
                      fontFamily: dashboard ? 'Outfit' : 'Instrument Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text('👋', style: TextStyle(fontSize: dashboard ? 26.sp : 24.sp)),
            ],
          ),
          SizedBox(height: dashboard ? 10.h : 8.h),
          SizedBox(
            width: dashboard ? null : 240.w,
            child: Text(
              dashboard
                  ? _categoryHeadline(category)
                  : 'welcome_lets_begin_your_health_journey'.tr,
              style: dashboard
                  ? TextStyle(
                      color: _navy.withValues(alpha: 0.7),
                      fontSize: 15.sp,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    )
                  : TextStyle(
                      color: AppPalette.textSecondary,
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
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
            'no_bmi_record_yet'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 18.sp,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            'you_havent_calculated_your_bmi_yet'.tr,
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
            text: 'calculate_your_bmi'.tr,
            leadingIcon: Image.asset(
              AppAssets.calcilatorIcon,
              width: 18.w,
              height: 18.w,
            ),
            gradient: AppColors.ctaGradient,
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

  // ── Calculated state (BMI dashboard design) ──

  static const Color _navy = Color(0xFF1D2B3A);
  static const Color _muted = Color(0xFF64748B);

  /// Gauge card, meal plan card and health profile card.
  Widget _buildDashboard(BMIRecord record, UserProfile profile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBmiSummaryCard(record),
        SizedBox(height: 14.h),
        _buildMealPlanCard(),
        SizedBox(height: 14.h),
        _buildHealthProfileCard(record, profile),
      ],
    );
  }

  /// Gauge segment colours (match the `guagae.webp` arc), by category.
  static const Map<BMICategory, Color> _gaugeColors = {
    BMICategory.underweight: Color(0xFF5EC2EA),
    BMICategory.normal: Color(0xFF36D3AB),
    BMICategory.overweight: Color(0xFFFF8C00),
    BMICategory.obese: Color(0xFFFF2020),
  };

  Widget _buildBmiSummaryCard(BMIRecord record) {
    final color = record.category.color;
    return CustomCard(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 12.h),
      borderRadius: 24.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'your_bmi'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _navy,
              fontSize: 22.sp,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Center(
            child: BMIGaugeWidget(
              bmiValue: record.bmiValue,
              size: 160.w,
              showLabels: true,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    record.bmiValue.toStringAsFixed(1),
                    style: TextStyle(
                      color: color,
                      fontSize: 40.sp,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  record.category.label,
                  maxLines: 1,
                  style: TextStyle(
                    color: Color.lerp(color, Colors.black, 0.1),
                    fontSize: 16.sp,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Semantics(
            container: true,
            label: 'categories'.tr,
            // One line: shrinks uniformly if it doesn't fit, never wraps.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12.w,
                children: [
                  for (final c in BMICategory.values) _bmiLegendItem(c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chart-style legend entry: rounded colour swatch + category name.
  Widget _bmiLegendItem(BMICategory c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.5.w,
          height: 8.5.h,
          decoration: BoxDecoration(
            color: _gaugeColors[c],
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          c.label,
          maxLines: 1,
          style: TextStyle(
            color: _muted,
            fontSize: 12.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlanCard() {
    return CustomCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      borderRadius: 24.r,
      // Clearly visible teal outline (the card default is transparent).
      borderColor: AppColors.primaryTealLight.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(AppAssets.dashMeal, width: 30.w, height: 30.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'home_meal_plan_title'.tr,
                        maxLines: 1,
                        style: TextStyle(
                          color: _navy,
                          fontSize: 17.sp,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'meal_plan_based_on_profile'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Same look as every other CTA in the app.
          AnimatedCtaButton(
            text: 'unlock_personalized_meals'.tr,
            height: 52.h,
            width: double.infinity,
            borderRadius: BorderRadius.circular(28.r),
            gradient: AppColors.ctaGradient,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
            alignTrailingToEnd: false,
            leadingIcon: _tintedSvg(AppAssets.dashCrown, 20.w, Colors.white),
            trailingIcon: CtaArrowLottie(size: 28.w),
            onPressed: EatBalancedMealsScreen.openMealPlan,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProfileCard(BMIRecord record, UserProfile profile) {
    final weight = record.weightDisplay.replaceFirst(RegExp(r'\.0(?=\s)'), '');
    final stats = <(String, String, String)>[
      (AppAssets.dashAge, 'age'.tr, '${record.age}'),
      (
        AppAssets.dashGender,
        'gender'.tr,
        record.gender.trim().toLowerCase().tr,
      ),
      (AppAssets.dashWeight, 'weight'.tr, weight),
      (AppAssets.dashHeight, 'height'.tr, record.heightDisplay),
    ];

    return CustomCard(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 14.h),
      borderRadius: 24.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'your_health_profile'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _navy,
                    fontSize: 18.sp,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
            ],
          ),
          SizedBox(height: 12.h),
          IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      color: const Color(0xFFE2E8F0),
                    ),
                  Expanded(
                    child: _buildStat(stats[i].$1, stats[i].$2, stats[i].$3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Column(
        children: [
          SvgPicture.asset(icon, width: 24.w, height: 24.w),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: _muted,
                fontSize: 12.sp,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: _navy,
                fontSize: 14.sp,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tintedSvg(String asset, double size, Color color) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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
      label: 'remove_annoying_ads_upgrade_to_premium'.tr,
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
                color: const Color(0xFF06302B).withValues(alpha: 0.35),
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
                                  'premium_caps'.tr,
                                  style: TextStyle(
                                    color: _gold,
                                    fontSize: 10.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                // Scales down rather than truncating.
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    'remove_annoying_ads'.tr,
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
                        'enjoy_a_faster_distraction_free_experience'.tr,
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

/// Gold CTA on the premium card. Static: no pulse or shine.
class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton();

  static const Color _gold = _RemoveAdsCard._gold;
  static const Color _goldDeep = _RemoveAdsCard._goldDeep;
  static const Color _onGold = _RemoveAdsCard._onGold;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22.r);
    return Container(
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
            color: _goldDeep.withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Label centred; padded so it never runs under the arrow.
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 44.w),
              child: Text(
                'upgrade_to_premium'.tr,
                style: TextStyle(
                  color: _onGold,
                  fontSize: 16.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Arrow pinned to the end corner (left in RTL).
          PositionedDirectional(
            end: 14.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: CtaArrowLottie(size: 26.w, color: _onGold),
            ),
          ),
        ],
      ),
    );
  }
}
