import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/meal_plan_controller.dart';
import '../../core/constants/app_assets.dart';
import 'insight_common.dart';
import 'meal_plan_data.dart';
import 'meal_progress_screens.dart';
import '../../core/theme/app_palette.dart';

export 'meal_plan_data.dart';
export 'meal_progress_screens.dart';

Color get _kDeep => const Color(0xFF006B4E);
const Color _kDeepFill = Color(0xFF006B4E);
Color get _kLav => const Color(0xFFEDEFFB);

/// "1 Week Meal Plan" — the Meal Planner list.
class DailyMealPlanScreen extends StatelessWidget {
  const DailyMealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'n_1_week_meal_plan'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'meal_planner'.tr,
            style: TextStyle(
              color: AppPalette.textPrimary,
              fontSize: 18.sp,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: -0.18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          const _TargetBanner(),
          SizedBox(height: 12.h),
          const _DayMeals(),
          SizedBox(height: 4.h),
          const _PlanDisclaimer(),
          SizedBox(height: 10.h),
          TipBanner(text: 'remember_portions'.tr),
        ],
      ),
    );
  }
}

/// "Your daily target" line, shown when the user's profile is known.
class _TargetBanner extends StatelessWidget {
  const _TargetBanner();

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    if (c.targetKcal <= 0) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _kLav,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'daily_target_line'.trParams({
          'kcal': '${c.targetKcal}',
          'goal': c.goal,
        }),
        style: TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 12.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PlanDisclaimer extends StatelessWidget {
  const _PlanDisclaimer();

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return PrecautionCard(
      // Under 18 the key message is to not follow this plan at all.
      lead: c.needsCare
          ? 'under_18_warning'.tr
          : 'this_plan_is_general_guidance_not'.tr,
      body: 'plan_based_on'.tr,
    );
  }
}

/// Day selector + the three meals of the selected day.
class _DayMeals extends StatelessWidget {
  const _DayMeals();

  Widget _dayChip(MealPlanController c, int d) {
    final selected = c.selectedDay.value == d;
    final done = c.eatenOnDay(d) == 3;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => c.selectedDay.value = d,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.symmetric(vertical: 7.h),
          decoration: BoxDecoration(
            // Selected stays deep green in both themes (white text on it).
            color: selected
                ? _kDeepFill
                : (done ? const Color(0xFFC9F7E3) : AppPalette.surface),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? _kDeepFill : const Color(0xFFD5F2E8),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'day_caps'.tr,
                style: bodyStyle(
                  8.5,
                  color: selected ? Colors.white70 : AppPalette.textSecondary,
                  weight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$d',
                style: headStyle(
                  15,
                  color: selected ? Colors.white : _kDeep,
                  weight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return Obx(() {
      final day = c.selectedDay.value;
      final meals = MealPlanData.mealsFor(
        c.category,
        day,
        targetKcal: c.targetKcal,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [for (int d = 1; d <= 7; d++) _dayChip(c, d)]),
          SizedBox(height: 14.h),
          for (final m in meals) _MealCard(meal: m),
        ],
      );
    });
  }
}

class _MealCard extends StatelessWidget {
  final MealInfo meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFDDF4EC)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F33D2AB),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 86.w,
              height: 86.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AssetOrPlaceholder(asset: meal.photo, circle: true),
                  ),
                  PositionedDirectional(
                    end: -4.w,
                    bottom: 2.h,
                    child: Image.asset(meal.badge, width: 30.w, height: 30.w),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        meal.slot.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFF006948),
                          fontSize: 11.sp,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.27,
                          letterSpacing: 0.55,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF8EC),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 13.sp,
                              color: _kDeep,
                            ),
                            SizedBox(width: 3.w),
                            Flexible(
                              child: Text(
                                '${meal.kcal} ${'unit_kcal'.tr}',
                                style: bodyStyle(
                                  12,
                                  color: _kDeep,
                                  weight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      meal.name,
                      style: TextStyle(
                        color: AppPalette.textPrimary,
                        fontSize: 18.sp,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                        letterSpacing: -0.18,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    meal.shortBlurb,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppPalette.textBody,
                      fontSize: 13.sp,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                      letterSpacing: 0.06,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Image.asset(
                        AppAssets.mealProtein,
                        width: 16.w,
                        height: 16.h,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          meal.tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppPalette.textBody,
                            fontSize: 11.sp,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.27,
                            letterSpacing: 0.44,
                          ),
                        ),
                      ),
                      Obx(() {
                        final done = MealPlanController.to.isEaten(meal.key);
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              Get.to(() => MealDetailScreen(meal: meal)),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: done ? kGreen : _kDeepFill,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x33006B4E),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'view'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.29,
                                letterSpacing: 0.14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }),
                    ],
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

class _TealPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TealPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF33D2AB),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.27,
              letterSpacing: 0.44,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Today's Lunch" detail screen.
class MealDetailScreen extends StatelessWidget {
  final MealInfo meal;
  const MealDetailScreen({super.key, required this.meal});

