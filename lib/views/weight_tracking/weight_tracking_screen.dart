import 'dart:math' as math;

import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeightTrackerController controller =
        Get.find<WeightTrackerController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Weight Tracking'),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Obx(() {
              final current = controller.currentWeight.value;
              final goal = controller.goalWeight.value;
              final timeframe = controller.selectedTimeframe.value;
              final spots = controller.getSpots();
              final goalSpots = controller.getGoalSpots();
              final xLabels = controller.getXAxisLabels();

              final hasRecords = controller.weightHistory.isNotEmpty;
              final currentStr = hasRecords
                  ? '${current.toStringAsFixed(1)}kg'
                  : '00.0kg';
              final goalStr = hasRecords
                  ? '${goal.toStringAsFixed(1)}kg'
                  : '00.0kg';
              final centerValStr = hasRecords
                  ? current.toStringAsFixed(1)
                  : '00.0';
              final progressVal = hasRecords
                  ? (goal > 0
                        ? (current / goal).clamp(0.0, 1.0)
                        : (current / 60.0).clamp(0.0, 1.0))
                  : 0.05; // tiny 1–2cm arc fill when no records

              final pWeek = controller.progressThisWeek.value;
              final pMonth = controller.progressThisMonth.value;
              final pTotal = controller.progressTotal.value;
              final weekStr = pWeek == 0.0
                  ? '-0.0kg'
                  : '${pWeek > 0 ? '+' : ''}${pWeek.toStringAsFixed(1)}kg';
              final monthStr = pMonth == 0.0
                  ? '-0.0kg'
                  : '${pMonth > 0 ? '+' : ''}${pMonth.toStringAsFixed(1)}kg';
              final totalStr = pTotal == 0.0
                  ? '-0.0kg'
                  : '${pTotal > 0 ? '+' : ''}${pTotal.toStringAsFixed(1)}kg';

              // Fixed Y-axis scale: 0, 20, 40, 60, 80, 100, 120 — interval 20
              // Headroom up to 140.0 ensures the 120.0 weight badge and icon are not cut off
              const double calculatedMinY = 0.0;
              const double calculatedMaxY = 140.0;
              const double calculatedInterval = 20.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Weight Ring Summary Card
                  CustomCard(
                    borderRadius: 22.r,
                    padding: EdgeInsets.all(18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Current Weight
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current weight',
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              currentStr,
                              style: TextStyle(
                                color: const Color(0xFF33D2AB),
                                fontSize: 24.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        // Center Ring Gauge
                        SizedBox(
                          width: 90.w,
                          height: 90.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80.w,
                                height: 80.w,
                                child: CustomPaint(
                                  painter: _GradientCircularProgressPainter(
                                    progress: progressVal,
                                    strokeWidth: 8.w,
                                    backgroundColor: const Color(0xFFE8F7F2),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppAssets.weightTrackingicon,
                                    height: 24.h,
                                    width: 24.w,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    centerValStr,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.30,
                                    ),
                                  ),
                                  Text(
                                    'kg',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.30,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Goal Weight
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Goal weight',
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              goalStr,
                              style: TextStyle(
                                color: const Color(0xFFF97316),
                                fontSize: 24.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Add Weight CTA Button
                  CustomGradientButton(
                    text: 'Add Weight',
                    leadingIcon: Icon(
                      CupertinoIcons.plus_circle,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    backgroundImage: AppAssets.btnRectangle,
                    onPressed: () => Get.toNamed(AppRoutes.addWeight),
                  ),
                  SizedBox(height: 16.h),

                  // Weight Progress Card with Chart
                  CustomCard(
                    borderRadius: 22.r,
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title & Timeframe Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weight Progress',
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 15.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F2),
                                borderRadius: BorderRadius.circular(10.r),
                              ),

                              child: Row(
                                children: ['Week', 'Month', 'Year'].map((tab) {
                                  final isSelected =
                                      timeframe.toLowerCase() ==
                                      tab.toLowerCase();
                                  return GestureDetector(
                                    onTap: () => controller.setTimeframe(tab),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 4.r,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        tab,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Inter',
                                          color: isSelected
                                              ? const Color(0xFF33D2AB)
                                              : const Color(0xFF797979),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // Legend row
                        Row(
                          children: [
                            // Current weight legend
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2FD1A6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Current Weight',
                              style: TextStyle(
                                color: const Color(0xFF4B5563),
                                fontSize: 11.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            // Goal weight legend
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF97316),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Goal Weight',
                              style: TextStyle(
                                color: const Color(0xFF4B5563),
                                fontSize: 11.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 22.h),

                        // FL Chart Container
                        SizedBox(
                          height: 185.h,
                          child: LineChart(
                            LineChartData(
                              clipData: const FlClipData.none(),
                              gridData: const FlGridData(show: false),
                              lineTouchData: const LineTouchData(
                                enabled: false,
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24.h,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value != value.roundToDouble()) {
                                        return const SizedBox.shrink();
                                      }
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < xLabels.length) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 6.h),
                                          child: Text(
                                            xLabels[index],
                                            style: TextStyle(
                                              color: const Color(0xFF797979),
                                              fontSize: 11.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28.w,
                                    interval: calculatedInterval,
                                    getTitlesWidget: (value, meta) {
                                      if (value < calculatedMinY ||
                                          value > 120.0) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: const Color(0xFF797979),
                                          fontSize: 11.sp,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.w,
                                  ),
                                  left: BorderSide(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.w,
                                  ),
                                ),
                              ),
                              minX: 0,
                              maxX: (xLabels.length - 1).toDouble(),
                              minY: calculatedMinY,
                              maxY: calculatedMaxY,
                              lineBarsData: spots.isEmpty
                                  ? []
                                  : [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: spots.length > 1,
                                        curveSmoothness: 0.35,
                                        color: const Color(0xFF2FD1A6),
                                        barWidth: spots.length > 1 ? 2.2.w : 0,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) {
                                                final isLast =
                                                    index == spots.length - 1;
                                                return _WeightDotPainter(
                                                  radius: 3.5.r,
                                                  dotColor: Colors.white,
                                                  strokeColor: const Color(
                                                    0xFF2FD1A6,
                                                  ),
                                                  strokeWidth: 2.w,
                                                  isLast: isLast,
                                                );
                                              },
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF2FD1A6)
                                                  .withValues(alpha: 0.22),
                                              const Color(0xFF2FD1A6)
                                                  .withValues(alpha: 0.0),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                      // Goal weight — dashed orange horizontal line
                                      if (goalSpots.isNotEmpty)
                                        LineChartBarData(
                                          spots: goalSpots,
                                          isCurved: false,
                                          color: const Color(0xFFF97316),
                                          barWidth: 1.8.w,
                                          isStrokeCapRound: false,
                                          dashArray: [6, 4],
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter:
                                                (
                                                  spot,
                                                  percent,
                                                  barData,
                                                  index,
                                                ) {
                                                  // Only show a small label at the
                                                  // right end of the goal line
                                                  if (index ==
                                                      goalSpots.length - 1) {
                                                    return _GoalLabelPainter(
                                                      label:
                                                          '${spot.y.toStringAsFixed(1)}kg',
                                                    );
                                                  }
                                                  return FlDotCirclePainter(
                                                    radius: 0,
                                                    color: Colors.transparent,
                                                    strokeWidth: 0,
                                                    strokeColor:
                                                        Colors.transparent,
                                                  );
                                                },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: false,
                                          ),
                                        ),
                                    ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Bottom Progress Metrics Summary
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 8.w,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F2),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProgressMetric(
                                value: weekStr,
                                label: 'This Week',
                              ),
                              _buildProgressDivider(),
                              _buildProgressMetric(
                                value: monthStr,
                                label: 'This Month',
                              ),
                              _buildProgressDivider(),
                              _buildProgressMetric(
                                value: totalStr,
                                label: 'Total Progress',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressMetric({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 13.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDivider() {
    return Container(height: 28.h, width: 1.w, color: Colors.grey);
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;

  const _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw full background circular track
    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw active gradient progress arc
    if (progress > 0) {
      final startAngle = 130 * (math.pi / 180);
      final sweepAngle = (progress * 2 * math.pi).clamp(0.0, 2 * math.pi);

      final progressPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment(0.8, -0.6),
          end: Alignment(-0.8, 0.7),
          colors: [
            Color(0xFF33D2AB), // Vibrant mint at top-right
            Color(0xFF20BC9A), // Teal
            Color(0xFF0F8C74), // Deep teal
            Color(0xFF025848), // Dark forest teal at bottom-left
          ],
          stops: [0.0, 0.35, 0.70, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      if (progress >= 1.0) {
        canvas.drawCircle(center, radius, progressPaint);
      } else {
        canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _WeightDotPainter extends FlDotPainter {
  final double radius;
  final Color dotColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool isLast;

  _WeightDotPainter({
    required this.radius,
    required this.dotColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.isLast,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offset) {
    // 1. Draw the circle dot
    final fillPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(offset, radius, fillPaint);
    canvas.drawCircle(offset, radius, strokePaint);

    // 2. Draw label above the dot
    final valueStr = spot.y.toStringAsFixed(1);

    if (isLast) {
      final isNearTop = offset.dy < 10.0;
      final badgeCenterY = isNearTop ? offset.dy + 18.0 : offset.dy - 16.0;

      // Draw highlighted teal pill badge with downward pointer
      final textPainter = TextPainter(
        text: TextSpan(
          text: valueStr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 9.0.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final badgeWidth = textPainter.width + 10.0;
      final badgeHeight = textPainter.height + 4.0;
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(offset.dx, badgeCenterY),
          width: badgeWidth,
          height: badgeHeight,
        ),
        Radius.circular(3.0.r),
      );

      final badgePaint = Paint()
        ..color = const Color(0xFF33D2AB)
        ..style = PaintingStyle.fill;

      // Draw rounded rectangle badge
      canvas.drawRRect(badgeRect, badgePaint);

      // Draw pointer (pointing down if badge above dot, pointing up if below dot)
      final pointerPath = Path();
      if (isNearTop) {
        pointerPath
          ..moveTo(offset.dx - 3.0, badgeCenterY - (badgeHeight / 2))
          ..lineTo(offset.dx + 3.0, badgeCenterY - (badgeHeight / 2))
          ..lineTo(offset.dx, offset.dy + 4.5)
          ..close();
      } else {
        pointerPath
          ..moveTo(offset.dx - 3.0, badgeCenterY + (badgeHeight / 2))
          ..lineTo(offset.dx + 3.0, badgeCenterY + (badgeHeight / 2))
          ..lineTo(offset.dx, offset.dy - 4.5)
          ..close();
      }
      canvas.drawPath(pointerPath, badgePaint);

      // Draw text inside badge
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - (textPainter.width / 2),
          badgeCenterY - (textPainter.height / 2),
        ),
      );
    } else {
      final isNearTop = offset.dy < 10.0;
      final textY = isNearTop ? offset.dy + 10.0 : offset.dy - 14.0;

      // Draw normal floating text above dot
      final textPainter = TextPainter(
        text: TextSpan(
          text: valueStr,
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 9.0.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(offset.dx - (textPainter.width / 2), textY),
      );
    }
  }

  @override
  Size getSize(FlSpot spot) => Size(radius * 2, radius * 2);

  @override
  Color get mainColor => strokeColor;

  @override
  List<Object?> get props => [
    radius,
    dotColor,
    strokeColor,
    strokeWidth,
    isLast,
  ];

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) => b;
}

/// Draws a small orange pill badge at the end of the goal weight line.
class _GoalLabelPainter extends FlDotPainter {
  final String label;

  _GoalLabelPainter({required this.label});

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.5.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 8.0;
    final badgeHeight = textPainter.height + 4.0;
    // Always show badge ABOVE the line
    final badgeCenterY = offset.dy - badgeHeight / 2 - 4.0;

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(offset.dx, badgeCenterY),
        width: badgeWidth,
        height: badgeHeight,
      ),
      Radius.circular(4.0.r),
    );

    final paint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(badgeRect, paint);

    // Tiny downward pointer triangle
    final pointer = Path()
      ..moveTo(offset.dx - 3.0, badgeCenterY + badgeHeight / 2)
      ..lineTo(offset.dx + 3.0, badgeCenterY + badgeHeight / 2)
      ..lineTo(offset.dx, offset.dy - 1.0)
      ..close();
    canvas.drawPath(pointer, paint);

    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        badgeCenterY - textPainter.height / 2,
      ),
    );
  }

  @override
  Size getSize(FlSpot spot) => const Size(50, 20);

  @override
  Color get mainColor => const Color(0xFFF97316);

  @override
  List<Object?> get props => [label];

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) => b;
}
