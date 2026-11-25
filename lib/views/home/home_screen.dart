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
import '../widgets/custom_gradient_button.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/rtl.dart';
import '../../core/utils/responsive.dart';

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
            Positioned(
              top: isTablet(context)
                  ? 10.h + MediaQuery.paddingOf(context).top - 44.h
                  : 10.h,
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
                  return MirrorOnRtl(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(width: 375.w, child: art),
                    ),
                  );
                }),
              ),
            ),

            // Main Screen Content
            SafeArea(
              // Both the empty and the calculated state: normal phones keep
              // the fill layout, short ones (iPhone SE) scroll.
              child: ScrollOnShortPhones(
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
                            return _buildGreeting(
                              hasData,
                              profileController,
                              bmiController.latestRecord.value?.category,
                            );
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
                            padding: EdgeInsets.fromLTRB(
                              18.w,
                              2.h,
                              18.w,
                              // Premium: extra room so the centred card sits
                              // above the nav bar's overlap, not on it.
                              isPremium ? 145.h : 24.h,
                            ),
                            child: Column(
                              // Premium users have no ads card below, so centre
                              // the BMI card in the free space.
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
                        return Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 18.h),
                          // Scales down rather than overflowing on short
                          // screens.
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 32.w,
                                child: _buildDashboard(latest, profile),
                              ),
                            ),
                          ),
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
        Obx(() {
          final appController = Get.find<AppController>();
          if (appController.isPremium.value) {
            return SizedBox(width: size, height: size);
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
        }),
      ],
    );
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
    // Calculated state uses the dashboard design: navy, larger type and a
    // category headline.
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
              // Scales down rather than truncating, so long translations
              // and names stay fully readable.
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
                      color: _navy,
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

  // ── Calculated state (BMI dashboard design) ──

  static const Color _navy = Color(0xFF1D2B3A);
  static const Color _mintDeep = Color(0xFF0E7C5B);
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

  /// "Your BMI" card: title, gauge, value and category pill, with the
  /// gauge colour legend in a row along the bottom.
  Widget _buildBmiSummaryCard(BMIRecord record) {
    final color = record.category.color;
    return CustomCard(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
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
              size: 180.w,
              showLabels: true,
            ),
          ),
          SizedBox(height: 10.h),
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
                      fontSize: 44.sp,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
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
          SizedBox(height: 14.h),
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
          width: 20.w,
          height: 9.w,
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
                        'Meal Plan to Maintain Weight',
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
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: EatBalancedMealsScreen.openMealPlan,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC8F3E2), Color(0xFFDDF8EC)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tintedSvg(AppAssets.dashCrown, 20.w, _mintDeep),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        'Unlock Personalized Meals',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _mintDeep,
                          fontSize: 15.sp,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    MirrorOnRtl(
                      child: _tintedSvg(
                        AppAssets.dashArrowRight,
                        18.w,
                        _mintDeep,
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
      (AppAssets.dashGoal, 'goal'.tr, _goalShort(profile.healthGoal)),
    ];

    return CustomCard(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 14.h),
      borderRadius: 24.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Container(
              //   width: 32.w,
              //   height: 32.w,
              //   padding: EdgeInsets.all(7.w),
              //   decoration: const BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: Color(0xFFE3F7F0),
              //   ),
              //   child: _tintedSvg(AppAssets.dashProfile, 18.w, _mint),
              // ),
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
              // GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onTap: () => Get.toNamed(AppRoutes.profile),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 12.w,
              //       vertical: 6.h,
              //     ),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFF2FBF7),
              //       borderRadius: BorderRadius.circular(30.r),
              //       border: Border.all(color: const Color(0xFFBDEBDC)),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           'view_profile'.tr,
              //           style: TextStyle(
              //             color: _mint,
              //             fontSize: 12.sp,
              //             fontFamily: 'Outfit',
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         SizedBox(width: 4.w),
              //         MirrorOnRtl(
              //           child: _tintedSvg(
              //             AppAssets.dashArrowRight,
              //             14.w,
              //             _mint,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
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

  String _goalShort(HealthGoal? goal) {
    switch (goal) {
      case HealthGoal.loseWeight:
        return 'goal_short_lose'.tr;
      case HealthGoal.buildMuscle:
        return 'goal_short_build'.tr;
      case HealthGoal.maintainWeight:
        return 'goal_short_maintain'.tr;
      case HealthGoal.improveHealth:
        return 'goal_short_improve'.tr;
      case null:
        return '—';
    }
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
      'upgrade_to_premium'.tr,
      style: TextStyle(
        color: _onGold,
        fontSize: 14.sp,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
                              offset: Offset(3.w * pulse * dirSign(context), 0),
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
