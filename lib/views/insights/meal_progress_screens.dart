import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/meal_plan_controller.dart';
import 'insight_common.dart';
import 'meal_screens.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kTrack = Color(0xFFE3E8FB);

BoxDecoration _mintCard({double r = 24}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(r.r),
  border: Border.all(color: kMintBorder, width: 1.4),
  boxShadow: const [
    BoxShadow(color: Color(0x1F33D2AB), blurRadius: 8, offset: Offset(0, 2)),
  ],
);

/// "Breakfast Completed!" screen.
class MealCompletedScreen extends StatelessWidget {
  final MealInfo meal;
  const MealCompletedScreen({super.key, required this.meal});

  String get _milestone {
    switch (meal.key) {
      case 'breakfast':
        return 'MORNING MILESTONE';
      case 'lunch':
        return 'MIDDAY MILESTONE';
      default:
        return 'EVENING MILESTONE';
    }
  }

  String get _message {
    switch (meal.key) {
      case 'breakfast':
        return 'Great start! You’ve completed today’s breakfast and '
            'energized your morning.';
      case 'lunch':
        return 'Nicely done! You’ve completed today’s lunch and kept your '
            'energy steady.';
      default:
        return 'Well done! You’ve completed today’s dinner and wrapped up '
            'a balanced day.';
    }
  }

