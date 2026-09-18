import 'dart:math' as math;

import 'package:flutter/material.dart';

class BorderedRoundSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double? disabledThumbRadius;
  final double borderWidth;
  final Color? borderColor;
  final Color fillColor;
  final double elevation;
  final double pressedElevation;

  const BorderedRoundSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.borderWidth = 2.5,
    this.borderColor,
    this.fillColor = Colors.white,
    this.elevation = 2.0,
    this.pressedElevation = 4.0,
  });

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
      isEnabled ? enabledThumbRadius : _disabledThumbRadius,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final double radius = radiusTween.evaluate(enableAnimation);

    final elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );
    final double evaluatedElevation = elevationTween.evaluate(
      activationAnimation,
    );

    final path = Path()
      ..addArc(
        Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius),
        0,
        math.pi * 2,
      );

    if (evaluatedElevation > 0) {
      canvas.drawShadow(path, Colors.black, evaluatedElevation, true);
    }

    // Inner Fill (White)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Border (Matching slider active track color)
    final effectiveBorderColor =
        borderColor ?? sliderTheme.activeTrackColor ?? const Color(0xFF2FD1A6);
    final borderPaint = Paint()
      ..color = effectiveBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, radius - (borderWidth / 2), borderPaint);
  }
}
