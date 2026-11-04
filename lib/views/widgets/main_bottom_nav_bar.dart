import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/responsive.dart';

const Color _kActiveNavColor = Color(0xFF2EC4B6);

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
    final tablet = isTablet(context);
    return Container(
      color: AppPalette.surface,
      child: SizedBox(
        height: 74.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              top: 10.h,
              right: 15.w,
              left: 15.w,
              child: Container(
                decoration: ShapeDecoration(
                  color: AppPalette.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _slot(
                      tablet,
                      _buildNavItem(
                        icon: AppAssets.navHome,
                        label: 'home'.tr,
                        index: 0,
                      ),
                    ),
                    _slot(
                      tablet,
                      _buildNavItem(
                        icon: AppAssets.navWeight,
                        label: 'weight'.tr,
                        index: 2,
                      ),
                    ),
                    SizedBox(width: 56.w),
                    _slot(
                      tablet,
                      _buildNavItem(
                        icon: AppAssets.navProfile,
                        label: 'profile'.tr,
                        index: 1,
                      ),
                    ),
                    _slot(
                      tablet,
                      _buildNavItem(
                        icon: AppAssets.navHistory,
                        label: 'history'.tr,
                        index: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Raised center "+" button
            Positioned(
              top: -15,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAddTap,
                child: ClipOval(
                  child: Image.asset(
                    AppAssets.navAdd,
                    fit: BoxFit.cover,
                    width: 52.w,
                    height: 52.h,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(bool isTablet, Widget item) =>
      isTablet ? Expanded(child: Center(child: item)) : Flexible(child: item);

  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? _kActiveNavColor : const Color(0xFF9AA6A9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 20.sp,
              height: 20.sp,
              color: color,
              colorBlendMode: BlendMode.srcIn,
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
