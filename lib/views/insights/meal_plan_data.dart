import 'package:flutter/material.dart';

import '../../data/models/bmi_record_model.dart';
import 'meal_plan_normal.dart';
import 'meal_plan_obese.dart';
import 'meal_plan_overweight.dart';
import 'meal_plan_raw.dart';
import 'meal_plan_underweight.dart';

/// Optional per-meal photo overrides, by meal key. Put a file in
/// assets/images and map the key here, e.g.
///   'underweight_d1_breakfast': 'assets/images/uw_d1_breakfast.png',
/// Meal keys look like `<category>_d<day>_<slot>` (day is 1–7, slot is
/// breakfast / lunch / dinner). Anything not listed uses the photo mapped to the
/// dish name in `_mealPhotos`.
const Map<String, String> kMealPhotoOverrides = {};

const String _meals = 'assets/images/meals';
const String _fallbackPhoto = '$_meals/oatmeal_bowl.jpg';
const String _badges = 'assets/images/badges';

/// Photo for each dish, by meal name (shared by all four BMI plans).
const Map<String, String> _mealPhotos = {
  'Peanut Butter Oats': '$_meals/peanut_butter_oats.jpg',
  'Chicken & Rice Bowl': '$_meals/chicken_rice_bowl.jpg',
  'Salmon, Quinoa & Avocado': '$_meals/salmon_quinoa_avocado.jpg',
  'Cheese Omelette & Toast': '$_meals/cheese_omelette_toast.jpg',
  'Beef & Sweet Potato Wrap': '$_meals/beef_sweet_potato_wrap.jpg',
  'Creamy Chicken Pasta': '$_meals/creamy_chicken_pasta.jpg',
  'Nutty Smoothie Bowl': '$_meals/smoothie_bowl.jpg',
  'Tuna Pasta Salad': '$_meals/tuna_pasta.jpg',
  'Lamb Curry with Rice': '$_meals/lamb_curry_rice.jpg',
  'Avocado Egg Toast': '$_meals/egg_avocado_toast.jpg',
  'Turkey Hummus Sandwich': '$_meals/turkey_sandwich.jpg',
  'Beef & Noodle Stir-fry': '$_meals/beef_stir_fry_noodles.jpg',
  'Granola Yogurt Parfait': '$_meals/granola_yogurt_parfait.jpg',
  'Falafel Rice Plate': '$_meals/falafel_plate.jpg',
  'Baked Cod & Potatoes': '$_meals/baked_cod.jpg',
  'Banana Pancakes': '$_meals/banana_pancakes.jpg',
  'Chicken Quesadilla': '$_meals/chicken_quesadilla.jpg',
  'Lentil Veggie Stew': '$_meals/lentil_soup.jpg',
  'Overnight Oats & Almonds': '$_meals/overnight_oats_jar.jpg',
  'Egg Fried Rice Bowl': '$_meals/egg_fried_rice.jpg',
  'Roast Chicken & Mash': '$_meals/roast_chicken_mashed_potato.jpg',
  'Greek Yogurt Bowl': '$_meals/greek_yogurt_berries.jpg',
  'Grilled Chicken Salad': '$_meals/grilled_chicken_salad.jpg',
  'Salmon & Vegetables': '$_meals/salmon_vegetables.jpg',
  'Veggie Scramble & Toast': '$_meals/veggie_scramble_toast.jpg',
  'Quinoa Chickpea Bowl': '$_meals/quinoa_chickpea_bowl.jpg',
  'Turkey Stir-fry & Rice': '$_meals/turkey_stir_fry.jpg',
  'Oats with Berries': '$_meals/oatmeal_bowl.jpg',
  'Tuna Whole-grain Wrap': '$_meals/tuna_wrap.jpg',
  'Baked Cod & Veg': '$_meals/baked_cod.jpg',
  'Lentil Veggie Soup': '$_meals/lentil_soup.jpg',
  'Chicken Fajita Plate': '$_meals/chicken_fajita.jpg',
  'Fruit & Cottage Cheese': '$_meals/cottage_cheese_fruit.jpg',
  'Mediterranean Chicken Bowl': '$_meals/mediterranean_chicken_bowl.jpg',
  'Shrimp Veggie Noodles': '$_meals/shrimp_noodles.jpg',
  'Banana Oat Pancakes': '$_meals/banana_oat_pancakes.jpg',
  'Hummus Veggie Sandwich': '$_meals/hummus_veggie_sandwich.jpg',
  'Salmon & Quinoa': '$_meals/salmon_with_quinoa.jpg',
  'Chia Pudding & Fruit': '$_meals/chia_pudding.jpg',
  'Chicken Rice Bowl': '$_meals/chicken_rice_bowl.jpg',
  'Veggie Lentil Curry': '$_meals/lentil_curry.jpg',
  'Veggie Egg-White Omelette': '$_meals/veggie_omelette.jpg',
  'Grilled Chicken & Greens': '$_meals/grilled_chicken_salad.jpg',
  'Baked Fish & Veg': '$_meals/baked_cod.jpg',
  'Berry Protein Smoothie': '$_meals/smoothie_bowl.jpg',
  'Turkey Lettuce Wraps': '$_meals/turkey_lettuce_wraps.jpg',
  'Zucchini Noodles & Chicken': '$_meals/zucchini_noodles.jpg',
  'Light Overnight Oats': '$_meals/overnight_oats_jar.jpg',
  'Chickpea Salad Bowl': '$_meals/chickpea_salad.jpg',
  'Grilled Shrimp & Veg': '$_meals/grilled_shrimp.jpg',
  'Greek Yogurt & Apple': '$_meals/greek_yogurt_berries.jpg',
  'Herbed Chicken & Broccoli': '$_meals/chicken_broccoli.jpg',
  'Mushroom Scramble': '$_meals/mushroom_scramble.jpg',
  'Tuna Cucumber Bowl': '$_meals/tuna_salad.jpg',
  'Baked Cod & Cauli Mash': '$_meals/baked_cod.jpg',
  'Cottage Cheese & Berries': '$_meals/cottage_cheese_fruit.jpg',
  'Chicken Veggie Soup': '$_meals/chicken_soup.jpg',
  'Turkey Meatballs & Salad': '$_meals/turkey_meatballs.jpg',
  'Chia Oat Bowl': '$_meals/chia_pudding.jpg',
  'Grilled Veggie Wrap': '$_meals/grilled_veggie_wrap.jpg',
  'Steamed Fish & Greens': '$_meals/steamed_fish_greens.jpg',
  'Spinach Egg-White Wrap': '$_meals/egg_white_wrap.jpg',
  'Yogurt & Berries': '$_meals/greek_yogurt_berries.jpg',
  'Veggie Lentil Soup': '$_meals/lentil_soup.jpg',
  'Lemon Herb Chicken': '$_meals/lemon_herb_chicken.jpg',
  'Veggie Omelette': '$_meals/veggie_omelette.jpg',
  'Cucumber Tuna Bowl': '$_meals/tuna_salad.jpg',
  'Baked Cod & Zucchini': '$_meals/baked_cod.jpg',
  'Chickpea Veggie Bowl': '$_meals/chickpea_salad.jpg',
  'Grilled Shrimp Salad': '$_meals/grilled_shrimp.jpg',
  'Protein Smoothie': '$_meals/smoothie_bowl.jpg',
  'Turkey Veggie Wrap': '$_meals/turkey_lettuce_wraps.jpg',
  'Chicken & Broccoli': '$_meals/chicken_broccoli.jpg',
  'Cottage Cheese & Fruit': '$_meals/cottage_cheese_fruit.jpg',
  'Baked Fish & Cauliflower': '$_meals/baked_cod.jpg',
  'Chia Berry Cup': '$_meals/chia_pudding.jpg',
  'Grilled Veggie Bowl': '$_meals/grilled_veggie_wrap.jpg',
  'Herbed Turkey & Salad': '$_meals/turkey_meatballs.jpg',
};

