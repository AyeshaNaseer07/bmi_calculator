import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';

/// Branded loader: a rotating gradient arc around a softly pulsing icon.
class CustomLoader extends StatefulWidget {
  const CustomLoader({
    super.key,
    this.size,
    this.icon = CupertinoIcons.camera_fill,
  });

  /// Outer diameter. Defaults to 64.w.
  final double? size;

  /// Icon shown (pulsing) in the middle of the ring. Pass null to hide.
  final IconData? icon;

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? 64.w;
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final double t = _controller.value;
            final double pulse = 0.85 + 0.15 * math.sin(t * 2 * math.pi);
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(size),
                  painter: _ArcPainter(progress: t, strokeWidth: size * 0.09),
                ),
                if (widget.icon != null)
                  Transform.scale(
                    scale: pulse,
                    child: Icon(
                      widget.icon,
                      size: size * 0.36,
                      color: AppColors.primaryTeal,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Rect arcRect = rect.deflate(strokeWidth / 2);

    // Faint track.
    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = AppColors.primaryTeal.withValues(alpha: 0.15),
    );

    // Rotating gradient sweep.
    final double start = progress * 2 * math.pi;
    final Paint sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 1.5,
        colors: const [
          Color(0x0009B389),
          AppColors.primaryTealLight,
          AppColors.primaryTeal,
        ],
        transform: GradientRotation(start),
      ).createShader(arcRect);

    canvas.drawArc(arcRect, start, math.pi * 1.5, false, sweep);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

/// Full-screen dimmed overlay with a [CustomLoader] and a label. Blocks touches.
class LoaderOverlay extends StatelessWidget {
  const LoaderOverlay({super.key, this.message = 'Uploading photo...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomLoader(size: 64.w),
                SizedBox(height: 14.h),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
