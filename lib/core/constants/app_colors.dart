import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Primary Palette ──
  static const Color primaryTeal = Color(0xFF1DB59B);
  static const Color primaryTealDark = Color(0xFF138A76);
  static const Color primaryTealLight = Color(0xFF2FD1A6);
  static const Color accentBlue = Color(0xFF168EE2);

  // ── Gradients ──
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF2FD1A6), Color(0xFF168EE2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF0FDF8), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFF3FAF7), Color(0xFFE8F7F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardMintGradient = LinearGradient(
    colors: [Color(0xFFF4FCF9), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Backgrounds & Cards ──
  static const Color scaffoldBackground = Color(0xFFF7FAF8);
  static const Color cardBackground = Colors.white;
  static const Color mintLight = Color(0xFFEDFAF5);
  static const Color mintBorder = Color(0xFFD4EFE6);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color borderGray = Color(0xFFE2E8F0);

  // ── Typography Colors ──
  static const Color textDark = Color(0xFF1E293B);
  static const Color textBody = Color(0xFF475569);
  static const Color textMuted = Color(0xFF8E9BAE);
  static const Color textLight = Color(0xFF94A3B8);

  // ── BMI Categories Colors ──
  static const Color underweight = Color(0xFF3B82F6);
  static const Color normal = Color(0xFF10B981);
  static const Color overweight = Color(0xFFF59E0B);
  static const Color obese = Color(0xFFEF4444);

  // ── Status & Accents ──
  static const Color gold = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D4F);
  static const Color heartRed = Color(0xFFEF4444);
  static const Color hydrationBlue = Color(0xFF0EA5E9);
  static const Color progressGreen = Color(0xFF22C55E);

  // ── Shadows ──
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF1DB59B).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: const Color(0xFF168EE2).withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