/// Picks the badge icon that best fits a dish photo file name.
String _badgeFor(String photo) {
  final n = photo.split('/').last.toLowerCase();
  bool has(List<String> k) => k.any(n.contains);
  String b;
  if (has(['shrimp'])) {
    b = 'shrimp';
  } else if (has(['salmon', 'cod', 'tuna', 'fish'])) {
    b = 'salmon';
  } else if (has(['avocado'])) {
    b = 'avocado';
  } else if (has(['egg', 'omelette', 'scramble'])) {
    b = 'egg';
  } else if (has(['pancake'])) {
    b = 'pancake';
  } else if (has(['smoothie'])) {
    b = 'smoothie';
  } else if (has(['yogurt', 'cottage'])) {
    b = 'yogurt';
  } else if (has(['curry'])) {
    b = 'curry';
  } else if (has(['soup', 'stew'])) {
    b = 'soup';
  } else if (has(['oat', 'granola', 'chia'])) {
    b = 'oats';
  } else if (has(['wrap', 'sandwich', 'quesadilla', 'fajita'])) {
    b = 'wrap';
  } else if (has(['salad', 'chickpea', 'quinoa', 'falafel', 'zucchini'])) {
    b = 'salad';
  } else {
    b = 'chicken';
  }
  return '$_badges/$b.png';
}

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

  /// How much the base portion was scaled to fit the user's calorie target.
  final double portion;

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
    this.portion = 1.0,
  });

  /// e.g. `Portion ×1.3`, empty when the base portion is used.
  String get portionLabel => (portion - 1).abs() < 0.04
      ? ''
      : 'Portion ×${portion.toStringAsFixed(1)}';

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

  /// The three meals of [day]. When [targetKcal] is given, portions are scaled
  /// so the day adds up to that personal calorie target.
  static List<MealInfo> mealsFor(
    BMICategory cat,
    int day, {
    int targetKcal = 0,
  }) {
    final info = _cats[cat]!;
    final raw = info.plan[(day - 1).clamp(0, 6)];
    final dayTotal = raw.fold(0, (a, m) => a + m.kcal);
    final scale = targetKcal > 0 ? targetKcal / dayTotal : 1.0;
    return [
      for (int i = 0; i < 3; i++)
        _build(cat, info, day, _slots[i], raw[i], dayTotal, scale),
    ];
  }

  static int _scaled(int v, double scale, {int step = 1}) =>
      ((v * scale) / step).round() * step;

  /// Scales the leading number of a quantity like `150g`, `1/2 cup`, `2 large`.
  static String _scaleQty(String qty, double scale) {
    if ((scale - 1).abs() < 0.04) return qty;
    final m = RegExp(r'^\s*(\d+(?:\.\d+)?)(?:/(\d+))?(.*)$').firstMatch(qty);
    if (m == null) return qty;
    var n = double.parse(m.group(1)!);
    final denom = m.group(2);
    if (denom != null) {
      n = n / double.parse(denom);
    }
    final rest = m.group(3)!;
    n *= scale;
    final isGrams = RegExp(r'^\s*g\b').hasMatch(rest) || rest.startsWith('g');
    if (isGrams) {
      final g = (n / 5).round() * 5;
      return '${g < 5 ? 5 : g}$rest';
    }
    n = ((n * 4).round() / 4).clamp(0.25, 100.0).toDouble();
    final whole = n.floor();
    final frac = n - whole;
    final fs = frac == 0.25 ? '1/4' : (frac == 0.5 ? '1/2' : '3/4');
    final text = frac == 0 ? '$whole' : (whole == 0 ? fs : '$whole $fs');
    return '$text$rest';
  }

  static MealInfo _build(
    BMICategory cat,
    _CatInfo info,
    int day,
    String slot,
    RawMeal r,
    int dayTotal,
    double scale,
  ) {
    final key = '${cat.name}_d${day}_$slot';
    final photo =
        kMealPhotoOverrides[key] ?? _mealPhotos[r.name] ?? _fallbackPhoto;
    return MealInfo(
      key: key,
      category: cat,
      day: day,
      slotKey: slot,
      name: r.name,
      blurb: r.blurb,
      kcal: _scaled(r.kcal, scale, step: 5),
      photo: photo,
      badge: _badgeFor(photo),
      tag: r.tag,
      tagIcon: info.tagIcon,
      time: _slotTimes[slot]!,
      prep: _slotPrep[slot]!,
      chips: [r.tag, ...info.chips.where((c) => c != r.tag).take(2)],
      protein: _scaled(r.p, scale),
      carbs: _scaled(r.c, scale),
      fat: _scaled(r.f, scale),
      target: (r.kcal * 100 / dayTotal).round().clamp(1, 99),
      ingredients: [
        for (final part in r.ing.split(';'))
          [part.split('|')[0], _scaleQty(part.split('|')[1], scale)],
      ],
      portion: scale,
      note: info.note,
    );
  }
}
