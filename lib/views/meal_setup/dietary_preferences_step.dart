import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import '../../core/constants/app_assets.dart';
import 'meal_setup_common.dart';
import 'meal_setup_flow.dart';

/// Step 4 — Dietary Preferences (all optional).
class DietaryPreferencesStep extends StatefulWidget {
  const DietaryPreferencesStep({super.key});

  @override
  State<DietaryPreferencesStep> createState() => _DietaryPreferencesStepState();
}

class _DietaryPreferencesStepState extends State<DietaryPreferencesStep> {
  final c = MealSetupController.to;
  late final TextEditingController _otherFoods;
  late final Worker _clearOther;

  @override
  void initState() {
    super.initState();
    _otherFoods = TextEditingController(text: c.otherDislikes.value);
    // Choosing "None" clears the typed foods.
    _clearOther = ever<String>(c.otherDislikes, (v) {
      if (v.isEmpty && _otherFoods.text.isNotEmpty) _otherFoods.clear();
    });
  }

  @override
  void dispose() {
    _clearOther.dispose();
    _otherFoods.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!c.dietValid) {
      final needsOther =
          c.dislikes.contains('other') && c.otherDislikes.value.trim().isEmpty;
      showSetupHint(
        needsOther ? 'ms_fill_other_dislike'.tr : 'ms_fill_diet'.tr,
      );
      return;
    }
    MealSetupFlow.next(4);
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 4,
      titleTop: 'ms_dietary'.tr,
      titleBottom: 'ms_preferences'.tr,
      subtitle: 'ms_dietary_subtitle'.tr,
      hero: MealSetupAssets.diet,
      body: Column(
        children: [
          _section(
            image: AppAssets.msDietType,
            title: 'ms_diet_type'.tr,
            subtitle: 'ms_choose_diet_type'.tr,
            child: _single(MealSetupOptions.dietTypes, c.dietType),
          ),
          _section(
            image: AppAssets.msDietCuisine,
            title: 'ms_cuisine_preference'.tr,
            subtitle: 'ms_select_favorite_cuisine'.tr,
            child: _single(MealSetupOptions.cuisines, c.cuisine),
          ),
          _section(
            image: AppAssets.msDietFoodsDislike,
            title: 'ms_foods_you_dislike'.tr,
            subtitle: 'ms_select_foods_dislike'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => _chipLine(
                    MealSetupOptions.dislikes,
                    isOn: c.dislikes.contains,
                    onTap: c.toggleDislike,
                  ),
                ),
                SizedBox(height: 10.h),
                SetupTextField(
                  controller: _otherFoods,
                  hint: 'ms_add_other_foods'.tr,
                  hintColor: kMsTextSecondary,
                  hintSize: 12.5,
                  radius: 20,
                  verticalPadding: 8,
                  maxLength: 120,
                  prefixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(start: 12.w, end: 6.w),
                    child: SvgPicture.asset(
                      MealSetupAssets.pencil,
                      width: 15.w,
                      height: 15.w,
                    ),
                  ),
                  onChanged: c.setOtherDislikes,
                ),
              ],
            ),
          ),
          _section(
            image: AppAssets.msDietMealsPerDay,
            title: 'ms_meals_per_day'.tr,
            subtitle: 'ms_how_many_meals'.tr,
            child: _single(MealSetupOptions.mealsPerDay, c.mealsPerDay),
          ),
          _section(
            image: AppAssets.msDietCookingPreference,
            title: 'ms_cooking_preference'.tr,
            subtitle: 'ms_preferred_cooking_style'.tr,
            child: _single(MealSetupOptions.cooking, c.cooking),
          ),
          _section(
            image: AppAssets.msDietBudget,
            title: 'ms_budget'.tr,
            subtitle: 'ms_select_budget'.tr,
            child: _single(MealSetupOptions.budget, c.budget),
          ),
        ],
      ),
      bottom: Obx(
        () => SetupCta(text: 'next'.tr, enabled: c.dietValid, onPressed: _next),
      ),
    );
  }

  /// Single-choice chips; tapping the selected chip clears it.
  Widget _single(List<SetupOption> options, RxnString value) {
    return Obx(
      () => _chipLine(
        options,
        isOn: (k) => value.value == k,
        onTap: (k) => value.value = value.value == k ? null : k,
      ),
    );
  }

  /// All chips on one line, scaled down when they don't fit the card.
  /// An invisible copy (with room for one check mark) sets the size, so
  /// the row doesn't rescale when a chip is selected.
  Widget _chipLine(
    List<SetupOption> options, {
    required bool Function(String key) isOn,
    required void Function(String key) onTap,
  }) {
    Widget row({required bool ghost}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: 5.w),
          SetupChip(
            label: options[i].label.tr,
            selected: !ghost && isOn(options[i].key),
            onTap: () => onTap(options[i].key),
          ),
        ],
        if (ghost) SizedBox(width: SetupChip.checkExtraWidth),
      ],
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Stack(
        children: [
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: row(ghost: true),
          ),
          row(ghost: false),
        ],
      ),
    );
  }

  Widget _section({
    required String image,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SetupCard(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SetupIconTile(image: image, size: 62),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SetupCardTitle(
                    title: title,
                    subtitle: subtitle,
                    subtitleColor: kMsSubtitle,
                  ),
                  SizedBox(height: 8.h),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
