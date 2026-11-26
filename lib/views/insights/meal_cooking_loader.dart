import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/meal_plan_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../meal_setup/meal_setup_flow.dart';
import 'insight_common.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kTeal = AppColors.primaryTeal;
const Color _kTealLight = AppColors.primaryTealLight;

class MealCookingLoader extends StatefulWidget {
  final int week;

  /// Set once the week's meals have arrived: the bar fills to 100%, the
  /// "ready" line shows, then [onFinished] is called so the plan can appear.
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
  late List<String> _ingredients;

  /// Loader time when [MealCookingLoader.done] arrived, and the bar's
  /// progress at that moment (it fills from there to 100%).
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

    // Never throw something into the pot the user can't or won't eat.
    final dislikes = r?.dislikes ?? const <String>[];
    final banned = <String>{
      if (allergyKeys.contains('shellfish')) 'shrimp',
      if (allergyKeys.contains('fish')) 'salmon',
      if (allergyKeys.contains('eggs')) ...['egg', 'pancake'],
      if (allergyKeys.contains('dairy')) ...['yogurt', 'smoothie'],
      if (allergyKeys.contains('gluten') ||
          conditionKeys.contains('celiac')) ...[
        'wrap',
        'pancake',
      ],
      if (hasDiet || dislikes.contains('meat')) ...[
        'chicken',
        'salmon',
        'shrimp',
      ],
      if (diet == 'vegan') ...['egg', 'yogurt', 'pancake', 'smoothie'],
      if (dislikes.contains('seafood')) ...['salmon', 'shrimp'],
    };
    _ingredients = [
      for (final b in _Kitchen.badges)
        if (!banned.contains(b)) 'assets/images/badges/$b.webp',
    ];
    if (_ingredients.isEmpty) {
      _ingredients = ['assets/images/badges/salad.webp'];
    }
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
          builder: (context, _) {
            final t = _seconds;
            return Column(
              children: [
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: _Kitchen(
                    // With reduced motion the pot stands still.
                    t: still ? 0.6 : t,
                    animate: !still,
                    ingredients: _ingredients,
                  ),
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

/// Positions shared by the painter and the flying ingredient pictures.
class _Geo {
  _Geo(this.size);
  final Size size;

  static const double period = 8.0;
  static const int slots = 10;
  static const double gap = 0.8;
  static const double flight = 1.15;

  double get w => size.width;
  double get h => size.height;
  double get cx => w / 2;
  double get potW => math.min(w * 0.5, h * 0.68);
  double get potH => potW * 0.58;
  double get mouthY => h * 0.47;
  double get bottomY => mouthY + potH;
  double get ingredientSize => potW * 0.3;
  double flightU(int k, double t) {
    if (t < k * gap) return -1;
    return ((t - k * gap) % period) / flight;
  }

  /// Arc from the side of the stove, up high, down into the pot.
  Offset flightPos(int k, double u) {
    final fromLeft = k.isEven;
    final start = Offset(fromLeft ? w * 0.06 : w * 0.94, h * 0.92);
    final ctrl = Offset(
      fromLeft ? cx - potW * 0.55 : cx + potW * 0.55,
      -h * 0.25,
    );
    final end = Offset(cx + (fromLeft ? -1 : 1) * potW * 0.08, mouthY - 4);
    final a = (1 - u) * (1 - u), b = 2 * (1 - u) * u, c = u * u;
    return start * a + ctrl * b + end * c;
  }
}

class _Kitchen extends StatelessWidget {
  final double t;
  final bool animate;
  final List<String> ingredients;
  const _Kitchen({
    required this.t,
    required this.animate,
    required this.ingredients,
  });

  static const badges = [
    'avocado',
    'chicken',
    'curry',
    'egg',
    'oats',
    'pancake',
    'salad',
    'salmon',
    'shrimp',
    'smoothie',
    'soup',
    'wrap',
    'yogurt',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final g = _Geo(Size(box.maxWidth, box.maxHeight));
        final loop = (t / _Geo.period).floor();
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _KitchenPainter(t, g))),
            if (animate)
              for (int k = 0; k < _Geo.slots; k++)
                ..._flying(
                  g,
                  k,
                  ingredients[(k + loop * 3) % ingredients.length],
                ),
          ],
        );
      },
    );
  }

  List<Widget> _flying(_Geo g, int k, String asset) {
    final u = g.flightU(k, t);
    if (u < 0 || u > 1) return const [];
    final pos = g.flightPos(k, u);
    final s = g.ingredientSize * (1 - 0.45 * u);
    final spin = (k.isEven ? 1 : -1) * u * math.pi * 2;
    return [
      Positioned(
        left: pos.dx - s / 2,
        top: pos.dy - s / 2,
        width: s,
        height: s,
        child: Opacity(
          opacity: u < 0.85 ? 1 : ((1 - u) / 0.15).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: spin,
            child: Image.asset(asset, gaplessPlayback: true),
          ),
        ),
      ),
    ];
  }
}

/// Stove, pot (with a face), soup, splashes, lid, steam and sparkles.
class _KitchenPainter extends CustomPainter {
  _KitchenPainter(this.t, this.g);
  final double t;
  final _Geo g;

