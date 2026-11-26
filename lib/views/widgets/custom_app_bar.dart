import '../../core/utils/rtl.dart';

import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_palette.dart';
import 'language_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;

  /// Shows the language shortcut when no [trailing] widget is given.
  final bool showLanguageButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
    this.showLanguageButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    final canShowBack = showBackButton && Navigator.of(context).canPop();
    final trailingWidget =
        trailing ?? (showLanguageButton ? const LanguageButton() : null);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (canShowBack)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GestureDetector(
                  onTap: onBackPressed ?? () => Get.back(),
                  child: const AppBackIcon(),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 20.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailingWidget != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: trailingWidget,
              ),
          ],
        ),
      ),
    );
  }
}

/// Back button graphic: the round white button artwork.
class AppBackIcon extends StatelessWidget {
  const AppBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return MirrorOnRtl(
      child: Image.asset(AppAssets.insightBackIcon, height: 36.h, width: 36.w),
    );
  }
}
