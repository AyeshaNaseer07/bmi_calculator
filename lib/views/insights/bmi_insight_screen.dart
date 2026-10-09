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
  final double imageAspect;
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
    required this.imageAspect,
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
      return const _Variant(
        screenTitle: 'Maintain Your BMI',
        planTitle: 'How to Maintain Your BMI',
        chip: 'NORMAL',
        chipBg: Color(0xFFE3F8F1),
        chipFg: Color(0xFF09B389),
        range: '18.5 – 24.9',
        message: 'Keep up your healthy routine!',
        messageColor: Color(0xFF09B389),
        image: AppAssets.insightNormal,
        imageAspect: 1065 / 456,
        weightColor: Color(0xFF09B389),
        barBg: Color(0xFFE3F8F1),
        barFill: Color(0xFF09B389),
        barText: Color(0xFF09B389),
        whyBorder: kMintBorder,
      );
    case BMICategory.underweight:
      return const _Variant(
        screenTitle: 'Improve Your BMI',
        planTitle: 'Your Healthy Weight Plan',
        chip: 'UNDERWEIGHT',
        chipBg: Color(0xFFE3F1FB),
        chipFg: Color(0xFF0A8FD6),
        range: 'Below 18.5',
        message: 'Your BMI is below the healthy range.',
        messageColor: Color(0xFF0A8FD6),
        image: AppAssets.insightUnder,
        imageAspect: 1065 / 500,
        weightColor: Color(0xFF0A8FD6),
        barBg: Color(0xFFD3ECFA),
        barFill: Color(0xFF1B7FC4),
        barText: Color(0xFF0A6FB0),
        whyBorder: Color(0xFFD3E8F8),
        gain: true,
        whyTitle: 'Why You May Be Underweight?',
        whyBullets: [
          'Not getting enough calories or nutrients',
          'Skipping meals or having a low appetite',
          'High physical activity without enough food',
          'Stress or lifestyle changes',
          'Certain health conditions can also affect weight',
        ],
      );
    case BMICategory.overweight:
      return const _Variant(
        screenTitle: 'Improve Your BMI',
        planTitle: 'How to Improve Your BMI',
        chip: 'OVERWEIGHT',
        chipBg: Color(0xFFFFEFC2),
        chipFg: Color(0xFFB45309),
        range: '25.0–29.9',
        message: 'Your BMI is above the healthy range.',
        messageColor: Color(0xFF9A4A0C),
        image: AppAssets.insightOver,
        imageAspect: 1065 / 510,
        weightColor: Color(0xFF9A4A0C),
        barBg: Color(0xFFFFEFC2),
        barFill: Color(0xFF8A3B0E),
        barText: Color(0xFF7A3A0A),
        whyBorder: Color(0xFFD3E8F8),
        whyTitle: 'Why You May Be Overweight?',
        whyBullets: [
          'Eating more calories than your body needs.',
          'Lack of regular physical activity.',
          'Consuming too many sugary or processed foods.',
          'Poor sleep and high stress.',
          'Hormonal changes or certain medical conditions.',
        ],
      );
    case BMICategory.obese:
      return const _Variant(
        screenTitle: 'Improve Your BMI',
        planTitle: 'How to Improve Your BMI',
        chip: 'OBESE',
        chipBg: Color(0xFFFDE4E4),
        chipFg: Color(0xFFC01818),
        range: '30 and above',
        message: 'Your BMI is above the healthy range.',
        messageColor: Color(0xFFC01818),
        image: AppAssets.insightObese,
        imageAspect: 1056 / 537,
        weightColor: Color(0xFFE11D1D),
        barBg: Color(0xFFFCCFCF),
        barFill: Color(0xFFB91C1C),
        barText: Color(0xFFB91C1C),
        whyBorder: Color(0xFFF8D4D4),
        whyTitle: 'Why You’re in the Obese Range?',
        whyBullets: [
          'Weight is high compared to your height.',
          'Low physical activity can contribute to weight gain.',
          'Eating habits, sleep, genetics, and other factors may also play a role.',
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
                        'Your Weight Progress',
                        style: TextStyle(
                          color: const Color(0xFF141B2B),
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.13,
                          letterSpacing: 0.14,
                        ),
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
    return AspectRatio(
      aspectRatio: v.imageAspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(v.image, fit: BoxFit.cover),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 0, 80.w, 25.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip: ● NORMAL
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
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
                      SizedBox(height: 10.h),

                      // Range: 18.5 – 24.9
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(v.range, style: headStyle(32)),
                      ),
                      SizedBox(height: 10.h),

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
                );
              },
            ),
          ),
        ],
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
          Text(label, style: headStyle(12, weight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: text ?? kg.round().toString(),
                  style: headStyle(24, color: color),
                ),
                TextSpan(
                  text: ' kg',
                  style: headStyle(12, color: color, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return InsightCard(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              weightCol(
                'Current Weight',
                current,
                v.weightColor,
                CrossAxisAlignment.start,
              ),
              Image.asset(AppAssets.insightRise, width: 38.w, height: 38.w),
              weightCol(
                isNormal ? 'Healthy Range' : 'Healthy Target',
                target,
                const Color(0xFF09B389),
                CrossAxisAlignment.end,
                text: isNormal ? _healthyRangeText() : null,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (isNormal)
            Container(
              width: double.infinity,
              height: 28.h,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: const Color(0x1E33D2AB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Text(
                'You’re in the healthy BMI range',
                style: TextStyle(
                  color: const Color(0xFF09B389),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.17,
                  letterSpacing: 0.44,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: v.barBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Text(
                    '${v.gain ? '+' : '−'} $diff kg to healthy',
                    style: bodyStyle(
                      12,
                      color: v.barText,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Stack(
                        children: [
                          Container(height: 6.h, color: Colors.white),
                          FractionallySizedBox(
                            widthFactor: fill,
                            child: Container(height: 6.h, color: v.barFill),
                          ),
                        ],
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
                  title: 'Eat Balanced Meals',
                  subtitle: 'Choose balanced, nutritious foods.',
                  onTap: () => Get.to(() => const EatBalancedMealsScreen()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _TipCard(
                  icon: AppAssets.tipHydrated,
                  tile: const Color(0xFFEAF1FD),
                  title: 'Stay Hydrated',
                  subtitle: 'Drink enough water daily.',
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
                  title: 'Stay Active',
                  subtitle: 'Move your body every day.',
                  onTap: () => Get.to(() => const StayActiveScreen()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _TipCard(
                  icon: AppAssets.tipSleep,
                  tile: const Color(0xFFEBEEFD),
                  title: 'Sleep Well',
                  subtitle:
                      'Aim for ${PersonalTargets.sleepText(widget.record.age)} hours nightly.',
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
            color: const Color(0xFF141B2B),
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
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
                            height: 1.13,
                            letterSpacing: 0.14,
                          ),
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
                    for (final b in v.whyBullets)
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•  ', style: bodyStyle(13, color: kInk)),
                            Expanded(
                              child: Text(
                                b,
                                style: TextStyle(
                                  color: const Color(0xFF141B2B),
                                  fontSize: 11,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 1.36,
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
    return InsightCard(
      radius: 20,
      onTap: onTap,
      padding: EdgeInsets.all(14.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 54.h, maxWidth: 54.h),
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.38,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 11.50,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
              height: 1.37,
            ),
          ),
        ],
      ),
    );
  }
}
