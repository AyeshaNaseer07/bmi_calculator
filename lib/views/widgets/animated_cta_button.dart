import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import 'custom_gradient_button.dart';

class AnimatedCtaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? height;
  final double? width;
  final String? backgroundImage;
  final bool isLoading;
  final bool enablePulse;
  final bool enableShimmer;
  final bool enableArrowNudge;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const AnimatedCtaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.height,
    this.width,
    this.backgroundImage,
    this.isLoading = false,
    this.enablePulse = true,
    this.enableShimmer = true,
    this.enableArrowNudge = true,
    this.borderRadius,
    this.textStyle,
  });

  @override
  State<AnimatedCtaButton> createState() => _AnimatedCtaButtonState();
}

class _AnimatedCtaButtonState extends State<AnimatedCtaButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAlphaAnimation;
  late Animation<double> _arrowOffsetAnimation;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // 1. Gentle breathing / pulse animation (1400ms easeInOut cycle back and forth)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _glowAlphaAnimation = Tween<double>(begin: 0.22, end: 0.52).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _arrowOffsetAnimation = Tween<double>(begin: 0.0, end: 3.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    if (widget.enablePulse && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }

    // 2. Periodic shimmer light sweep (2800ms cycle: sweeps across in ~1680ms, pauses ~1120ms)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _shimmerAnimation = Tween<double>(begin: -1.4, end: 2.4).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: const Interval(0.0, 0.60, curve: Curves.easeInOutCubic),
      ),
    );

    if (widget.enableShimmer && !widget.isLoading) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _pulseController.stop();
        _shimmerController.stop();
      } else {
        if (widget.enablePulse && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
        if (widget.enableShimmer && !_shimmerController.isAnimating) {
          _shimmerController.repeat();
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(12.r);

    // Build trailing icon with optional animated directional nudge
    Widget? effectiveTrailing = widget.trailingIcon;
    if (widget.enableArrowNudge &&
        widget.trailingIcon != null &&
        !widget.isLoading) {
      effectiveTrailing = AnimatedBuilder(
        animation: _arrowOffsetAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_arrowOffsetAnimation.value.w, 0),
            child: child,
          );
        },
        child: widget.trailingIcon,
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double currentScale = widget.isLoading
            ? 1.0
            : (_isPressed ? 0.97 : _scaleAnimation.value);

        return Transform.scale(
          scale: currentScale,
          child: Listener(
            onPointerDown: widget.onPressed == null
                ? null
                : (_) => setState(() => _isPressed = true),
            onPointerUp: widget.onPressed == null
                ? null
                : (_) => setState(() => _isPressed = false),
            onPointerCancel: widget.onPressed == null
                ? null
                : (_) => setState(() => _isPressed = false),
            child: Container(
              width: widget.width ?? double.infinity,
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0AA37D).withValues(
                      alpha: widget.isLoading
                          ? 0.15
                          : _glowAlphaAnimation.value,
                    ),
                    blurRadius:
                        12.r +
                        (widget.isLoading ? 0 : 8.r * _pulseController.value),
                    spreadRadius:
                        0.5.r +
                        (widget.isLoading ? 0 : 1.5.r * _pulseController.value),
                    offset: Offset(0, 4.h),
                  ),
                  BoxShadow(
                    color: const Color(0xFF33D2AB).withValues(
                      alpha: widget.isLoading
                          ? 0.08
                          : (_glowAlphaAnimation.value * 0.4),
                    ),
                    blurRadius:
                        22.r +
                        (widget.isLoading ? 0 : 10.r * _pulseController.value),
                    spreadRadius: 0.0,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CustomGradientButton(
                    text: widget.text,
                    onPressed: widget.onPressed,
                    leadingIcon: widget.leadingIcon,
                    trailingIcon: effectiveTrailing,
                    height: widget.height,
                    width: widget.width,
                    backgroundImage:
                        widget.backgroundImage ?? AppAssets.btnRectangle,
                    borderRadius: effectiveBorderRadius,
                    textStyle: widget.textStyle,
                  ),
                  if (widget.enableShimmer && !widget.isLoading)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: effectiveBorderRadius,
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              final shimmerVal = _shimmerAnimation.value;
                              if (shimmerVal < -1.1 || shimmerVal > 2.1) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(shimmerVal - 0.7, -1.0),
                                    end: Alignment(shimmerVal + 0.7, 1.0),
                                    stops: const [0.0, 0.38, 0.5, 0.62, 1.0],
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.05),
                                      Colors.white.withValues(alpha: 0.40),
                                      Colors.white.withValues(alpha: 0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
