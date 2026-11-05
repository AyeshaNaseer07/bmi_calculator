import 'dart:io';
import 'dart:math' as math;

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
import '../widgets/ads/interstitial_ad_manager.dart';
import '../widgets/app_background.dart';
import '../insights/bmi_insight_screen.dart';
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
                            // Heading sits outside the scaled-down block so it
                            // stays on the page's left edge on iPad.
                            _buildCategoriesHeading(),
                            SizedBox(height: 10.h),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.topCenter,
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
            alignment: AlignmentDirectional.centerStart,
            child: Obx(() {
              final imgPath = profileController.profileImagePath.value;
              if (imgPath != null) {
                return ClipOval(
                  child: Image.file(
                    File(imgPath),
                    width: 34.w,
                    height: 34.w,
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
          );
        }),
      ],
    );
  }

  Widget _buildGreeting(bool hasData, ProfileController profileController) {
    final userName = profileController.userProfile.value.homeDisplayName;
    final greeting = userName.isNotEmpty
        ? 'hello_name'.trParams({'name': '\u2068$userName\u2069'})
        : 'hello_guest'.tr;

    return ConstrainedBox(
      // Keeps long names and long translations clear of the avatar art.
      constraints: BoxConstraints(maxWidth: 260.w),
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
                      color: const Color(0xFF63C9B7),
                      fontSize: 24.sp,
                      fontFamily: 'Instrument Sans',

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text('👋', style: TextStyle(fontSize: 24.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 240.w,
            child: Text(
              hasData
                  ? 'lets_track_your_health_today'.tr
                  : 'welcome_lets_begin_your_health_journey'.tr,
              style: TextStyle(
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

  Widget _buildActiveBmiCard(BMIRecord record) {
    final isToday = DateUtils.isSameDay(record.date, DateTime.now());
    final formattedTime = isToday
        ? 'today_at'.trParams({
            'time': DateFormat('h:mm a').format(record.date),
          })
        : DateFormat('MMM d, h:mm a').format(record.date);
    // Tablets get a larger gauge and chip so the card isn't mostly empty.
    final tablet = isTablet(context);

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
                  Flexible(
                    child: Text(
                      'your_bmi'.tr,
                      style: TextStyle(
                        color: AppPalette.textPrimary,
                        fontSize: 18.sp,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'last_updated'.tr,
                        style: TextStyle(
                          color: const Color(0xFF96ADB0),
                          fontSize: 10.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: AppPalette.textPrimary,
                          fontSize: 10.sp,
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
                  size: tablet ? 215.w : 170.w,
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
                      fontSize: tablet ? 40.sp : 36.sp,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: tablet ? 6.h : 4.h,
                      ),
                      decoration: ShapeDecoration(
                        color: record.category.color.withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Text(
                        record.category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: record.category.color,
                          fontSize: tablet ? 14.sp : 12.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.history),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tablet ? 12.w : 8.w,
                        vertical: tablet ? 8.h : 6.h,
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
                            width: tablet ? 13.w : 10.w,
                            height: tablet ? 13.w : 10.w,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              'view_history'.tr,
                              style: TextStyle(
                                color: AppPalette.textPrimary,
                                fontSize: tablet ? 11.sp : 9.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
            label: 'weight'.tr,
            onTapUpdate: () => Get.toNamed(AppRoutes.addWeight),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.heighticon,
            value: record.heightDisplay,
            label: 'height'.tr,
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.ageicon,
            value: 'age_yrs'.trParams({'age': '${record.age}'}),
            label: 'age'.tr,
            onTapUpdate: () => Get.toNamed(AppRoutes.bmiCalculator),
          ),
          _buildDivider(),
          _buildParamItem(
            imageAsset: AppAssets.gendericon,
            value: record.gender.trim().toLowerCase().tr,
            label: 'gender'.tr,
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

  Widget _buildCategoriesHeading() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'bmi'.tr,
            style: TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 20.sp,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'categories'.tr,
            style: TextStyle(
              color: const Color(0xFF09B389),
              fontSize: 20.sp,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCategories(BMICategory currentCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'underweight_18_5'.tr,
                currentCategory == BMICategory.underweight,
                inactiveBg: const Color(0xFFCDEBF8),
                activeBg: AppColors.underweight,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'normal_18_5_24_9'.tr,
                currentCategory == BMICategory.normal,
                inactiveBg: const Color(0xFFC0ECE6),
                activeBg: AppColors.normal,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryBadge(
                'overweight_25_29_9'.tr,
                currentCategory == BMICategory.overweight,
                inactiveBg: const Color(0xFFFEDFC1),
                activeBg: AppColors.overweight,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildCategoryBadge(
                'obese_30_34_9'.tr,
                currentCategory == BMICategory.obese,
                inactiveBg: const Color(0xFFFFB1B2),
                activeBg: AppColors.obese,
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
          color: isCurrent ? Colors.white : AppPalette.textPrimary,
        ),
      ),
    );
  }
}

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
    // Larger banner on tablets so the category message reads at a glance.
    final tablet = isTablet(context);

    final message = Text(
      category.feedbackMessage,
      style: TextStyle(
        color: AppPalette.textPrimary,
        fontSize: tablet ? 15.sp : 12.sp,
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
                  constraints: BoxConstraints(minHeight: tablet ? 64.h : 48.h),
                  decoration: BoxDecoration(
                    // Pastel fills are light-only; dark mode tints with the category colour.
                    color: category.feedbackBackground,
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
                                          Colors.white.withValues(alpha: 0.7),
                                          Colors.white.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: tablet ? 18.w : 14.w,
                                vertical: tablet ? 16.h : 10.h,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  category.buildFeedbackIcon(
                                    size: tablet ? 32.w : 24.w,
                                  ),
                                  SizedBox(width: tablet ? 14.w : 10.w),
                                  Expanded(child: message),
                                  SizedBox(width: 6.w),
                                  // Arrow nudges forward with the pulse.
                                  Transform.translate(
                                    offset: Offset(
                                      7.w * pulse * dirSign(context),
                                      0,
                                    ),
                                    child: MirrorOnRtl(
                                      child: Image.asset(
                                        AppAssets.ageForward,
                                        height: tablet ? 20.h : 16.h,
                                        width: tablet ? 20.w : 16.w,
                                      ),
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
