import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/app_background.dart';
import 'hydration_screens.dart';
import 'insight_common.dart';
import 'lifestyle_screens.dart';
import 'nutrition_screens.dart';

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
  final Color weightColor;
  final Color barBg;
  final Color barFill;
  final Color barText;
  final Color whyBorder;
  final String? whyTitle;
  final List<String> whyBullets;

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
    required this.weightColor,
    required this.barBg,
    required this.barFill,
    required this.barText,
    required this.whyBorder,
    this.whyTitle,
    this.whyBullets = const [],
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
        weightColor: Color(0xFF0A8FD6),
        barBg: Color(0xFFD3ECFA),
        barFill: Color(0xFF1B7FC4),
        barText: Color(0xFF0A6FB0),
        whyBorder: Color(0xFFD3E8F8),
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
        range: '30–34.9',
        message: 'Your BMI is above the healthy range.',
        messageColor: Color(0xFFC01818),
        image: AppAssets.insightObese,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(v),
                      SizedBox(height: 14.h),
                      Text(
                        'Your Weight Progress',
                        style: headStyle(17, weight: FontWeight.w700),
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
                      _buildWhyAndTips(v),
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
    return SizedBox(
      width: double.infinity,
      height: 174.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            v.image,
            fit: BoxFit
                .fill, // stretches to the new size, keeps the rounded border
          ),

          // Text stacked on the empty left side of the image
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Keep text out of the avatar area (~42% of the width on the right)
                final rightInset = constraints.maxWidth * 0.42;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    constraints.maxWidth * 0.06, // left
                    0,
                    rightInset,
                    0,
                  ),
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
                      SizedBox(height: 6.h),

                      // Message
                      Text(
                        v.message,
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
      CrossAxisAlignment align,
    ) {
      return Column(
        crossAxisAlignment: align,
        children: [
          Text(label, style: headStyle(12, weight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: kg.round().toString(),
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
                isNormal ? 'Ideal Weight' : 'Healthy Target',
                target,
                const Color(0xFF09B389),
                CrossAxisAlignment.end,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (isNormal)
            Container(
              width: double.infinity,
              height: 28.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kMintBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                'You’re in the healthy BMI range',
                style: bodyStyle(12, color: kGreen, weight: FontWeight.w600),
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
                    '+ $diff kg to healthy',
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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TipCard(
                  icon: AppAssets.tipMeals,
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
        IntrinsicHeight(
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
                  subtitle: 'Aim for 7\u20139 hours nightly.',
                  onTap: () => Get.to(() => const SleepWellScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final tips = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasWhy) SizedBox(height: collapsedH.h + 14.h),
        Text(v.planTitle, style: headStyle(17, weight: FontWeight.w700)),
        SizedBox(height: 10.h),
        grid,
      ],
    );

    if (!hasWhy) return tips;

    // The "Why" card floats over the tips when expanded.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tips,
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
                          style: headStyle(15, weight: FontWeight.w600),
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
                            Text('•  ', style: bodyStyle(12, color: kInk)),
                            Expanded(
                              child: Text(
                                b,
                                style: bodyStyle(
                                  12,
                                  color: kInk,
                                  weight: FontWeight.w500,
                                  height: 1.3,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(icon, fit: BoxFit.contain, height: 50.h, width: 50.w),
          SizedBox(height: 14.h),
          Text(title, style: headStyle(15, weight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text(subtitle, style: bodyStyle(12, height: 1.35)),
        ],
      ),
    );
  }
}
