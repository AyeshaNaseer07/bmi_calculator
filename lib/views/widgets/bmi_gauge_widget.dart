import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_pages.dart';
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
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: BMIService.getGaugeProgress(widget.bmiValue),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _animateGauge();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called whenever returning back to this screen from any another screen
    _animateGauge();
  }

  @override
  void didPush() {
    // Called when the route is pushed
    _animateGauge();
  }

  void _animateGauge() {
    _animation = Tween<double>(
      begin: 0.0,
      end: BMIService.getGaugeProgress(widget.bmiValue),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void didUpdateWidget(covariant BMIGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmiValue != widget.bmiValue) {
      _animateGauge();
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size ?? 200.w;
    final gaugeHeight = widget.showValueCenter
        ? effectiveSize * 0.72
        : (widget.showLabels ? effectiveSize * 0.60 : effectiveSize * 0.54);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: effectiveSize,
          height: gaugeHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Gauge background image asset
              Positioned(
                top: 0,
                left: 4,
                right: 4,
                child: Image.asset(
                  AppAssets.bmiGauge,
                  width: effectiveSize,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),

              // Needle and pivot painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _BMIGaugeNeedlePainter(
                    progress: _animation.value,
                    showLabels: widget.showLabels,
                    bmiValue: widget.bmiValue,
                  ),
                ),
              ),

              // Center value / label if requested
              if (widget.showValueCenter)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.bmiValue.toStringAsFixed(1),
                        style: AppTypography.valueLarge.copyWith(
                          fontSize: 28.sp,
                        ),
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
            ],
          ),
        );
      },
    );
  }
}

class _BMIGaugeNeedlePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final bool showLabels;
  final double bmiValue;

  _BMIGaugeNeedlePainter({
    required this.progress,
    required this.showLabels,
    required this.bmiValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // In Group 10.png (454x450), the semi-circle center is at (227, 225.5) / 454
    final center = Offset(size.width / 2, size.width * (225.5 / 454.0));
    final radius = size.width * (226.0 / 454.0);
    final needleLength = radius * 0.74;

    // Angle: progress 0.0 -> math.pi (pointing left)
    // progress 0.5 -> math.pi / 2 (pointing top)
    // progress 1.0 -> 0.0 (pointing right)
    final needleAngle = math.pi - (progress * math.pi);

    final needlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final tip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy - needleLength * math.sin(needleAngle),
    );

    final perpAngle = needleAngle + math.pi / 2;
    final baseWidth = size.width * 0.024;
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

    // Subtle drop shadow for needle
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.save();
    canvas.translate(0.8, 1.2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw Needle
    canvas.drawPath(path, needlePaint);

    // Pivot Circle
    final pivotHalo = Paint()
      ..color = const Color(0xFF2FD1A6).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final pivotOuter = Paint()..color = const Color(0xFF1E293B);
    final pivotInner = Paint()..color = const Color(0xFF2FD1A6);

    final outerRadius = size.width * 0.038;
    final innerRadius = size.width * 0.020;

    canvas.drawCircle(center, outerRadius * 1.5, pivotHalo);
    canvas.drawCircle(center, outerRadius, pivotOuter);
    canvas.drawCircle(center, innerRadius, pivotInner);

    // Labels below arc ends
    if (showLabels) {
      final numFontSize = (size.width * 0.068).clamp(10.0, 13.0);
      final subFontSize = (size.width * 0.055).clamp(8.5, 11.0);

      final numStyle = TextStyle(
        color: const Color(0xFF1E2D2F),
        fontSize: numFontSize,
        fontWeight: FontWeight.w700,
        fontFamily: 'Outfit',
        height: 1.15,
      );
      final subStyle = TextStyle(
        color: const Color(0xFF8C9EA0),
        fontSize: subFontSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        height: 1.25,
      );

      final textPainterLow = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: '18.5\n', style: numStyle),
            TextSpan(text: 'Low', style: subStyle),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterLow.paint(
        canvas,
        Offset(
          (size.width * 0.125) - (textPainterLow.width / 2),
          center.dy + size.width * 0.015,
        ),
      );

      final textPainterHigh = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: '24.9\n', style: numStyle),
            TextSpan(text: 'High', style: subStyle),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainterHigh.paint(
        canvas,
        Offset(
          (size.width * 0.875) - (textPainterHigh.width / 2),
          center.dy + size.width * 0.015,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BMIGaugeNeedlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.bmiValue != bmiValue;
  }
}