  Widget _macro(String label, String value, String sub, {bool hi = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: hi ? const Color(0xFF8FF0CD).withValues(alpha: 0.6) : _kLav,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Stack(
          // The highlight dot sits in the card's top padding — don't clip it.
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    label,
                    style: bodyStyle(
                      11,
                      color: hi ? _kDeep : AppPalette.textBody,
                      weight: FontWeight.w600,
                    ).copyWith(letterSpacing: 0.4),
                  ),
                  SizedBox(height: 4.h),
                  Text(value, style: headStyle(20, weight: FontWeight.w700)),
                  SizedBox(height: 2.h),
                  Text(
                    sub,
                    style: bodyStyle(
                      12,
                      color: hi ? _kDeep : AppPalette.textSecondary,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (hi)
              PositionedDirectional(
                top: -6.h,
                end: 4.w,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: _kDeep,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9.w,
        height: 9.w,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      SizedBox(width: 6.w),
      Text(
        t,
        style: bodyStyle(
          12.5,
          color: AppPalette.textPrimary,
          weight: FontWeight.w600,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: meal.day == 1
          ? 'todays_meal'.trParams({'meal': meal.slot})
          : 'day_meal'.trParams({'day': '${meal.day}', 'meal': meal.slot}),
      // Once a meal is eaten it can't be marked again.
      bottom: Obx(() {
        final eaten = MealPlanController.to.isEaten(meal.key);
        return GradientActionButton(
          text: eaten ? 'marked'.tr : 'mark_as_eaten'.tr,
          leading: Icons.check_circle_outline_rounded,
          onTap: eaten
              ? null
              : () {
                  MealPlanController.to.markEaten(meal.key);
                  Get.off(() => MealCompletedScreen(meal: meal));
                },
        );
      }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TealPill(
                icon: Icons.wb_sunny_outlined,
                text: 'day_dot_meal'.trParams({
                  'day': '${meal.day}',
                  'meal': meal.slot,
                }),
              ),
              _TealPill(icon: Icons.schedule_rounded, text: meal.time),
            ],
          ),
          SizedBox(height: 12.h),
          // Hero photo with overlays
          AspectRatio(
            aspectRatio: 1023 / 639,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AssetOrPlaceholder(
                    asset: meal.photo,
                    fit: BoxFit.cover,
                    radius: 0,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.62),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 10.h,
                    start: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: _kDeep,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'balanced_meal_kcal'.trParams({
                                'meal': meal.slot.toUpperCase(),
                                'kcal': '${meal.kcal}',
                              }),
                              style: bodyStyle(
                                11.5,
                                color: _kDeep,
                                weight: FontWeight.w800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 10.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                meal.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: headStyle(
                                  22,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                meal.heroLine,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: bodyStyle(
                                  8.5,
                                  color: Colors.white,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14.sp,
                                color: _kDeep,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                meal.prep,
                                style: bodyStyle(
                                  12,
                                  color: kInk,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              for (int i = 0; i < meal.chips.length; i++) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: i == 0 ? const Color(0xFFC5F6E3) : _kLav,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    width: 79.5.w,
                    child: Text(
                      meal.chips[i],
                      style: bodyStyle(
                        12.5,
                        color: _kDeep,
                        weight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          // Nutrition summary
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 6.h),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: kMintBorder, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1F33D2AB),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      AppAssets.mealSlotLunch,
                      width: 14.w,
                      height: 14.h,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'nutrition_summary'.tr,
                        style: headStyle(16, weight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'target_pct_daily'.trParams({'pct': '${meal.target}'}),
                        textAlign: TextAlign.end,
                        style: bodyStyle(12, color: AppPalette.textBody),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _macro('energy_caps'.tr, '${meal.kcal}', 'kcal'),
                    _macro(
                      'protein_caps'.tr,
                      '${meal.protein}${'unit_g'.tr}',
                      '${meal.proteinPct}%',
                      hi: true,
                    ),
                    _macro(
                      'carbs_caps'.tr,
                      '${meal.carbs}${'unit_g'.tr}',
                      '${meal.carbsPct}%',
                    ),
                    _macro('fat_caps'.tr, '${meal.fat}g', '${meal.fatPct}%'),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: SizedBox(
                    height: 9.h,
                    child: Row(
                      children: [
                        Expanded(
                          flex: meal.proteinPct,
                          child: Container(color: _kDeep),
                        ),
                        Expanded(
                          flex: meal.carbsPct,
                          child: Container(color: const Color(0xFF3EE0A8)),
                        ),
                        Expanded(
                          flex: meal.fatPct,
                          child: Container(color: AppPalette.border),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dot(_kDeep, 'protein'.tr),
                    _dot(const Color(0xFF3EE0A8), 'carbs'.tr),
                    _dot(AppPalette.textMuted, 'healthy_fats'.tr),
                  ],
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.to(() => IngredientsScreen(meal: meal)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: kMintBorder, width: 1.4),
              ),
              child: Row(
                children: [
                  Image.asset(AppAssets.flowerIcon, width: 22.w, height: 24.h),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'ingredients'.tr,
                      style: headStyle(18, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'items_count'.trParams({
                      'count': '${meal.ingredients.length}',
                    }),
                    style: bodyStyle(
                      14,
                      color: _kDeep,
                      weight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_ios, size: 15.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ingredients list.
class IngredientsScreen extends StatelessWidget {
  final MealInfo meal;
  const IngredientsScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'ingredients'.tr,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 10.h),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: kMintBorder, width: 1.4),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4.w, 8.h),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppAssets.flowerIcon,
                          width: 16.w,
                          height: 18.h,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'items_count'.trParams({
                              'count': '${meal.ingredients.length}',
                            }),
                            style: TextStyle(
                              color: const Color(0xFF006948),
                              fontSize: 14.sp,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                              height: 1.27,
                              letterSpacing: 0.44,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (meal.portionLabel.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'portion_adjusted'.trParams({
                        'portion': meal.portionLabel,
                      }),
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 11.sp,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                for (final ing in meal.ingredients)
                  Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBFAF4),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: AppPalette.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20.sp,
                            color: _kDeep,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            ing[0],
                            style: bodyStyle(
                              16,
                              color: kInk,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          ing[1],
                          style: bodyStyle(
                            13,
                            color: AppPalette.textBody,
                            weight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          TipBanner(text: meal.note),
        ],
      ),
    );
  }
}
