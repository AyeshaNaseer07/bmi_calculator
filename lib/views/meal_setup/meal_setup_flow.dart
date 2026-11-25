import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import '../insights/meal_screens.dart';
import 'dietary_preferences_step.dart';
import 'food_allergies_step.dart';
import 'health_profile_step.dart';
import 'lifestyle_step.dart';
import 'meal_plan_setup_screen.dart';
import 'meal_setup_common.dart';
import 'medical_conditions_step.dart';

/// Navigation for: overview → 5 steps → 1 Week Meal Plan.
///
/// Every route in the flow is named `/meal-…` so finishing can pop the
/// whole flow (and any earlier plan screen) in one go.
abstract class MealSetupFlow {
  static const String overviewRoute = '/meal-setup';
  static const String planRoute = '/meal-plan';
  static String stepRoute(int step) => '/meal-setup-step-$step';

  /// Steps that must be finished before the plan is built.
  static const List<int> requiredSteps = [1, 2, 3];

  /// Entry point from "View your meal plan": setup the first time,
  /// the plan itself once setup is done.
  static void openPlanOrSetup() {
    final c = MealSetupController.to;
    if (c.isComplete.value) {
      openPlan();
    } else {
      openSetup();
    }
  }

  static void openSetup() {
    MealSetupController.to.prefillHealthProfile();
    Get.to(() => const MealPlanSetupScreen(), routeName: overviewRoute);
  }

  static void openPlan() {
    MealSetupController.to.applyToPlan();
    Get.to(() => const DailyMealPlanScreen(), routeName: planRoute);
  }

  static void openStep(int step) {
    final Widget Function() page = switch (step) {
      1 => () => const HealthProfileStep(),
      2 => () => const MedicalConditionsStep(),
      3 => () => const FoodAllergiesStep(),
      4 => () => const DietaryPreferencesStep(),
      _ => () => const LifestyleStep(),
    };
    Get.to(page, routeName: stepRoute(step));
  }

  /// Overview "Continue": first unfinished step, or finish if all done.
  static void continueFromOverview() {
    final c = MealSetupController.to;
    for (int s = 1; s <= MealSetupController.totalSteps; s++) {
      if (!c.completedSteps.contains(s)) {
        openStep(s);
        return;
      }
    }
    finish();
  }

  /// Saves [step] and moves on to the next one (or builds the plan).
  static void next(int step) {
    MealSetupController.to.completeStep(step);
    if (step < MealSetupController.totalSteps) {
      openStep(step + 1);
    } else {
      finish();
    }
  }

  static Future<void> finish() async {
    final c = MealSetupController.to;
    final missing = requiredSteps.firstWhereOrNull(
      (s) => !c.completedSteps.contains(s),
    );
    if (missing != null) {
      showSetupHint('ms_finish_required_steps'.tr);
      openStep(missing);
      return;
    }
    await c.finish();
    Get.until((r) => !(r.settings.name ?? '').startsWith('/meal-'));
    Get.to(() => const DailyMealPlanScreen(), routeName: planRoute);
  }
}

/// One selectable answer: stored [key], translated [label], optional
/// [sub] line and [emoji] icon.
class SetupOption {
  final String key;
  final String label;
  final String? sub;
  final String emoji;

  /// 3D icon asset from a developer kit; preferred over [emoji].
  final String? image;
  const SetupOption(
    this.key,
    this.label, {
    this.sub,
    this.emoji = '',
    this.image,
  });
}

abstract class MealSetupOptions {
  static const String _cond = 'assets/images/meal_setup';

  static const medical = [
    SetupOption(
      'diabetes',
      'ms_diabetes',
      sub: 'ms_diabetes_sub',
      image: '$_cond/ic_3d_cond_diabetes.png',
    ),
    SetupOption(
      'high_bp',
      'ms_high_bp',
      image: '$_cond/ic_3d_cond_high_bp.png',
    ),
    SetupOption(
      'cholesterol',
      'ms_cholesterol',
      image: '$_cond/ic_3d_cond_cholesterol.png',
    ),
    SetupOption(
      'heart',
      'ms_heart_disease',
      image: '$_cond/ic_3d_cond_heart_disease.png',
    ),
    SetupOption(
      'kidney',
      'ms_kidney_disease',
      image: '$_cond/ic_3d_cond_kidney_disease.png',
    ),
    SetupOption(
      'liver',
      'ms_liver_disease',
      image: '$_cond/ic_3d_cond_liver_disease.png',
    ),
    SetupOption(
      'thyroid',
      'ms_thyroid',
      image: '$_cond/ic_3d_cond_thyroid.png',
    ),
    SetupOption(
      'pcos',
      'ms_pcos',
      sub: 'ms_pcos_sub',
      image: '$_cond/ic_3d_cond_pcos.png',
    ),
    SetupOption('celiac', 'ms_celiac', image: '$_cond/ic_3d_cond_celiac.png'),
    SetupOption('gout', 'ms_gout', image: '$_cond/ic_3d_cond_gout.png'),
    SetupOption(
      'gerd',
      'ms_acid_reflux',
      sub: 'ms_acid_reflux_sub',
      image: '$_cond/ic_3d_cond_gerd.png',
    ),
    SetupOption('anemia', 'ms_anemia', image: '$_cond/ic_3d_cond_anemia.png'),
  ];

