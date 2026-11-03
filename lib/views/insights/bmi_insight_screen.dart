import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/meal_plan_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/app_background.dart';
import 'hydration_screens.dart';
import 'insight_common.dart';
import 'lifestyle_screens.dart';
import 'nutrition_screens.dart';
import 'personal_targets.dart';
import '../../core/theme/app_palette.dart';

/// Hero image proportions and where its card sits, as fractions of the
/// image width, so the text can be laid over the card.
class _HeroArt {
  final double aspect;

  const _HeroArt(this.aspect);

  double get left => 15 / 1065;
  double get top => 15 / 1065;
  double get cardHeight => 363 / 1065;
}

class _Variant {
  final String screenTitle;
  final String planTitle;
  final String chip;
  final Color chipBg;
  final Color chipFg;
  final String range;
  final String message;
  final Color messageColor;
  final String image;
  final _HeroArt art;

  final Color weightColor;
  final Color barBg;
  final Color barFill;
  final Color barText;
  final Color whyBorder;
  final String? whyTitle;
  final List<String> whyBullets;

  /// True when the healthy goal means gaining weight (underweight).
  final bool gain;

  const _Variant({
    required this.screenTitle,
    required this.planTitle,
    required this.chip,
    required this.chipBg,
    required this.chipFg,
    required this.range,
    required this.message,
    required this.messageColor,
    required this.image,
    required this.art,
    required this.weightColor,
    required this.barBg,
    required this.barFill,
    required this.barText,
    required this.whyBorder,
    this.whyTitle,
    this.whyBullets = const [],
    this.gain = false,
  });
}

_Variant _variantFor(BMICategory c) {
  switch (c) {
    case BMICategory.normal:
      return _Variant(
        screenTitle: 'maintain_your_bmi'.tr,
        planTitle: 'how_to_maintain_your_bmi'.tr,
        chip: 'normal'.tr.toUpperCase(),
        chipBg: const Color(0xFFE3F8F1),
        chipFg: Color(0xFF09B389),
        range: '18.5 – 24.9',
        message: 'keep_up_your_healthy_routine'.tr,
        messageColor: Color(0xFF09B389),
        image: AppAssets.insightNormal,
        art: _HeroArt(1065 / 456),
        weightColor: Color(0xFF09B389),
        barBg: const Color(0xFFE3F8F1),
        barFill: Color(0xFF09B389),
        barText: Color(0xFF09B389),
        whyBorder: kMintBorder,
      );
    case BMICategory.underweight:
      return _Variant(
        screenTitle: 'improve_your_bmi'.tr,
        planTitle: 'your_healthy_weight_plan'.tr,
        chip: 'underweight'.tr.toUpperCase(),
        chipBg: const Color(0xFFE3F1FB),
        chipFg: const Color(0xFF0A8FD6),
        range: 'below_18_5'.tr,
        message: 'your_bmi_is_below_the_healthy'.tr,
        messageColor: const Color(0xFF0A8FD6),
        image: AppAssets.insightUnder,
        art: _HeroArt(1065 / 507),
        weightColor: const Color(0xFF0A8FD6),
        barBg: const Color(0xFFD3ECFA),
        barFill: const Color(0xFF1B7FC4),
        barText: const Color(0xFF0A6FB0),
        whyBorder: const Color(0xFFD3E8F8),
        gain: true,
        whyTitle: 'why_you_may_be_underweight'.tr,
        whyBullets: [
          'not_getting_enough_calories_or_nutrients'.tr,
          'skipping_meals_or_having_a_low'.tr,
          'high_physical_activity_without_enough_food'.tr,
          'stress_or_lifestyle_changes'.tr,
          'certain_health_conditions_can_also_affect'.tr,
        ],
      );
    case BMICategory.overweight:
      return _Variant(
        screenTitle: 'improve_your_bmi'.tr,
        planTitle: 'how_to_improve_your_bmi'.tr,
        chip: 'overweight'.tr.toUpperCase(),
        chipBg: const Color(0xFFFFEFC2),
        chipFg: const Color(0xFFB45309),
        range: '25.0–29.9',
        message: 'your_bmi_is_above_the_healthy'.tr,
        messageColor: const Color(0xFF9A4A0C),
        image: AppAssets.insightOver,
        art: _HeroArt(1065 / 510),
        weightColor: const Color(0xFF9A4A0C),
        barBg: const Color(0xFFFFEFC2),
        barFill: const Color(0xFF8A3B0E),
        barText: const Color(0xFF7A3A0A),
        whyBorder: const Color(0xFFD3E8F8),
        whyTitle: 'why_you_may_be_overweight'.tr,
        whyBullets: [
          'eating_more_calories_than_your_body'.tr,
          'lack_of_regular_physical_activity'.tr,
          'consuming_too_many_sugary_or_processed'.tr,
          'poor_sleep_and_high_stress'.tr,
          'hormonal_changes_or_certain_medical_conditions'.tr,
        ],
      );
    case BMICategory.obese:
      return _Variant(
        screenTitle: 'improve_your_bmi'.tr,
        planTitle: 'how_to_improve_your_bmi'.tr,
        chip: 'obese'.tr.toUpperCase(),
        chipBg: const Color(0xFFFDE4E4),
        chipFg: const Color(0xFFC01818),
        range: '30.0-34.9',
        message: 'your_bmi_is_above_the_healthy'.tr,
        messageColor: const Color(0xFFC01818),
        image: AppAssets.insightObese,
        art: _HeroArt(1056 / 537),
        weightColor: Color(0xFFE11D1D),
        barBg: const Color(0xFFFCCFCF),
        barFill: const Color(0xFFB91C1C),
        barText: const Color(0xFFB91C1C),
        whyBorder: const Color(0xFFF8D4D4),
        whyTitle: 'why_youre_in_the_obese_range'.tr,
        whyBullets: [
          'weight_is_high_compared_to_your'.tr,
          'low_physical_activity_can_contribute_to'.tr,
          'eating_habits_sleep_genetics_and_other'.tr,
        ],
      );
  }
}

