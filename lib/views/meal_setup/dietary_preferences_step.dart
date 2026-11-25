import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _otherFoods = TextEditingController(text: c.otherDislikes.value);
  }

  @override
  void dispose() {
    _otherFoods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 4,
      titleTop: 'ms_dietary'.tr,
      titleBottom: 'ms_preferences'.tr,
      subtitle: 'ms_dietary_subtitle'.tr,
      hero: MealSetupAssets.diet,
      heroEmoji: '🍽️',
      body: Column(
        children: [
          _section(
            image: _ic('diet_type'),
            title: 'ms_diet_type'.tr,
            subtitle: 'ms_choose_diet_type'.tr,
            child: _single(MealSetupOptions.dietTypes, c.dietType),
          ),
          _section(
            image: _ic('cuisine_globe'),
            title: 'ms_cuisine_preference'.tr,
            subtitle: 'ms_select_favorite_cuisine'.tr,
            child: _single(MealSetupOptions.cuisines, c.cuisine),
          ),
          _section(
            image: _ic('foods_dislike'),
            title: 'ms_foods_you_dislike'.tr,
            subtitle: 'ms_select_foods_dislike'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final o in MealSetupOptions.dislikes)
                        SetupChip(
                          label: o.label.tr,
                          selected: c.dislikes.contains(o.key),
                          onTap: () => c.toggleDislike(o.key),
                        ),
                    ],
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
                  onChanged: (v) => c.otherDislikes.value = v,
                ),
              ],
            ),
          ),
          _section(
            image: _ic('meals_per_day'),
            title: 'ms_meals_per_day'.tr,
            subtitle: 'ms_how_many_meals'.tr,
            child: _single(MealSetupOptions.mealsPerDay, c.mealsPerDay),
          ),
          _section(
            image: _ic('cooking_preference'),
            title: 'ms_cooking_preference'.tr,
            subtitle: 'ms_preferred_cooking_style'.tr,
            child: _single(MealSetupOptions.cooking, c.cooking),
          ),
          _section(
            image: _ic('budget_wallet'),
            title: 'ms_budget'.tr,
            subtitle: 'ms_select_budget'.tr,
            child: _single(MealSetupOptions.budget, c.budget),
          ),
        ],
      ),
      bottom: SetupCta(
        text: 'next'.tr,
        onPressed: () {
          FocusScope.of(context).unfocus();
          MealSetupFlow.next(4);
        },
      ),
    );
  }

  /// Single-choice chips; tapping the selected chip clears it.
  Widget _single(List<SetupOption> options, RxnString value) {
    return Obx(
      () => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          for (final o in options)
            SetupChip(
              label: o.label.tr,
              selected: value.value == o.key,
              onTap: () => value.value = value.value == o.key ? null : o.key,
            ),
        ],
      ),
    );
  }

  static String _ic(String name) =>
      'assets/images/meal_setup/ic_3d_diet_$name.png';

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
