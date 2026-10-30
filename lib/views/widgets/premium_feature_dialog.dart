import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_palette.dart';

/// "Premium Feature" prompt for a locked feature: a lock badge over the card,
/// a [message] explaining what Premium unlocks, an "Unlock Premium" button
/// that runs [onUnlock] and a "Not Now" that just closes it.
class PremiumFeatureDialog extends StatelessWidget {
  final String message;
  final VoidCallback onUnlock;

  const PremiumFeatureDialog({
    super.key,
    required this.message,
    required this.onUnlock,
  });

  static Future<void> show({
    required String message,
    required VoidCallback onUnlock,
  }) {
    return Get.dialog(
      PremiumFeatureDialog(message: message, onUnlock: onUnlock),
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  static const Color _green = Color(0xFF09B389);
  static const List<Color> _gradient = [Color(0xFF1BD19E), Color(0xFF0AA37D)];

  @override
  Widget build(BuildContext context) {
    final badge = 84.w;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Card starts halfway down the badge.
          Container(
            margin: EdgeInsets.only(top: badge / 2),
            padding: EdgeInsets.fromLTRB(22.w, badge / 2 + 16.h, 22.w, 10.h),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(26.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Premium Feature',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 21.sp,
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 13.5.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 22.h),
                _UnlockButton(
                  onTap: () {
                    Get.back();
                    onUnlock();
                  },
                ),
                SizedBox(height: 4.h),
                TextButton(
                  onPressed: Get.back,
                  style: TextButton.styleFrom(
                    foregroundColor: AppPalette.textSecondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                  ),
                  child: Text(
                    'Not Now',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _LockBadge(size: badge),
        ],
      ),
    );
  }
}

/// Repeating 0 → 1 clock shared by the badge and button; stays at 0 with the
/// system "reduce motion" setting.
mixin _LoopAnimation<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      loop.stop();
      loop.value = 0;
    } else if (!loop.isAnimating) {
      loop.repeat();
    }
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }

  /// 0 → 1 → 0 once per cycle.
  double get pulse => 0.5 - 0.5 * math.cos(loop.value * 2 * math.pi);
}

/// Green lock badge that wiggles at the start of each cycle while its glow
/// breathes.
class _LockBadge extends StatefulWidget {
  final double size;

  const _LockBadge({required this.size});

  @override
  State<_LockBadge> createState() => _LockBadgeState();
}

class _LockBadgeState extends State<_LockBadge>
    with SingleTickerProviderStateMixin, _LoopAnimation {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final t = loop.value;
        // Damped shake over the first quarter, then still.
        final w = (t / 0.25).clamp(0.0, 1.0);
        final angle = math.sin(w * 4 * math.pi) * 0.18 * (1 - w);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: PremiumFeatureDialog._gradient,
            ),
            border: Border.all(color: AppPalette.surface, width: 5.w),
            boxShadow: [
              BoxShadow(
                color: PremiumFeatureDialog._green.withValues(
                  alpha: 0.3 + 0.25 * pulse,
                ),
                blurRadius: (16 + 12 * pulse).r,
                spreadRadius: 2 * pulse,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: angle,
            child: Icon(Icons.lock_rounded, color: Colors.white, size: 34.sp),
          ),
        );
      },
    );
  }
}

/// Green CTA that gently pulses, has a shine sweeping across it and an arrow
/// nudging forward.
class _UnlockButton extends StatefulWidget {
  final VoidCallback onTap;

  const _UnlockButton({required this.onTap});

  @override
  State<_UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<_UnlockButton>
    with SingleTickerProviderStateMixin, _LoopAnimation {
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28.r);
    final label = Center(
      child: Text(
        'Unlock Premium',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: loop,
        builder: (context, _) {
          final pulse = this.pulse;
          // Shine crosses during the first half, then rests.
          final shine = (loop.value / 0.5).clamp(0.0, 1.0);
          return Transform.scale(
            scale: 1 + 0.03 * pulse,
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: PremiumFeatureDialog._gradient,
                ),
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: PremiumFeatureDialog._green.withValues(
                      alpha: 0.3 + 0.25 * pulse,
                    ),
                    blurRadius: (10 + 8 * pulse).r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final bandWidth = width * 0.35;
                    return Stack(
                      children: [
                        if (shine < 1)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            width: bandWidth,
                            left: -bandWidth + (width + bandWidth) * shine,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-1, -0.4),
                                  end: const Alignment(1, 0.4),
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.45),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            children: [
                              SizedBox(width: 22.sp),
                              Expanded(child: label),
                              // Arrow nudges forward with the pulse.
                              Transform.translate(
                                offset: Offset(5.w * pulse, 0),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 22.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
