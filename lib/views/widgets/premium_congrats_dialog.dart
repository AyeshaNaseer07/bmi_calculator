import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_palette.dart';

/// Shown after a successful purchase or restore: glowing crown badge, title,
/// short message and a Continue button. Eases in with a slight scale-up.
class PremiumCongratsDialog extends StatelessWidget {
  final bool isRestore;

  const PremiumCongratsDialog({super.key, this.isRestore = false});

  /// Completes when the user taps Continue.
  static Future<void> show({bool isRestore = false}) {
    return Get.dialog<void>(
      PremiumCongratsDialog(isRestore: isRestore),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  static const Color _green = Color(0xFF09B389);
  static const Color _mint = Color(0xFF33D2AB);

  @override
  Widget build(BuildContext context) {
    final dark = AppPalette.isDark;
    final still = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(24.r);

    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 300.w,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: AppPalette.surface.withValues(alpha: 0.97),
            borderRadius: radius,
            border: Border.all(
              color: _mint.withValues(alpha: dark ? 0.35 : 0.45),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crown badge
              Container(
                width: 76.w,
                height: 76.w,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? const Color(0xFF1A3A2A)
                      : const Color(0xFFE9FBF3),
                  border: Border.all(
                    color: _mint.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _mint.withValues(alpha: dark ? 0.35 : 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(AppAssets.crown, fit: BoxFit.contain),
              ),
              SizedBox(height: 16.h),
              Text(
                isRestore ? 'Purchases Restored!' : "You're Premium Now!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 20.sp,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isRestore
                    ? 'Your previous purchase has been restored.\n'
                          'All premium features are unlocked again.'
                    : 'Enjoy an ad-free experience and all\n'
                          'premium health features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 12.5.sp,
                  fontFamily: 'Inter',
                  height: 1.45,
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  if (Get.isDialogOpen == true) Get.back();
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1BD19E), Color(0xFF0AA37D)],
                    ),
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: still ? 1 : 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, t, child) => Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
          ),
          // Mint glow and lift around the card.
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: _mint.withValues(alpha: dark ? 0.18 : 0.22),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.45 : 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: card,
          ),
        ),
      ),
    );
  }
}