  @override
  void paint(Canvas canvas, Size size) {
    double impact = 0;
    double? lookX;
    for (int k = 0; k < _Geo.slots; k++) {
      final u = g.flightU(k, t);
      if (u >= 1 && u <= 1.35) {
        impact = math.max(impact, math.sin((u - 1) / 0.35 * math.pi));
      }
      if (u >= 0 && u < 1) lookX = g.flightPos(k, u).dx;
    }

    _glow(canvas);
    _sparkles(canvas);
    _stove(canvas);
    canvas.save();
    canvas.translate(0, impact * g.potH * 0.06);
    _pot(canvas, impact, lookX);
    _soup(canvas);
    _splashes(canvas);
    canvas.restore();
    _lid(canvas, impact);
    _steam(canvas);
  }

  void _glow(Canvas canvas) {
    final pulse = 0.5 + 0.5 * math.sin(t * 2.4);
    final center = Offset(g.cx, g.mouthY + g.potH * 0.3);
    final r = g.potW * (0.8 + 0.06 * pulse);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _kTealLight.withValues(alpha: 0.3),
            _kTealLight.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  void _sparkles(Canvas canvas) {
    const spots = [
      Offset(0.14, 0.2),
      Offset(0.86, 0.28),
      Offset(0.22, 0.6),
      Offset(0.8, 0.68),
      Offset(0.62, 0.08),
    ];
    for (int i = 0; i < spots.length; i++) {
      final s = math.pow(math.max(0.0, math.sin(t * 2.2 + i * 1.3)), 3);
      if (s < 0.02) continue;
      final c = Offset(spots[i].dx * g.w, spots[i].dy * g.h);
      final r = g.potW * 0.07 * s;
      final star = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r);
      canvas.drawPath(
        star,
        Paint()..color = i.isEven ? const Color(0xFFFFC94D) : _kTeal,
      );
    }
  }

  void _stove(Canvas canvas) {
    final base = g.bottomY + g.potH * 0.32;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(g.cx, base + 4),
          width: g.potW * 0.95,
          height: 7,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    const n = 5;
    for (int i = 0; i < n; i++) {
      final x = g.cx + (i - (n - 1) / 2) * g.potW * 0.16;
      final flick = math.sin(t * 13 + i * 1.7) * 0.5 + 0.5;
      final h = g.potH * (0.22 + 0.12 * flick);
      final w = g.potW * 0.05;
      _flame(canvas, Offset(x, base), h, w, const Color(0xFFFF8A3D));
      _flame(
        canvas,
        Offset(x, base),
        h * 0.55,
        w * 0.55,
        const Color(0xFFFFD45C),
      );
    }
  }

