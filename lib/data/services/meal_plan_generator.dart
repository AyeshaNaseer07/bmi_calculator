import '../models/ai_meal_plan_model.dart';

/// The meals of one plan day, from the "Meals per day" answer.
abstract class MealSlots {
  static const List<String> standard = ['breakfast', 'lunch', 'dinner'];
  static List<String> of(String mealsPerDay, {String mealTiming = ''}) =>
      switch (mealsPerDay) {
        '2' when mealTiming == 'late' => const ['lunch', 'dinner'],
        '2' => const ['breakfast', 'dinner'],
        '4' => const ['breakfast', 'lunch', 'snack', 'dinner'],
        '5_plus' => const [
          'breakfast',
          'morning_snack',
          'lunch',
          'afternoon_snack',
          'dinner',
        ],
        _ => standard,
      };

  static bool isSnack(String slot) => slot.endsWith('snack');
}

/// Everything a generator needs to write one week of a long meal plan.
class MealPlanRequest {
  /// Week being generated (1-based) and the plan's total length.
  final int week;
  final int totalWeeks;

  final int targetKcal;
  final String bmiCategory;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String activity;
  final String healthGoal;
  final List<String> conditions;
  final List<String> allergies;
  final String dietType;
  final String cuisine;
  final List<String> dislikes;
  final String cooking;
  final String budget;
  final String sleep;
  final String water;
  final String mealTiming;
  final String notes;

  /// "Meals per day" answer: `2`, `3`, `4`, `5_plus` or `none`.
  final String mealsPerDay;

  /// English name of the language the meals should be written in.
  final String language;

  /// Dishes already used in earlier weeks.
  final List<String> avoidNames;

  /// Bundled photo names the generator may pick from.
  final List<String> photoKeys;

  const MealPlanRequest({
    required this.week,
    required this.totalWeeks,
    required this.targetKcal,
    required this.bmiCategory,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.healthGoal,
    required this.conditions,
    required this.allergies,
    required this.dietType,
    required this.cuisine,
    required this.dislikes,
    required this.cooking,
    required this.budget,
    required this.sleep,
    required this.water,
    required this.mealTiming,
    required this.notes,
    this.mealsPerDay = '',
    required this.language,
    required this.avoidNames,
    required this.photoKeys,
  });

  MealPlanRequest copyWith({
    int? week,
    int? totalWeeks,
    List<String>? avoidNames,
    String? language,
  }) => MealPlanRequest(
    week: week ?? this.week,
    totalWeeks: totalWeeks ?? this.totalWeeks,
    targetKcal: targetKcal,
    bmiCategory: bmiCategory,
    age: age,
    gender: gender,
    heightCm: heightCm,
    weightKg: weightKg,
    activity: activity,
    healthGoal: healthGoal,
    conditions: conditions,
    allergies: allergies,
    dietType: dietType,
    cuisine: cuisine,
    dislikes: dislikes,
    cooking: cooking,
    budget: budget,
    sleep: sleep,
    water: water,
    mealTiming: mealTiming,
    notes: notes,
    mealsPerDay: mealsPerDay,
    language: language ?? this.language,
    avoidNames: avoidNames ?? this.avoidNames,
    photoKeys: photoKeys,
  );

  /// Meal slots of every day in this plan.
  List<String> get slots => MealSlots.of(mealsPerDay, mealTiming: mealTiming);

  String get signature => [
    targetKcal,
    bmiCategory,
    age,
    gender,
    heightCm.toStringAsFixed(1),
    weightKg.toStringAsFixed(1),
    activity,
    healthGoal,
    (List.of(conditions)..sort()).join(','),
    (List.of(allergies)..sort()).join(','),
    dietType,
    cuisine,
    (List.of(dislikes)..sort()).join(','),
    cooking,
    budget,
    sleep,
    water,
    mealTiming,
    notes.trim(),
    if (slots.length != 3) 'meals=${slots.join(',')}',
  ].join('|');
}

class MealPlanException implements Exception {
  final String message;

  /// False for errors a retry can't fix (bad key, unknown model).
  final bool retryable;

  /// HTTP status from the API, when there was one.
  final int? statusCode;
  const MealPlanException(
    this.message, {
    this.retryable = true,
    this.statusCode,
  });

  @override
  String toString() => 'MealPlanException: $message';
}

/// Source of generated meal weeks. Gemini today; the backend API later.
abstract class MealPlanGenerator {
  /// Returns exactly 7 days, each with one meal per [MealPlanRequest.slots].
  Future<List<List<AiMeal>>> generateWeek(MealPlanRequest request);
}
