import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/meal_plan_controller.dart';
import 'insight_common.dart';
import 'personal_targets.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kLav = Color(0xFFE8EBFB);

/// "Sleep Well, Live Better".
class SleepWellScreen extends StatelessWidget {
  const SleepWellScreen({super.key});

  Widget _routine(IconData icon, String title, String sub) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Container(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 12.w, 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFCFF1E5), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A33D2AB),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: _kLav,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19.sp, color: _kDeep),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: headStyle(14.5, weight: FontWeight.w700)),
                Text(
                  sub,
                  style: bodyStyle(12.5, color: const Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Sleep Well, Live Better',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 130.w,
              height: 130.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130.w,
                    height: 130.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFFBFF5DF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                  Icon(Icons.nightlight_round, size: 62.sp, color: _kDeep),
                  Positioned(
                    top: 18.h,
                    left: 22.w,
                    child: Icon(Icons.auto_awesome, size: 10.sp, color: kGreen),
                  ),
                  Positioned(
                    bottom: 18.h,
                    right: 26.w,
                    child: Icon(Icons.auto_awesome, size: 10.sp, color: kGreen),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: _kLav,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.nightlight_round, size: 13.sp, color: _kDeep),
                  SizedBox(width: 6.w),
                  Text(
                    'RESTFUL SLEEP',
                    style: bodyStyle(
                      12,
                      color: _kDeep,
                      weight: FontWeight.w800,
                    ).copyWith(letterSpacing: 0.4),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'Good sleep supports a healthy body and\nbalanced lifestyle.',
              textAlign: TextAlign.center,
              style: bodyStyle(
                15,
                color: const Color(0xFF374151),
                weight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFCFF1E5), width: 1.3),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFE2F9EF)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2633D2AB),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16.sp,
                          color: _kDeep,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'RECOMMENDED SLEEP',
                          style: bodyStyle(
                            12,
                            color: _kDeep,
                            weight: FontWeight.w800,
                          ).copyWith(letterSpacing: 0.4),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9F7E3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Optimal Rest',
                        style: bodyStyle(
                          12,
                          color: _kDeep,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${PersonalTargets.sleepText(MealPlanController.to.age)} ',
                                  style: headStyle(40, color: _kDeep),
                                ),
                                TextSpan(
                                  text: 'Hours',
                                  style: headStyle(
                                    21,
                                    weight: FontWeight.w500,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Aim for consistent, quality sleep every night.',
                            style: bodyStyle(
                              13.5,
                              color: const Color(0xFF374151),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            PersonalTargets.bedtimeText(
                              MealPlanController.to.age,
                            ),
                            style: bodyStyle(
                              14.5,
                              color: _kDeep,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 60.w,
                      height: 60.w,
                      child: CustomPaint(
                        painter: _SleepRing(0.78),
                        child: Center(
                          child: Icon(
                            Icons.bed_outlined,
                            size: 22.sp,
                            color: _kDeep,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'HEALTHY SLEEP ROUTINE',
            style: headStyle(14.5, weight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          _routine(
            Icons.brightness_5_outlined,
            'Keep a Regular Schedule',
            'Sleep and wake up around the same time.',
          ),
          _routine(
            Icons.phone_android_rounded,
            'Limit Screen Time',
            'Put your phone away before bedtime.',
          ),
          _routine(
            Icons.local_cafe_outlined,
            'Avoid Late Caffeine',
            'Choose caffeine-free drinks in the evening.',
          ),
        ],
      ),
    );
  }
}

class _SleepRing extends CustomPainter {
  final double progress;
  _SleepRing(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFD7E5F3),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..color = _kDeep,
    );
  }

  @override
  bool shouldRepaint(covariant _SleepRing old) => old.progress != progress;
}