  Widget _legend(String t, bool on) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7.w,
        height: 7.w,
        decoration: BoxDecoration(
          color: on ? _kDeep : const Color(0xFFC3C8CF),
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: 5.w),
      Text(
        t,
        style: bodyStyle(
          12.5,
          color: on ? _kDeep : const Color(0xFF4B5563),
          weight: FontWeight.w700,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return InsightScaffold(
      title: '${meal.slot} Completed!',
      bottom: GradientActionButton(
        text: 'View Your Progress',
        trailing: Icons.arrow_forward_rounded,
        onTap: () => Get.to(() => const MealProgressScreen()),
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          SizedBox(
            width: 150.w,
            height: 150.w,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEDF0FC),
                    boxShadow: [
                      BoxShadow(color: Color(0x6633D2AB), blurRadius: 40),
                    ],
                  ),
                ),
                Container(
                  width: 112.w,
                  height: 112.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFBDF2DF),
                  ),
                ),
                Container(
                  width: 74.w,
                  height: 74.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kDeep,
                  ),
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 40.sp),
                ),
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: _mini(Icons.eco_rounded),
                ),
                Positioned(
                  bottom: 2.h,
                  left: 14.w,
                  child: _mini(Icons.wb_sunny_outlined),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFC9F7E3),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              _milestone,
              style: bodyStyle(12, color: _kDeep, weight: FontWeight.w800)
                  .copyWith(letterSpacing: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              _message,
              textAlign: TextAlign.center,
              style: bodyStyle(
                13.5,
                color: const Color(0xFF374151),
                height: 1.45,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Obx(() {
            final done = c.completedCount.clamp(0, 3);
            final pct = (done / 3 * 100).round();
            return Container(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              decoration: _mintCard(r: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: _kDeep,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Day 1 of 7',
                            style: bodyStyle(
                              14,
                              color: _kDeep,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8ECFB),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Clean Eating Plan',
                          style: bodyStyle(
                            12,
                            color: _kDeep,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$done meal${done == 1 ? '' : 's'} completed',
                              style: headStyle(22, weight: FontWeight.w600),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${3 - done} nutritious meal'
                              '${3 - done == 1 ? '' : 's'} remaining today',
                              style: bodyStyle(
                                13,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8ECFB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: _kDeep,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Progress',
                        style: bodyStyle(
                          13,
                          color: const Color(0xFF374151),
                          weight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: bodyStyle(
                          13,
                          color: _kDeep,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: LinearProgressIndicator(
                      value: done / 3,
                      minHeight: 8.h,
                      backgroundColor: _kTrack,
                      valueColor: const AlwaysStoppedAnimation(_kDeep),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final m in kMeals)
                        _legend(m.slot, c.isEaten(m.key)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _mini(IconData i) => Container(
    width: 24.w,
    height: 24.w,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
    ),
    child: Icon(i, size: 13.sp, color: _kDeep),
  );
}

/// "Your Progress" screen.
class MealProgressScreen extends StatelessWidget {
  const MealProgressScreen({super.key});

  Widget _statCard({
    required IconData icon,
    required Color tile,
    required Color iconColor,
    required Widget trailing,
    required String label,
    required Widget value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
        decoration: _mintCard(r: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: tile,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, size: 20.sp, color: iconColor),
                ),
                trailing,
              ],
            ),
            SizedBox(height: 10.h),
            Text(label, style: bodyStyle(13, color: kInk, weight: FontWeight.w500)),
            SizedBox(height: 2.h),
            value,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return InsightScaffold(
      title: 'Your Progress',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Consistent nourishment & balance',
                  style: bodyStyle(13.5, color: const Color(0xFF374151)),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFA9EBD4),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco_rounded, size: 14.sp, color: _kDeep),
                    SizedBox(width: 4.w),
                    Text(
                      '7-Day Living Plan',
                      style: bodyStyle(12, color: _kDeep, weight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFD6F6E8), Colors.white, Color(0xFFD6F6E8)],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A33D2AB),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 190.w,
                  height: 190.w,
                  child: CustomPaint(
                    painter: _RingPainter(3 / 7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '3 ', style: headStyle(34)),
                                TextSpan(
                                  text: '/ 7',
                                  style: headStyle(
                                    20,
                                    weight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'DAYS COMPLETED',
                            style: bodyStyle(
                              12,
                              color: const Color(0xFF374151),
                              weight: FontWeight.w700,
                            ).copyWith(letterSpacing: 0.5),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9F7E3),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: _kDeep,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  '40% Reached',
                                  style: bodyStyle(
                                    12,
                                    color: _kDeep,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_rounded, size: 18.sp, color: _kDeep),
                    SizedBox(width: 6.w),
                    Text(
                      'Day 12: Vibrant Energy Phase',
                      style: bodyStyle(
                        13.5,
                        color: const Color(0xFF1F3A34),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final logged = (9 + c.completedCount).clamp(0, 21);
            return Row(
              children: [
                _statCard(
                  icon: Icons.restaurant_rounded,
                  tile: const Color(0xFFE8ECFB),
                  iconColor: _kDeep,
                  trailing: Text(
                    'Target: 90',
                    style: bodyStyle(12.5, color: kInk, weight: FontWeight.w800),
                  ),
                  label: 'Meals Logged',
                  value: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$logged', style: headStyle(22)),
                        TextSpan(
                          text: ' / 21',
                          style: headStyle(
                            15,
                            weight: FontWeight.w500,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                _statCard(
                  icon: Icons.local_fire_department_rounded,
                  tile: const Color(0xFFFFE9E7),
                  iconColor: const Color(0xFFE5392B),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE3E0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Active',
                      style: bodyStyle(
                        12,
                        color: const Color(0xFFD62B1F),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  label: 'Current Streak',
                  value: Text(
                    '3 Days 🔥',
                    style: headStyle(22, weight: FontWeight.w600),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 14.w, 12.h),
            decoration: _mintCard(r: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC9F7E3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 17.sp,
                        color: _kDeep,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Overall Plan Progress',
                        style: bodyStyle(14, color: kInk, weight: FontWeight.w600),
                      ),
                    ),
                    Text('40%', style: headStyle(19, color: _kDeep)),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 8.h,
                    backgroundColor: _kTrack,
                    valueColor: const AlwaysStoppedAnimation(_kDeep),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day 3 of 7',
                      style: bodyStyle(
                        12.5,
                        color: const Color(0xFF374151),
                        weight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '4 Days remaining',
                      style: bodyStyle(
                        12.5,
                        color: const Color(0xFF374151),
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FCEA),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.spa_outlined, size: 22.sp, color: _kDeep),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY WISDOM',
                        style: bodyStyle(
                          11.5,
                          color: _kDeep,
                          weight: FontWeight.w800,
                        ).copyWith(letterSpacing: 0.4),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Keep going! Small daily choices build healthy habits.',
                        style: bodyStyle(
                          15,
                          color: kInk,
                          weight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = _kTrack;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [Color(0xFF006B4E), Color(0xFF2FD4A8)],
      ).createShader(rect);
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
