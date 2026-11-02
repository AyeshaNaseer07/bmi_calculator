import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import 'hydration_goal_screens.dart';
import 'insight_common.dart';
import '../../core/theme/app_palette.dart';

export 'hydration_goal_screens.dart';

Color get _kSub => AppPalette.textSecondary;

class _Benefit extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color bg;
  final Color border;
  final Color chevron;
  final VoidCallback onTap;
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.border,
    required this.chevron,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: ShapeDecoration(
            color: bg,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: border),
              borderRadius: BorderRadius.circular(20.r),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(icon, width: 52.w, height: 52.w, fit: BoxFit.contain),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppPalette.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, color: chevron, size: 24.sp),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Stay Hydrated" hub.
class StayHydratedScreen extends StatelessWidget {
  const StayHydratedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'stay_hydrated'.tr,
      titleIcon: Icons.water_drop_outlined,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.waterHero,
              width: 250.w,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Text(
              'drink_enough_water_daily'.tr,
              style: TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'benefits'.tr,
            style: TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          _Benefit(
            icon: AppAssets.waterBoostIcon,
            title: 'boosts_your_energy'.tr,
            subtitle: 'water_helps_your_body_and_mind'.tr,
            bg: const Color(0xFFEAFBF3),
            border: const Color(0xFFC8F0DE),
            chevron: const Color(0xFF10B981),
            onTap: () => Get.to(() => const BoostsEnergyScreen()),
          ),
          _Benefit(
            icon: AppAssets.waterSupportIcon,
            title: 'supports_digestion'.tr,
            subtitle: 'helps_your_digestive_system_work_smoothly'.tr,
            bg: const Color(0xFFEBF3FE),
            border: const Color(0xFFD3E4FB),
            chevron: const Color(0xFF3B82F6),
            onTap: () => Get.to(() => const SupportsDigestionScreen()),
          ),
          _Benefit(
            icon: AppAssets.waterGoodIcon,
            title: 'good_for_your_skin'.tr,
            subtitle: 'staying_hydrated_helps_maintain_healthy_skin'.tr,
            bg: const Color(0xFFF3EEFE),
            border: const Color(0xFFE2D6FB),
            chevron: const Color(0xFF8B5CF6),
            onTap: () => Get.to(() => const GoodForSkinScreen()),
          ),
          _Benefit(
            icon: AppAssets.waterDailyIcon,
            title: 'your_daily_goal'.tr,
            subtitle: 'find_out_how_much_water_you'.tr,
            bg: AppPalette.surfaceMuted,
            border: const Color(0xFFD7F0E6),
            chevron: AppPalette.textBody,
            onTap: () => Get.to(() => const DailyGoalScreen()),
          ),
        ],
      ),
    );
  }
}

class _MintRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  const _MintRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 14.w, 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF7EF),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppPalette.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      fontSize: 13.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _asset(String path, {double size = 24}) =>
    Image.asset(path, width: size.w, height: size.w, fit: BoxFit.contain);

/// "Boosts Your Energy".
class BoostsEnergyScreen extends StatelessWidget {
  const BoostsEnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'boosts_your_energy'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Image.asset(
                AppAssets.waterEnergy,
                width: 296.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'stay_hydrated_to_help_your_body'.tr,
              style: TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'how_water_helps'.tr,
            style: TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          _MintRow(
            icon: _asset(AppAssets.brainIcon, size: 40),
            title: 'supports_focus'.tr,
            subtitle: 'water_helps_focus'.tr,
          ),
          _MintRow(
            icon: _asset(AppAssets.moonIcon, size: 40),
            title: 'helps_reduce_tiredness'.tr,
            subtitle: 'dehydration_can_make_you_feel_tired'.tr,
          ),
          _MintRow(
            icon: _asset(AppAssets.pulseIcon, size: 40),
            title: 'supports_daily_activity'.tr,
            subtitle: 'water_helps_everyday'.tr,
          ),
          SizedBox(height: 24.h),
          TipBanner(text: 'simple_tip_keep_a_glass_of'.tr),
        ],
      ),
    );
  }
}

class SupportsDigestionScreen extends StatelessWidget {
  const SupportsDigestionScreen({super.key});

  Widget _card(Widget icon, String title, String sub) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      // Soft mint glow all round (no border), like the nutrition cards.
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3333D2AB),
            blurRadius: 8,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  sub,
                  style: TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'supports_digestion'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'water_plays_an_important_role_in'.tr,
              style: TextStyle(
                color: AppPalette.textSecondary,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'why_water_matters'.tr,
            style: TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          _card(
            _asset(AppAssets.digestionIcon, size: 40),
            'helps_digestion'.tr,
            'water_helps_your_body_digest_food'.tr,
          ),
          _card(
            _asset(AppAssets.regularityIcon, size: 40),
            'supports_regularity'.tr,
            'drinking_enough_water_helps_prevent_constipation'.tr,
          ),
          _card(
            _asset(AppAssets.absorptionIcon, size: 40),
            'helps_nutrient_absorption'.tr,
            'water_supports_absorption'.tr,
          ),
          SizedBox(height: 4.h),
          TipBanner(text: 'drink_water_with_meals'.tr),
        ],
      ),
    );
  }
}

/// "Good for Your Skin".
class GoodForSkinScreen extends StatelessWidget {
  const GoodForSkinScreen({super.key});

  Widget _card(Widget icon, Color tile, String title, String sub) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD5F2E8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A33D2AB),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: headStyle(16, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(sub, style: bodyStyle(13, color: _kSub, height: 1.35)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'good_for_your_skin'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.waterSkin,
              width: 250.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'hydration_is_part_of_a_healthy'.tr,
              style: bodyStyle(13, color: _kSub),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'how_hydration_helps'.tr,
            style: headStyle(18, weight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          _card(
            _asset(AppAssets.skinHealthIcon, size: 36),
            const Color(0xFFEAF3FE),
            'supports_skin_health'.tr,
            'water_helps_your_body_maintain_normal'.tr,
          ),
          _card(
            _asset(AppAssets.regularityIcon, size: 36),
            const Color(0xFFE6F8F1),
            'maintains_fluid_balance'.tr,
            'drinking_enough_water_helps_maintain_your'.tr,
          ),
          _card(
            _asset(AppAssets.healthyHabitsIcon, size: 36),
            const Color(0xFFF1ECFD),
            'build_healthy_habits'.tr,
            'regular_hydration_is_one_part_of'.tr,
          ),
        ],
      ),
    );
  }
}
