import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/meal_plan_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../meal_setup/meal_setup_flow.dart';
import 'insight_common.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kTeal = AppColors.primaryTeal;
const Color _kTealLight = AppColors.primaryTealLight;

class MealCookingLoader extends StatefulWidget {
  final int week;
  final bool done;
  final VoidCallback? onFinished;

  const MealCookingLoader({
    super.key,
    required this.week,
    this.done = false,
    this.onFinished,
  });

  @override
  State<MealCookingLoader> createState() => _MealCookingLoaderState();
}

class _MealCookingLoaderState extends State<MealCookingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  /// Ticker time when the current week's animation started.
  Duration _origin = Duration.zero;

  double get _seconds =>
      ((_ticker.lastElapsedDuration ?? Duration.zero) - _origin)
          .inMicroseconds /
      1e6;

  /// Seconds each headline stays on screen.
  static const double _lineSeconds = 2.6;

  /// Seconds the bar takes to fill once the meals are ready.
  static const double _fillSeconds = 0.7;

  /// Seconds the full bar and "ready" line stay before the plan appears.
  static const double _holdSeconds = 0.6;

  late List<(String, String)> _lines;
  late List<(String, String)> _chips;

  double? _doneAt;
  double _doneFrom = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _buildCopy();
    _ticker.addListener(_checkFinished);
    if (widget.done) _markDone();
  }

  @override
  void didUpdateWidget(covariant MealCookingLoader old) {
    super.didUpdateWidget(old);
    if (old.week != widget.week) {
      _origin = _ticker.lastElapsedDuration ?? Duration.zero;
      _doneAt = null;
      _finished = false;
      _buildCopy();
    }
    if (widget.done && _doneAt == null) _markDone();
  }

  @override
  void dispose() {
    _ticker.removeListener(_checkFinished);
    _ticker.dispose();
    super.dispose();
  }

  void _markDone() {
    final t = _seconds;
    _doneFrom = _progressAt(t);
    _doneAt = t;
  }

  void _checkFinished() {
    final at = _doneAt;
    if (at == null || _finished) return;
    if (_seconds >= at + _fillSeconds + _holdSeconds) {
      _finished = true;
      widget.onFinished?.call();
    }
  }

  /// Bar progress: creeps toward 95% while cooking, then fills to 100%.
  double _progressAt(double t) {
    final at = _doneAt;
    if (at == null) return 0.95 * (1 - math.exp(-t / 14));
    final f = ((t - at) / _fillSeconds).clamp(0.0, 1.0);
    return _doneFrom + (1 - _doneFrom) * Curves.easeOutCubic.transform(f);
  }

  void _buildCopy() {
    final c = MealPlanController.to;
    final r = c.planRequest;
    final week = '${widget.week}';
    final kcal = r?.targetKcal ?? c.targetKcal;
    String label(List<SetupOption> options, String key) =>
        options.firstWhereOrNull((o) => o.key == key)?.label.tr ?? key;

    final diet = r?.dietType ?? '';
    final cuisine = r?.cuisine ?? '';
    final allergyKeys = r?.allergies ?? const <String>[];
    final conditionKeys = r?.conditions ?? const <String>[];
    final allergies = [
      for (final a in allergyKeys.take(2)) label(MealSetupOptions.allergies, a),
    ];
    final conditions = [
      for (final x in conditionKeys.take(2)) label(MealSetupOptions.medical, x),
    ];
    final hasDiet = diet == 'vegetarian' || diet == 'vegan';
    final hasCuisine = cuisine.isNotEmpty && cuisine != 'other';

    _lines = [
      ('🔪', 'cook_chopping'.tr),
      ('🔥', 'cook_stove'.trParams({'week': week})),
      if (kcal > 0) ('⚖️', 'cook_balancing'.trParams({'kcal': '$kcal'})),
      if (hasCuisine)
        (
          '🌏',
          'cook_cuisine'.trParams({
            'cuisine': label(MealSetupOptions.cuisines, cuisine),
          }),
        ),
      if (hasDiet)
        (
          '🥦',
          'cook_diet'.trParams({
            'diet': label(MealSetupOptions.dietTypes, diet),
          }),
        ),
      for (final a in allergies)
        ('🚫', 'cook_leaving_out'.trParams({'item': a})),
      for (final x in conditions)
        ('❤️', 'cook_condition'.trParams({'condition': x})),
      (
        '🍲',
        'cook_simmering'.trParams({'count': '${7 * (r?.slots.length ?? 3)}'}),
      ),
      ('🥄', 'cook_tasting'.tr),
      ('🍽️', 'cook_plating'.trParams({'week': week})),
    ];

    _chips = [
      if (kcal > 0) ('⚖️', '$kcal ${'unit_kcal'.tr}'),
      if (hasDiet) ('🥦', label(MealSetupOptions.dietTypes, diet)),
      if (hasCuisine) ('🌏', label(MealSetupOptions.cuisines, cuisine)),
      for (final a in allergies) ('🚫', 'cook_chip_no'.trParams({'item': a})),
      if (conditions.isNotEmpty) ('❤️', conditions.first),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'ai_plan_creating'.tr,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppPalette.surfaceMintDeep, AppPalette.surface],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppPalette.mintBorder, width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F33D2AB),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _ticker,
          // Built once; the Lottie runs its own animation.
          child: _CookingLottie(animate: !still),
          builder: (context, lottie) {
            final t = _seconds;
            return Column(
              children: [
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  // With reduced motion the Lottie stands still.
                  child: lottie,
                ),
                SizedBox(height: 4.h),
                _headline(t),
                SizedBox(height: 12.h),
                _progress(t),
                if (_chips.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _potChips(t, still),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _headline(double t) {
    final ready = _doneAt != null;
    final i = ready ? -1 : (t / _lineSeconds).floor() % _lines.length;
    final (emoji, text) = ready
        ? ('✅', 'cook_ready'.trParams({'week': '${widget.week}'}))
        : _lines[i];
    return SizedBox(
      height: 28.h,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, a) {
          // New line rises from below, old one floats up and away.
          final incoming = child.key == ValueKey(i);
          final slide = Tween<Offset>(
            begin: Offset(0, incoming ? 0.9 : -0.9),
            end: Offset.zero,
          ).animate(a);
          return ClipRect(
            child: SlideTransition(
              position: slide,
              child: FadeTransition(opacity: a, child: child),
            ),
          );
        },
        child: Row(
          key: ValueKey(i),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: headStyle(15.5, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progress(double t) {
    final p = _progressAt(t);
    final pct = (p * 100).floor();
    final status = _doneAt != null
        ? 'cook_progress'.trParams({'pct': '$pct'})
        : t > 60
        ? 'cook_slow'.tr
        : (pct >= 90
              ? 'cook_almost'.tr
              : 'cook_progress'.trParams({'pct': '$pct'}));
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final fill = w * p;
            final pan = 22.w;
            final shine = (t * 0.7) % 1.0;
            return SizedBox(
              height: 24.h,
              child: Stack(
                clipBehavior: Clip.none,
                // Fills from the start edge, so right-to-left in ar/ur.
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Container(
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: AppPalette.surfaceMintDeep,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: SizedBox(
                      width: fill,
                      height: 10.h,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.ctaGradient,
                              ),
                            ),
                          ),
                          // Moving shine across the filled part.
                          PositionedDirectional(
                            start: shine * (fill + 40) - 40,
                            top: 0,
                            bottom: 0,
                            width: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.45),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // A little pan riding the end of the bar.
                  PositionedDirectional(
                    start: (fill - pan / 2).clamp(0.0, math.max(0.0, w - pan)),
                    child: Transform.rotate(
                      angle: math.sin(t * 7) * 0.18,
                      child: Text('🍳', style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: bodyStyle(12.5, color: _kDeep, weight: FontWeight.w700),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'week_n'.trParams({'n': '${widget.week}'}),
              style: bodyStyle(
                12,
                color: AppPalette.textSecondary,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _potChips(double t, bool still) {
    return Column(
      children: [
        Text(
          'cook_in_the_pot'.tr.toUpperCase(),
          style: bodyStyle(
            10.5,
            color: AppPalette.textSecondary,
            weight: FontWeight.w800,
          ).copyWith(letterSpacing: 1.2),
        ),
        SizedBox(height: 8.h),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            for (int i = 0; i < _chips.length; i++)
              _chip(
                _chips[i],
                // Each chip pops in a beat after the previous one.
                still ? 1.0 : ((t - 0.6 - i * 0.45) / 0.6).clamp(0.0, 1.0),
              ),
          ],
        ),
      ],
    );
  }

  Widget _chip((String, String) chip, double a) {
    final (emoji, text) = chip;
    return Opacity(
      opacity: (a * 3).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: a <= 0 ? 0.0 : Curves.elasticOut.transform(a),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppPalette.mintBorder, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: 12.sp)),
              SizedBox(width: 4.w),
              Text(
                text,
                style: bodyStyle(12, color: _kDeep, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CookingLottie extends StatelessWidget {
  final bool animate;
  const _CookingLottie({required this.animate});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AppAssets.cookingLottie,
      fit: BoxFit.contain,
      animate: animate,
      delegates: LottieDelegates(
        values: [
          // Ring behind the hat.
          ValueDelegate.strokeColor(const ['Circle', '**'], value: _kTealLight),
          // Ribbon and the recipe-book lines.
          ValueDelegate.color(const ['Ribbon', '**'], value: _kTeal),
          ValueDelegate.color(const ['Book lines', '**'], value: _kTeal),
          // Heart: light teal body, deeper teal shade.
          ValueDelegate.color(const ['Heart bg', '**'], value: _kTealLight),
          ValueDelegate.color(const ['Heart shadow', '**'], value: _kTeal),
          // Milk bottle tint.
          ValueDelegate.color(const [
            'Milk',
            'Bg',
            '**',
          ], value: AppPalette.surfaceMintDeep),
        ],
      ),
    );
  }
}
