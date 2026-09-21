import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';

class NextButton extends StatefulWidget {
  final VoidCallback onNext;

  const NextButton({required this.onNext, super.key});

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.6, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Continuously bounce the arrow left → right → left
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isNavigating) return;
    _isNavigating = true;
    widget.onNext();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF24CCA7), Color(0xFF168EE2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 18.w),
            SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                AppAssets.arrowIcon,
                width: 18.w,
                height: 18.w,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
