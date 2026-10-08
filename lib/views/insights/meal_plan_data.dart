import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../data/models/bmi_record_model.dart';
import 'meal_plan_normal.dart';
import 'meal_plan_obese.dart';
import 'meal_plan_overweight.dart';
import 'meal_plan_raw.dart';
import 'meal_plan_underweight.dart';

/// Replace these dummy images with real ones.
///
/// Put a file in assets/images and map the meal key here, e.g.
///   'underweight_d1_breakfast': 'assets/images/uw_d1_breakfast.png',
/// Meal keys look like `<category>_d<day>_<slot>` (day is 1–7, slot is
/// breakfast / lunch / dinner). Anything not listed uses the dummy photo of
/// its slot.
const Map<String, String> kMealPhotoOverrides = {};

const Map<String, String> _dummyPhoto = {
  'breakfast': AppAssets.mealGreekPhoto,
  'lunch': AppAssets.mealChickenPhoto,
  'dinner': AppAssets.mealSalmonPhoto,
};

const Map<String, String> _dummyBadge = {
  'breakfast': AppAssets.mealGreekBadge,
  'lunch': AppAssets.mealChickenBadge,
  'dinner': AppAssets.mealSalmonBadge,
};

const _slots = ['breakfast', 'lunch', 'dinner'];
const _slotTimes = {'breakfast': '8:00 AM', 'lunch': '1:00 PM', 'dinner': '7:00 PM'};
const _slotPrep = {
  'breakfast': '10 min prep',
  'lunch': '15 min prep',
  'dinner': '25 min prep',
};

class MealInfo {
  final String key;
  final BMICategory category;
  final int day;
  final String slotKey;
  final String name;
  final String blurb;
  final int kcal;
  final String photo;
  final String badge;
  final String tag;
  final IconData tagIcon;
  final String time;
  final String prep;
  final List<String> chips;
  final int protein, carbs, fat;
  final int target;
  final List<List<String>> ingredients;
  final String note;

  const MealInfo({
    required this.key,
    required this.category,
    required this.day,
    required this.slotKey,
    required this.name,
    required this.blurb,
    required this.kcal,
    required this.photo,
    required this.badge,
    required this.tag,
    required this.tagIcon,
    required this.time,
    required this.prep,
    required this.chips,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.target,
    required this.ingredients,
    required this.note,
  });

  String get slot => slotKey[0].toUpperCase() + slotKey.substring(1);

  String get shortBlurb => blurb.length > 30 ? '${blurb.substring(0, 29)}…' : blurb;

  String get heroLine => '$blurb. Part of your Day $day plan.';

  double get _macroKcal => protein * 4.0 + carbs * 4.0 + fat * 9.0;
  int get proteinPct => (protein * 4 / _macroKcal * 100).round();
  int get carbsPct => (carbs * 4 / _macroKcal * 100).round();
  int get fatPct => 100 - proteinPct - carbsPct;
}

class _CatInfo {
  final List<List<RawMeal>> plan;
  final int dailyTarget;
  final IconData tagIcon;
  final List<String> chips;
  final String note;
  const _CatInfo(this.plan, this.dailyTarget, this.tagIcon, this.chips, this.note);
}

const Map<BMICategory, _CatInfo> _cats = {
  BMICategory.underweight: _CatInfo(
    kUnderweightPlan,
    2000,
    Icons.bolt_rounded,
    ['Energy Dense', 'High Protein', 'Healthy Fats'],
    'Add a glass of milk or a handful of nuts if you are still hungry.',
  ),
  BMICategory.normal: _CatInfo(
    kNormalPlan,
    1800,
    Icons.eco_outlined,
    ['High Protein', 'Balanced', 'Heart Healthy'],
    'Swap ingredients freely to suit your taste and keep variety.',
  ),
  BMICategory.overweight: _CatInfo(
    kOverweightPlan,
    1200,
    Icons.favorite_border_rounded,
    ['High Protein', 'High Fibre', 'Light & Lean'],
    'Fill half your plate with vegetables and eat slowly.',
  ),
  BMICategory.obese: _CatInfo(
    kObesePlan,
    1100,
    Icons.favorite_border_rounded,
    ['Calorie Smart', 'High Protein', 'High Fibre'],
    'Choose water or herbal tea with meals and watch portion sizes.',
  ),
};

class MealPlanData {
  MealPlanData._();

  static int get days => 7;

  static String categoryKey(BMICategory c) => c.name;

  static List<MealInfo> mealsFor(BMICategory cat, int day) {
    final info = _cats[cat]!;
    final raw = info.plan[(day - 1).clamp(0, 6)];
    return [
      for (int i = 0; i < 3; i++)
        _build(cat, info, day, _slots[i], raw[i], raw.fold(0, (a, m) => a + m.kcal)),
    ];
  }

  static MealInfo _build(
    BMICategory cat,
    _CatInfo info,
    int day,
    String slot,
    RawMeal r,
    int dayTotal,
  ) {
    final key = '${cat.name}_d${day}_$slot';
    return MealInfo(
      key: key,
      category: cat,
      day: day,
      slotKey: slot,
      name: r.name,
      blurb: r.blurb,
      kcal: r.kcal,
      photo: kMealPhotoOverrides[key] ?? _dummyPhoto[slot]!,
      badge: _dummyBadge[slot]!,
      tag: r.tag,
      tagIcon: info.tagIcon,
      time: _slotTimes[slot]!,
      prep: _slotPrep[slot]!,
      chips: [r.tag, ...info.chips.where((c) => c != r.tag).take(2)],
      protein: r.p,
      carbs: r.c,
      fat: r.f,
      target: (r.kcal * 100 / dayTotal).round().clamp(1, 99),
      ingredients: [
        for (final part in r.ing.split(';')) part.split('|'),
      ],
      note: info.note,
    );
  }
}