/// "Maintain / Improve Your BMI" screen opened from the Home banner.
class BmiInsightScreen extends StatefulWidget {
  final BMIRecord record;
  const BmiInsightScreen({super.key, required this.record});

  @override
  State<BmiInsightScreen> createState() => _BmiInsightScreenState();
}

class _BmiInsightScreenState extends State<BmiInsightScreen> {
  bool _whyOpen = false;

  @override
  void initState() {
    super.initState();
    // The weekly meal plan follows this BMI category.
    MealPlanController.to.useRecord(widget.record);
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final v = _variantFor(record.category);
    final isNormal = record.category == BMICategory.normal;

    final current = record.weightKg;
    final heightM = record.heightCm / 100;
    final target = isNormal ? current : (22.0 * heightM * heightM);
    final diff = (current - target).abs().round();
    final fill = isNormal
        ? 1.0
        : (record.category == BMICategory.underweight
                  ? (current / target)
                  : (target / current))
              .clamp(0.08, 1.0);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              InsightHeader(title: v.screenTitle),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHero(v),
                      Text(
                        'your_weight_progress'.tr,
                        style: TextStyle(
                          color: AppPalette.textPrimary,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.13,
                          letterSpacing: 0.14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.h),
                      _buildWeightCard(
                        v,
                        isNormal: isNormal,
                        current: current,
                        target: target,
                        diff: diff,
                        fill: fill,
                      ),
                      SizedBox(height: 14.h),
                      // Remaining space is shared by the tip cards.
                      Expanded(child: _buildWhyAndTips(v)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(_Variant v) {
    final art = v.art;
    return AspectRatio(
      aspectRatio: art.aspect,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cardH = w * art.cardHeight;
          final textW = w * 0.55 - 18.w;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(v.image, fit: BoxFit.cover),
              Positioned(
                left: w * art.left,
                top: w * art.top,
                height: cardH,
                width: textW + 18.w,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(18.w, 6.h, 0, 6.h),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: textW,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chip: ● NORMAL
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: v.chipBg,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: kMintBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7.w,
                                  height: 7.w,
                                  decoration: BoxDecoration(
                                    color: v.chipFg,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  v.chip,
                                  style: bodyStyle(
                                    11,
                                    color: v.chipFg,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Range: 18.5 – 24.9
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(v.range, style: headStyle(32)),
                          ),
                          SizedBox(height: 8.h),

                          // Message
                          Text(
                            v.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: bodyStyle(
                              13,
                              color: v.messageColor,
                              weight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Healthy weight range (BMI 18.5–24.9) for the user's height, e.g. `56–75`.
  String _healthyRangeText() {
    final h = widget.record.heightCm / 100;
    final lo = (18.5 * h * h).ceil();
    final hi = (24.9 * h * h).floor();
    return '$lo–$hi';
  }

  Widget _buildWeightCard(
    _Variant v, {
    required bool isNormal,
    required double current,
    required double target,
    required int diff,
    required double fill,
  }) {
    Widget weightCol(
      String label,
      double kg,
      Color color,
      CrossAxisAlignment align, {
      String? text,
    }) {
      return Column(
        crossAxisAlignment: align,
        children: [
          Text(label, style: headStyle(13, weight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: text ?? kg.round().toString(),
                  style: headStyle(24, color: color),
                ),
                TextSpan(
                  text: ' ${'unit_kg'.tr}',
                  style: headStyle(12, color: color, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      // Soft mint glow all round (no border line).
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4033D2AB),
            blurRadius: 8,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              weightCol(
                'current_weight'.tr,
                current,
                v.weightColor,
                CrossAxisAlignment.start,
              ),
              Image.asset(AppAssets.insightRise, width: 40.w, height: 40.w),
              weightCol(
                isNormal ? 'healthy_range'.tr : 'healthy_target'.tr,
                target,
                const Color(0xFF09B389),
                CrossAxisAlignment.end,
                text: isNormal ? _healthyRangeText() : null,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isNormal)
            Container(
              width: double.infinity,
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: const Color(0x1E33D2AB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Text(
                'youre_in_the_healthy_bmi_range'.tr,
                style: TextStyle(
                  color: const Color(0xFF09B389),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.17,
                  letterSpacing: 0.44,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: v.barBg,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'kg_to_healthy'.trParams({
                        'sign': v.gain ? '+' : '−',
                        'diff': '$diff',
                      }),
                      style: bodyStyle(
                        12,
                        color: v.barText,
                        weight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Rounded bar anchored to the right end of the pill.
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: FractionallySizedBox(
                        widthFactor: fill,
                        child: Container(
                          height: 7.h,
                          decoration: BoxDecoration(
                            color: v.barFill,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWhyAndTips(_Variant v) {
    final hasWhy = v.whyTitle != null;
    const collapsedH = 46.0;

    final grid = Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TipCard(
                  icon: AppAssets.mealIcon,
                  tile: const Color(0xFFE6F8EE),
                  title: 'eat_balanced_meals'.tr,
                  subtitle: 'choose_balanced_nutritious_foods'.tr,
                  onTap: () => Get.to(() => const EatBalancedMealsScreen()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _TipCard(
                  icon: AppAssets.tipHydrated,
                  tile: const Color(0xFFEAF1FD),
                  title: 'stay_hydrated'.tr,
                  subtitle: 'drink_enough_water_daily'.tr,
                  onTap: () => Get.to(() => const StayHydratedScreen()),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TipCard(
                  icon: AppAssets.tipActive,
                  tile: const Color(0xFFFFF7DC),
                  title: 'stay_active'.tr,
                  subtitle: 'move_your_body_every_day'.tr,
                  onTap: () => Get.to(() => const StayActiveScreen()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _TipCard(
                  icon: AppAssets.tipSleep,
                  tile: const Color(0xFFEBEEFD),
                  title: 'sleep_well'.tr,
                  subtitle: 'aim_for_hours_nightly'.trParams({
                    'hours': PersonalTargets.sleepText(widget.record.age),
                  }),
                  onTap: () => Get.to(() => const SleepWellScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final tips = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasWhy) SizedBox(height: collapsedH.h + 14.h),
        Text(
          v.planTitle,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontSize: 18,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            height: 1.33,
            letterSpacing: -0.18,
          ),
        ),

        SizedBox(height: 10.h),
        Expanded(child: grid),
      ],
    );

    if (!hasWhy) return tips;

    // The "Why" card floats over the tips when expanded.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: tips),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _whyOpen = !_whyOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: v.whyBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: v.whyBorder.withValues(alpha: 0.9),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          v.whyTitle!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _whyOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20.sp,
                        color: kInk,
                      ),
                    ],
                  ),
                  if (_whyOpen) ...[
                    SizedBox(height: 8.h),
                    for (int i = 0; i < v.whyBullets.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == v.whyBullets.length - 1 ? 0 : 6.h,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                color: AppPalette.textPrimary,
                                fontSize: 13.sp,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                v.whyBullets[i],
                                style: TextStyle(
                                  color: AppPalette.textPrimary,
                                  fontSize: 13.sp,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String icon;
  final Color tile;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TipCard({
    required this.icon,
    required this.tile,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subStyle = TextStyle(
      color: AppPalette.textMuted,
      fontSize: 11.50,
      fontFamily: 'Plus Jakarta Sans',
      fontWeight: FontWeight.w500,
      height: 1.37,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x4033D2AB),
              blurRadius: 8,
              offset: Offset.zero,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, c) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: c.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    icon,
                    width: 54.w,
                    height: 54.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 14.50,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.38,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Stack(
                    children: [
                      Text('\n', style: subStyle),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppPalette.textMuted,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.37,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
