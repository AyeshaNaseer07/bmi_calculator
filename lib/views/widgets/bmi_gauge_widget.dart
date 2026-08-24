import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/bmi_record_model.dart';
import '../../data/services/bmi_service.dart';

class BMIGaugeWidget extends StatefulWidget {
  final double bmiValue;
  final BMICategory? category;
  final double? size;
  final bool showLabels;
  final bool showValueCenter;
  final String? centerLabel;

  const BMIGaugeWidget({
    super.key,
    required this.bmiValue,
    this.category,
    this.size,
    this.showLabels = true,
    this.showValueCenter = false,
    this.centerLabel,
  });

  @override
  State<BMIGaugeWidget> createState() => _BMIGaugeWidgetState();
}

class _BMIGaugeWidgetState extends State<BMIGaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: BMIService.getGaugeProgress(widget.bmiValue),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BMIGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmiValue != widget.bmiValue) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: BMIService.getGaugeProgress(widget.bmiValue),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size ?? 200.w;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(effectiveSize, effectiveSize * 0.65),
          painter: _BMIGaugePainter(
            progress: _animation.value,
            showLabels: widget.showLabels,
            bmiValue: widget.bmiValue,
          ),
          child: widget.showValueCenter
              ? SizedBox(
                  width: effectiveSize,
                  height: effectiveSize * 0.65,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.bmiValue.toStringAsFixed(1),
                            style: AppTypography.valueLarge.copyWith(fontSize: 28.sp),
                          ),
                          if (widget.centerLabel != null)
                            Text(
                              widget.centerLabel!,
                              style: AppTypography.bodySmall.copyWith(
                                color: widget.category?.color ?? AppColors.normal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _BMIGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final bool showLabels;
  final double bmiValue;

  _BMIGaugePainter({
    required this.progress,
    required this.showLabels,
    required this.bmiValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.88);
    final radius = size.width * 0.42;
    final strokeWidth = size.width * 0.07;

    // Total arc is 180 degrees (from PI to 0)
    const startAngle = math.pi;
    const totalSweep = math.pi;

    // Segments: Underweight (22%), Normal (33%), Overweight (25%), Obese (20%)
    final segments = [
      (0.22, AppColors.underweight),
      (0.33, AppColors.normal),
      (0.25, AppColors.overweight),
      (0.20, AppColors.obese),
    ];

    double currentStart = startAngle;
    for (int i = 0; i < segments.length; i++) {
      final segSweep = totalSweep * segments[i].$1;
      final paint = Paint()
        ..color = segments[i].$2
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = i == 0
            ? StrokeCap.round
            : (i == segments.length - 1 ? StrokeCap.round : StrokeCap.butt);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentStart,
        segSweep - 0.02, // subtle gap
        false,
        paint,
      );
      currentStart += segSweep;
    }

    // Needle Calculation
    final needleAngle = math.pi - (progress * math.pi);
    final needleLength = radius * 0.82;

    final needlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final tip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy - needleLength * math.sin(needleAngle),
    );

    final perpAngle = needleAngle + math.pi / 2;
    final baseWidth = size.width * 0.025;
    final base1 = Offset(
      center.dx + baseWidth * math.cos(perpAngle),
      center.dy - baseWidth * math.sin(perpAngle),
    );
    final base2 = Offset(
      center.dx - baseWidth * math.cos(perpAngle),
      center.dy + baseWidth * math.sin(perpAngle),
    );

    final path = Path()
      ..moveTo(base1.dx, base1.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(base2.dx, base2.dy)
      ..close();

    canvas.drawPath(path, needlePaint);

    // Pivot Circle
    final pivotOuter = Paint()..color = const Color(0xFF1E293B);
    final pivotInner = Paint()..color = const Color(0xFF2FD1A6);

    final outerRadius = size.width * 0.035;
    final innerRadius = size.width * 0.018;

    canvas.drawCircle(center, outerRadius, pivotOuter);
    canvas.drawCircle(center, innerRadius, pivotInner);

    // Labels at bottom
    if (showLabels) {
      final labelFontSize = (size.width * 0.05).clamp(8.0, 12.0);

      final textPainterLow = TextPainter(
        text: TextSpan(
          text: '18.5',
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterLow.paint(canvas, Offset(size.width * 0.16, size.height * 0.90));

      final textPainterHigh = TextPainter(
        text: TextSpan(
          text: '24.9',
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterHigh.paint(canvas, Offset(size.width * 0.74, size.height * 0.90));
    }
  }

  @override
  bool shouldRepaint(covariant _BMIGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.bmiValue != bmiValue;
  }
}
