import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Base animated shimmer effect that sweeps across child widgets.
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _gradientPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientPosition,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_gradientPosition.value - 0.3).clamp(0.0, 1.0),
                _gradientPosition.value.clamp(0.0, 1.0),
                (_gradientPosition.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                Color(0xFFE8ECEB),
                Color(0xFFF7FAF9),
                Color(0xFFE8ECEB),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Medium Native Ad Shimmer Skeleton matching MediumNativeAdFactory layout
class MediumNativeAdShimmer extends StatelessWidget {
  const MediumNativeAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE8F7F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon, Headline/Body placeholder, AD badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon skeleton
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E5E5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(width: 10.w),

                // Text Stack skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E5E5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // ADDED: Stars skeleton
                      Row(
                        children: List.generate(
                          5,
                          (index) => Container(
                            width: 12.w,
                            height: 12.w,
                            margin: EdgeInsets.only(right: 2.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E5E5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E5E5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 130.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E5E5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // AD Badge skeleton
                Container(
                  width: 30.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7F3EA),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Media View skeleton
            Container(
              width: double.infinity,
              height: 136.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E5E5),
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            SizedBox(height: 10.h),

            // CTA Button skeleton
            Container(
              width: double.infinity,
              height: 46.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E5E5),
                borderRadius: BorderRadius.circular(23.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Screen Native Ad Shimmer Skeleton matching FullScreenNativeAdFactory layout
class FullScreenNativeAdShimmer extends StatelessWidget {
  const FullScreenNativeAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // Top Media Area (~68% screen height)
            Expanded(
              flex: 68,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFE0E5E5),
                child: Stack(
                  children: [
                    // AD Badge placeholder top right
                    Positioned(
                      top: 48.h,
                      right: 16.w,
                      child: Container(
                        width: 32.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7F3EA),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    // Centered media icon skeleton
                    Center(
                      child: Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3DADA),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Card Area (~32% screen height)
            Expanded(
              flex: 32,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + Info row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E5E5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 140.w,
                                height: 16.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E5E5),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              // ADDED: Stars skeleton
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    width: 13.w,
                                    height: 13.w,
                                    margin: EdgeInsets.only(right: 2.w),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0E5E5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                width: double.infinity,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E5E5),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // CTA Button Pill
                    Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E5E5),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
