import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

const Color _kLangShadowTeal = Color(0xFF079F7B);

class LanguageButton extends StatelessWidget {
  final double? size;

  const LanguageButton({super.key, this.size});

  void _open() {
    if (Get.currentRoute == AppRoutes.languagesSettings ||
        Get.currentRoute == AppRoutes.languageSelection) {
      return;
    }
    Get.toNamed(AppRoutes.languagesSettings);
  }

  Widget _lottie(BuildContext context, double s) {
    return Lottie.asset(
      AppAssets.languageLottie,
      width: s,
      height: s,
      fit: BoxFit.contain,
      animate: !MediaQuery.disableAnimationsOf(context),
      delegates: LottieDelegates(
        values: [
          // Blue speech bubbles → theme teal.
          for (final bubble in const ['bulle_01', 'bulle_03', 'bulle_04'])
            ValueDelegate.color([bubble, '**'], value: AppColors.primaryTeal),
          // Deep-blue glyph shadows → darker teal.
          for (final shadow in const [
            'symbole_01 shadow',
            'symbole_03_shadow',
            'symbole_04_shadow',
          ])
            ValueDelegate.color([shadow, '**'], value: _kLangShadowTeal),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = size ?? 40.w;
    return Semantics(
      button: true,
      label: 'language'.tr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _open,
        child: _lottie(context, s),
      ),
    );
  }
}
