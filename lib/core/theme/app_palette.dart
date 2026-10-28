import 'package:flutter/material.dart';

/// Surface, text and border colours that change between light and dark mode.
///
/// Brand teal, gradients on buttons and the BMI category colours are the same
/// in both modes and stay in [AppColors]. These are getters (not consts): the
/// whole app is rebuilt with `Get.forceAppUpdate()` when the theme changes,
/// so every widget re-reads them.
abstract class AppPalette {
  static bool isDark = false;

  static Color _pick(Color light, Color dark) => isDark ? dark : light;

  // ── Backgrounds ──
  static Color get background =>
      _pick(const Color(0xFFF7FAF8), const Color(0xFF0E1714));

  /// Cards, sheets, dialogs (white in light mode).
  static Color get surface =>
      _pick(Colors.white, const Color(0xFF17231F));

  /// Mint-tinted panels inside or between cards.
  static Color get surfaceMint =>
      _pick(const Color(0xFFF0FAF6), const Color(0xFF1B2B26));

  /// Slightly deeper mint, for panels sitting on [surfaceMint] or gradients.
  static Color get surfaceMintDeep =>
      _pick(const Color(0xFFE3F5EE), const Color(0xFF203530));

  /// Neutral grey panels, chips and inputs.
  static Color get surfaceMuted =>
      _pick(const Color(0xFFF1F5F9), const Color(0xFF212D2A));

  // ── Text ──
  static Color get textPrimary =>
      _pick(const Color(0xFF111827), const Color(0xFFF1F5F4));
  static Color get textBody =>
      _pick(const Color(0xFF4B5563), const Color(0xFFC6D1CE));
  static Color get textSecondary =>
      _pick(const Color(0xFF6B7280), const Color(0xFF9AA9A5));
  static Color get textMuted =>
      _pick(const Color(0xFF94A3B8), const Color(0xFF7D8B87));

  // ── Lines ──
  static Color get border =>
      _pick(const Color(0xFFE2E8F0), const Color(0xFF2B3A36));
  static Color get divider =>
      _pick(const Color(0xFFF1F5F9), const Color(0xFF24322E));
  static Color get mintBorder =>
      _pick(const Color(0xFFD4EFE6), const Color(0xFF26453B));

  /// Card shadows: soft mint glow in light mode, nearly none in dark.
  static Color shadow(Color light) =>
      isDark ? Colors.black.withValues(alpha: 0.35) : light;
}
