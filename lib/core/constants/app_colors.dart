import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Primary Palette ──
  static const Color primaryTeal = Color(0xFF09B389);
  static const Color primaryTealLight = Color(0xFF2FD1A6);
  static const Color accentBlue = Color(0xFF168EE2);

  // ── Gradients ──
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF2FD1A6), Color(0xFF168EE2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Backgrounds & Cards ──
  static const Color scaffoldBackground = Color(0xFFF7FAF8);

  // ── Typography Colors ──
  static const Color textDark = Color(0xFF1E293B);
  static const Color textBody = Color(0xFF475569);
  static const Color textMuted = Color(0xFF8E9BAE);
  static const Color textLight = Color(0xFF94A3B8);

  // ── BMI Categories Colors ──
  static const Color underweight = Color(0xFF38B6FF);
  static const Color normal = Color(0xFF00C48C);
  static const Color overweight = Color(0xFFFF9500);
  static const Color obese = Color(0xFFFF2D2D);

  // ── Status & Accents ──
  static const Color error = Color(0xFFFF4D4F);

  // ── Shadows ──
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF09B389).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
