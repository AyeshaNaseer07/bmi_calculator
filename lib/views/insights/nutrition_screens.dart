import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../onboarding/soft_paywall_screen.dart';
import '../widgets/premium_feature_dialog.dart';
import 'insight_common.dart';
import 'meal_screens.dart';
import '../../core/theme/app_palette.dart';

export 'meal_screens.dart';

class EatBalancedMealsScreen extends StatelessWidget {
  const EatBalancedMealsScreen({super.key});

  static void _openMealPlan() {
    if (Get.find<AppController>().isPremium.value) {
      Get.to(() => const DailyMealPlanScreen());
      return;
    }
    Get.to(
      () => SoftPaywallScreen(
        onUnlocked: () => Get.to(() => const DailyMealPlanScreen()),
        onDismissed: () {
          Future.delayed(const Duration(milliseconds: 300), () {
            PremiumFeatureDialog.show(
              message: 'meal_plan_premium_message'.tr,
              onUnlock: _openMealPlan,
            );
          });
        },
      ),
      transition: Transition.downToUp,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'eat_balanced_meals'.tr,
      body: Column(
        children: [
          SizedBox(height: 4.h),
          SizedBox(
            height: 170.w,
            child: Center(
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x6633D2AB),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: AssetOrPlaceholder(
                  asset: AppAssets.tipMeals,
                  width: 140.w,
                  height: 140.w,
                  circle: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(
              color: const Color(0x666CF8BB).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.leafIcon, width: 12.w, height: 12.h),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(
                    'nutrition_guide'.tr,
                    style: TextStyle(
                      color: const Color(0xFF00714D),
                      fontSize: 11,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.27,
                      letterSpacing: 0.55,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'build_healthy_eating_habits_one_meal'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 11.5,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: 0.06,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          _HubCard(
            iconAsset: AppAssets.tipMoreVeggies,
            title: 'eat_more_vegetables'.tr,
            subtitle: 'add_vegetables_and_fiber_to_your'.tr,
            onTap: () => Get.to(() => const EatVegetablesScreen()),
          ),
          _HubCard(
            iconAsset: AppAssets.tipLeanProtein,
            title: 'choose_lean_protein'.tr,
            subtitle: 'include_eggs_fish_beans_or_chicken'.tr,
            onTap: () => Get.to(() => const LeanProteinScreen()),
          ),
          _HubCard(
            iconAsset: AppAssets.tipPortionControl,
            title: 'control_portion_sizes'.tr,
            subtitle: 'enjoy_balanced_portions_at_every_meal'.tr,
            onTap: () => Get.to(() => const PortionSizesScreen()),
          ),
          _HubCard(
            iconAsset: AppAssets.tipDailyMealPlan,
            title: 'n_1_week_meal_plan'.tr,
            subtitle: 'explore_simple_ideas_for_balanced_meals'.tr,
            pro: true,
            onTap: _openMealPlan,
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool pro;

  const _HubCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.pro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(20.r),
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
              Image.asset(iconAsset, width: 50.w, height: 50.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: AppPalette.textPrimary,
                              fontSize: 15.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // The premium mark goes away once subscribed.
                        if (pro)
                          Obx(
                            () => Get.find<AppController>().isPremium.value
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: 6.w,
                                    ),
                                    child: Image.asset(
                                      AppAssets.weekPro,
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.chevron_right_rounded,
                color: AppPalette.textMuted,
                size: 26.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EatVegetablesScreen extends StatelessWidget {
  const EatVegetablesScreen({super.key});

  static BoxDecoration get _cardDeco => BoxDecoration(
    color: AppPalette.surface,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
        color: const Color(0x3333D2AB),
        blurRadius: 8,
        offset: Offset.zero,
      ),
    ],
  );

  static TextStyle _title(double size) => TextStyle(
    color: AppPalette.textPrimary,
    fontSize: size,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  static TextStyle get _sub => TextStyle(
    color: AppPalette.textSecondary,
    fontSize: 13,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle get _section => TextStyle(
    color: AppPalette.textPrimary,
    fontSize: 18,
    fontFamily: 'Plus Jakarta Sans',
    fontWeight: FontWeight.w700,
  );

  Widget _why(String icon, String title, String subtitle) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: _cardDeco,
    child: Row(
      children: [
        Image.asset(icon, width: 42.w, height: 42.w),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, style: _title(15)),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _sub,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'eat_more_vegetables'.tr,
      scroll: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 869 / 569,
                child: Image.asset(
                  AppAssets.photoVegetables,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'add_more_color_and_fiber_to'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'why_vegetables_matter'.tr,
            style: _section,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          _why(
            AppAssets.tipRichInFiber,
            'rich_in_fiber'.tr,
            'fiber_helps_you_feel_full_and'.tr,
          ),
          _why(
            AppAssets.tipFullOfNutrients,
            'full_of_nutrients'.tr,
            'vegetables_provide_vitamins_and_minerals'.tr,
          ),
          _why(
            AppAssets.tipAddMoreColor,
            'add_more_color'.tr,
            'choose_different_vegetables_for_variety'.tr,
          ),
          SizedBox(height: 4.h),
          Text(
            'try_this_today'.tr,
            style: _section,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: _cardDeco,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.asset(
                        AppAssets.tipSimpleMeal,
                        width: 58.w,
                        height: 58.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'simple_meal'.tr,
                            style: _title(16.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'half_plate_of_vegetables_quarter_protein'.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _sub,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'start_by_adding_vegetables_to_one'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _sub.copyWith(color: AppPalette.textBody),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeanProteinScreen extends StatelessWidget {
  const LeanProteinScreen({super.key});

  Widget _choice(String asset, String title, String subtitle) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
    decoration: BoxDecoration(
      color: const Color(0xFFD9F5EC),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: const Color(0xFF2CC99E)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 40.w, height: 40.w, fit: BoxFit.contain),
        SizedBox(height: 12.h),
        Text(
          title,
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  Widget _choiceRow(Widget left, Widget right) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        SizedBox(width: 16.w),
        Expanded(child: right),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'choose_lean_protein'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoBalancedMeal,
            width: double.infinity,
            height: 182.h,
            radius: 20.r,
          ),
          SizedBox(height: 14.h),
          TipBanner(text: 'include_a_source_of_protein_in'.tr),
          SizedBox(height: 14.h),
          SectionTitle('healthy_protein_choices'.tr),
          _choiceRow(
            _choice(
              AppAssets.proteinEgg,
              'eggs'.tr,
              'an_easy_source_of_protein'.tr,
            ),
            _choice(
              AppAssets.proteinFish,
              'fish'.tr,
              'provides_protein_and_important_nutrients'.tr,
            ),
          ),
          SizedBox(height: 18.h),
          _choiceRow(
            _choice(
              AppAssets.proteinBeans,
              'beans_lentils'.tr,
              'offer_protein_and_fiber'.tr,
            ),
            _choice(
              AppAssets.proteinChicken,
              'chicken'.tr,
              'a_versatile_source_of_lean_protein'.tr,
            ),
          ),
        ],
      ),
    );
  }
}

class PortionSizesScreen extends StatelessWidget {
  const PortionSizesScreen({super.key});

  Widget _step(String icon, String title, String subtitle) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
        Image.asset(icon, width: 52.w, height: 52.w, fit: BoxFit.contain),
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
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 13.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'control_portion_sizes'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1020 / 550,
            child: AssetOrPlaceholder(
              asset: AppAssets.portionSizeHero,
              width: double.infinity,
              fit: BoxFit.contain,
              radius: 20,
            ),
          ),
          SizedBox(height: 14.h),
          Center(
            child: Text(
              'enjoy_balanced_portions_without_skipping_meals'.tr,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.57,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 14.h),
          _step(
            AppAssets.tipMoreVeggies,
            'half_your_plate'.tr,
            'fill_half_your_plate_with_vegetables'.tr,
          ),
          _step(
            AppAssets.portionAddProtein,
            'add_protein'.tr,
            'use_one_quarter_of_your_plate'.tr,
          ),
          _step(
            AppAssets.portionWholeGrain,
            'include_whole_grains'.tr,
            'fill_the_remaining_quarter_with_whole'.tr,
          ),
          SizedBox(height: 4.h),
          TipBanner(text: 'a_simple_habit_eat_slowly_and'.tr),
        ],
      ),
    );
  }
}
