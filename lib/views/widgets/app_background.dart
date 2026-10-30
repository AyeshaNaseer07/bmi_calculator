import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_palette.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const AppBackground({super.key, required this.child, this.backgroundColor});

  /// Used in place of light-only background artwork in dark mode.
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF13241F), Color(0xFF0E1714)],
    stops: [0.0, 0.45],
  );

  @override
  Widget build(BuildContext context) {
    // The background artwork is light-only; dark mode uses a plain
    // gradient with a faint teal glow at the top instead.
    if (AppPalette.isDark) {
      return Container(
        decoration: const BoxDecoration(gradient: darkGradient),
        child: child,
      );
    }
    return Container(
      color: backgroundColor ?? AppColors.scaffoldBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                AppAssets.appBg,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
