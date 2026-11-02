import 'package:flutter/material.dart';

/// Surface, text and border colours.
///
/// Brand teal, gradients on buttons and the BMI category colours stay in
/// [AppColors].
abstract class AppPalette {
  // ── Backgrounds ──
  static const Color background = Color(0xFFF7FAF8);

  /// Cards, sheets, dialogs.
  static const Color surface = Colors.white;

  /// Mint-tinted panels inside or between cards.
  static const Color surfaceMint = Color(0xFFF0FAF6);

  /// Slightly deeper mint, for panels sitting on [surfaceMint] or gradients.
  static const Color surfaceMintDeep = Color(0xFFE3F5EE);

  /// Neutral grey panels, chips and inputs.
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // ── Text ──
  static const Color textPrimary = Color(0xFF111827);
  static const Color textBody = Color(0xFF4B5563);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF94A3B8);

  // ── Lines ──
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color mintBorder = Color(0xFFD4EFE6);
}
