import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            top: 16.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: CupertinoIcons.house_fill,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.person_fill,
                    label: 'Profile',
                    index: 1,
                  ),
                  SizedBox(width: 56.w),
                  _buildNavItem(
                    icon: CupertinoIcons.graph_square_fill,
                    label: 'Weight',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: CupertinoIcons.clock_fill,
                    label: 'History',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),

          // Raised center "+" button
          Positioned(
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAddTap,
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 26.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryTeal : const Color(0xFF9AA6A9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