  static const allergies = [
    SetupOption(
      'peanuts',
      'ms_peanuts',
      image: '$_cond/ic_3d_allergy_peanuts.png',
    ),
    SetupOption('dairy', 'ms_dairy', image: '$_cond/ic_3d_allergy_dairy.png'),
    SetupOption('eggs', 'ms_eggs', image: '$_cond/ic_3d_allergy_eggs.png'),
    SetupOption(
      'gluten',
      'ms_gluten',
      image: '$_cond/ic_3d_allergy_gluten.png',
    ),
    SetupOption(
      'shellfish',
      'ms_shellfish',
      sub: 'ms_shellfish_sub',
      image: '$_cond/ic_3d_allergy_shellfish.png',
    ),
    SetupOption(
      'tree_nuts',
      'ms_tree_nuts',
      sub: 'ms_tree_nuts_sub',
      image: '$_cond/ic_3d_allergy_tree_nuts.png',
    ),
    SetupOption('soy', 'ms_soy', image: '$_cond/ic_3d_allergy_soy.png'),
    SetupOption('fish', 'ms_fish', image: '$_cond/ic_3d_allergy_fish.png'),
  ];

  static const dietTypes = [
    SetupOption('vegetarian', 'ms_vegetarian'),
    SetupOption('non_vegetarian', 'ms_non_vegetarian'),
    SetupOption('vegan', 'ms_vegan'),
  ];

  static const cuisines = [
    SetupOption('pakistani', 'ms_pakistani'),
    SetupOption('indian', 'ms_indian'),
    SetupOption('asian', 'ms_asian'),
    SetupOption('mediterranean', 'ms_mediterranean'),
    SetupOption('other', 'other'),
  ];

  static const dislikes = [
    SetupOption('meat', 'ms_meat'),
    SetupOption('seafood', 'ms_seafood'),
    SetupOption('spicy', 'ms_spicy_food'),
    SetupOption('vegetables', 'ms_vegetables'),
    SetupOption('other', 'other'),
  ];

  static const mealsPerDay = [
    SetupOption('2', 'ms_meals_2'),
    SetupOption('3', 'ms_meals_3'),
    SetupOption('4', 'ms_meals_4'),
    SetupOption('5_plus', 'ms_meals_5_plus'),
  ];

  static const cooking = [
    SetupOption('quick', 'ms_quick_meals'),
    SetupOption('home_cooked', 'ms_home_cooked'),
    SetupOption('no_preference', 'ms_no_preference'),
  ];

  static const budget = [
    SetupOption('low', 'ms_budget_low'),
    SetupOption('medium', 'ms_budget_medium'),
    SetupOption('high', 'ms_budget_high'),
  ];

  static const sleep = [
    SetupOption('lt5', 'ms_sleep_lt5'),
    SetupOption('5_6', 'ms_sleep_5_6'),
    SetupOption('6_7', 'ms_sleep_6_7'),
    SetupOption('7_8', 'ms_sleep_7_8'),
    SetupOption('8_9', 'ms_sleep_8_9'),
    SetupOption('gt9', 'ms_sleep_gt9'),
  ];

  static const water = [
    SetupOption('lt1', 'ms_water_lt1'),
    SetupOption('1_1_5', 'ms_water_1_1_5'),
    SetupOption('1_5_2', 'ms_water_1_5_2'),
    SetupOption('gt2', 'ms_water_gt2'),
  ];

  static const mealTiming = [
    SetupOption('early', 'ms_early_meals', sub: 'ms_early_meals_sub'),
    SetupOption(
      'regular',
      'ms_regular_schedule',
      sub: 'ms_regular_schedule_sub',
    ),
    SetupOption('late', 'ms_late_meals', sub: 'ms_late_meals_sub'),
  ];
}