  void _flame(Canvas canvas, Offset base, double h, double w, Color color) {
    final p = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - w * 1.6,
        base.dy - h * 0.35,
        base.dx,
        base.dy - h,
      )
      ..quadraticBezierTo(
        base.dx + w * 1.6,
        base.dy - h * 0.35,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  Rect get _rim => Rect.fromCenter(
    center: Offset(g.cx, g.mouthY),
    width: g.potW,
    height: g.potW * 0.22,
  );

  void _pot(Canvas canvas, double impact, double? lookX) {
    final cx = g.cx, w = g.potW, top = g.mouthY, bottom = g.bottomY;

    final handle = Paint()..color = _kDeep;
    for (final side in [-1.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + side * (w / 2 + w * 0.05), top + g.potH * 0.22),
            width: w * 0.16,
            height: w * 0.07,
          ),
          Radius.circular(w * 0.04),
        ),
        handle,
      );
    }

    final body = Path()
      ..moveTo(cx - w / 2, top)
      ..lineTo(cx - w * 0.46, bottom - w * 0.1)
      ..quadraticBezierTo(cx - w * 0.45, bottom, cx - w * 0.34, bottom)
      ..lineTo(cx + w * 0.34, bottom)
      ..quadraticBezierTo(
        cx + w * 0.45,
        bottom,
        cx + w * 0.46,
        bottom - w * 0.1,
      )
      ..lineTo(cx + w / 2, top)
      ..arcTo(_rim, 0, math.pi, false)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14B88C), _kDeep],
        ).createShader(Rect.fromLTRB(cx - w / 2, top, cx + w / 2, bottom)),
    );
    // Shine down the left side.
    canvas.drawLine(
      Offset(cx - w * 0.38, top + g.potH * 0.3),
      Offset(cx - w * 0.36, bottom - w * 0.14),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round,
    );
    _face(canvas, impact, lookX);
  }

  void _face(Canvas canvas, double impact, double? lookX) {
    final cx = g.cx, w = g.potW;
    final eyeY = g.mouthY + g.potH * 0.48;
    final ink = Paint()..color = const Color(0xFF0B2E24);
    final happy = impact > 0.25;
    final blink = (t % 3.4) < 0.12;
    final look = lookX == null
        ? 0.0
        : ((lookX - cx) / (g.w / 2)).clamp(-1.0, 1.0);

    for (final side in [-1.0, 1.0]) {
      final c = Offset(cx + side * w * 0.15, eyeY);
      if (happy) {
        final arc = Path()
          ..moveTo(c.dx - w * 0.045, c.dy + w * 0.015)
          ..quadraticBezierTo(
            c.dx,
            c.dy - w * 0.05,
            c.dx + w * 0.045,
            c.dy + w * 0.015,
          );
        canvas.drawPath(
          arc,
          Paint()
            ..color = ink.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.025
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: c,
            width: w * 0.065,
            height: blink ? w * 0.012 : w * 0.075,
          ),
          ink,
        );
        if (!blink) {
          canvas.drawCircle(
            c + Offset(look * w * 0.014 - w * 0.008, -w * 0.018),
            w * 0.013,
            Paint()..color = Colors.white,
          );
        }
      }
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(side * w * 0.075, w * 0.055),
          width: w * 0.07,
          height: w * 0.04,
        ),
        Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: 0.55),
      );
    }

    // Smile that opens wide when an ingredient lands.
    final my = eyeY + w * 0.07;
    final open = w * (0.03 + 0.05 * impact);
    final mouth = Path()
      ..moveTo(cx - w * 0.06, my)
      ..quadraticBezierTo(cx, my + open * 2, cx + w * 0.06, my)
      ..close();
    canvas.drawPath(mouth, ink);
  }

  void _soup(Canvas canvas) {
    final w = g.potW;
    final soup = _rim.deflate(w * 0.03);
    canvas.drawOval(
      soup,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFF6FE7C8), _kTeal])
            .createShader(soup),
    );
    for (int i = 0; i < 7; i++) {
      final b = (t * 0.9 + i / 7) % 1.0;
      final c = Offset(
        g.cx + math.sin(i * 2.3) * w * 0.32,
        g.mouthY - b * w * 0.05 + math.cos(i * 1.7) * w * 0.03,
      );
      final r = w * (0.012 + 0.03 * b);
      canvas.drawCircle(
        c,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.65 * (1 - b)),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _kDeep.withValues(alpha: 0.25 * (1 - b)),
      );
    }
    canvas.drawOval(
      _rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04
        ..color = const Color(0xFF0E9C77),
    );
  }

  void _splashes(Canvas canvas) {
    for (int k = 0; k < _Geo.slots; k++) {
      final u = g.flightU(k, t);
      if (u < 1 || u > 1.35) continue;
      final v = (u - 1) / 0.35;
      final origin = g.flightPos(k, 1);
      for (int d = 0; d < 6; d++) {
        final ang = -math.pi * (0.15 + 0.7 * d / 5);
        final dist = g.potW * (0.06 + 0.28 * v);
        final p =
            origin +
            Offset(
              math.cos(ang) * dist,
              math.sin(ang) * dist + g.potW * 0.35 * v * v,
            );
        canvas.drawCircle(
          p,
          g.potW * 0.025 * (1 - v),
          Paint()..color = _kTealLight.withValues(alpha: 1 - v),
        );
      }
    }
  }

  /// Lid hovers and rattles on the steam, and jumps when something lands.
  void _lid(Canvas canvas, double impact) {
    final w = g.potW;
    final hop = math.sin(t * math.pi * 2 * 1.6).abs();
    final lift = g.potH * (0.28 + 0.08 * hop + 0.3 * impact);
    final tilt = 0.14 * math.sin(t * math.pi * 2 * 2.2) + 0.25 * impact;
    final lidW = w * 1.02, lidH = w * 0.2;

    canvas.save();
    canvas.translate(g.cx, g.mouthY - lift);
    canvas.rotate(tilt);
    final dome = Path()
      ..moveTo(-lidW / 2, 0)
      ..quadraticBezierTo(0, -lidH * 1.6, lidW / 2, 0)
      ..close();
    canvas.drawPath(
      dome,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1FCB9C), Color(0xFF0B8A66)],
        ).createShader(Rect.fromLTWH(-lidW / 2, -lidH, lidW, lidH)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: lidW * 1.04,
          height: w * 0.045,
        ),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = _kDeep,
    );
    canvas.drawCircle(
      Offset(0, -lidH * 0.85),
      w * 0.045,
      Paint()..color = _kDeep,
    );
    canvas.drawCircle(
      Offset(-w * 0.012, -lidH * 0.85 - w * 0.012),
      w * 0.014,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.restore();
  }

  void _steam(Canvas canvas) {
    final w = g.potW;
    for (int i = 0; i < 3; i++) {
      final s = (t * 0.55 + i / 3) % 1.0;
      final x0 = g.cx + (i - 1) * w * 0.3;
      final start = g.mouthY - g.potH * 0.7 - s * g.h * 0.12;
      final path = Path();
      const steps = 14;
      for (int j = 0; j <= steps; j++) {
        final f = j / steps;
        final y = start - f * g.h * 0.08;
        final x = x0 + math.sin(f * math.pi * 2 + t * 3 + i) * w * 0.05;
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.035
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF8FD9C3)
              .withValues(alpha: 0.6 * math.sin(s * math.pi)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _KitchenPainter old) =>
      old.t != t || old.g.size != g.size;
}
