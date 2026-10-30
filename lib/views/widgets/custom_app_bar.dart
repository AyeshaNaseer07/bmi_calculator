import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    final canShowBack = showBackButton && Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (canShowBack)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBackPressed ?? () => Get.back(),
                  child: const AppBackIcon(),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: AppPalette.textPrimary,
                fontSize: 20.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      ),
    );
  }
}

/// Back button graphic: the round white button artwork in light mode, a plain
/// white arrow in dark mode (the artwork's white circle glares on dark).
class AppBackIcon extends StatelessWidget {
  const AppBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppPalette.isDark) {
      return Image.asset(AppAssets.insightBackIcon, height: 36.h, width: 36.w);
    }
    return SizedBox(
      height: 36.h,
      width: 36.w,
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 22.sp,
      ),
    );
  }
}
