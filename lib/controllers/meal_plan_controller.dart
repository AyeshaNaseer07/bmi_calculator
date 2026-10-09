import 'package:get/get.dart';

import '../data/models/user_profile_model.dart' show ActivityLevel;
import '../data/models/bmi_record_model.dart';
import '../data/services/calorie_service.dart';

/// Tracks the weekly meal plan: which meals were eaten and which day/category
/// is being viewed.
///
/// Meal keys look like `<category>_d<day>_<slot>`.
class MealPlanController extends GetxController {
  static MealPlanController get to => Get.isRegistered<MealPlanController>()
      ? Get.find<MealPlanController>()
      : Get.put(MealPlanController(), permanent: true);

  final RxSet<String> eaten = <String>{}.obs;

  /// Category whose weekly plan is shown (set from the BMI insight screen).
  BMICategory category = BMICategory.normal;

  /// Day (1–7) currently selected on the meal plan screen.
  /// Personal daily calorie target (0 = unknown, plan shown at base size).
  int targetKcal = 0;
  String goal = '';
  bool needsCare = false;
  ActivityLevel activity = ActivityLevel.lightlyActive;
  int age = 25;
  double weightKg = 70;

  /// Points the plan at a BMI record: its category and personal calorie target.
  void useRecord(BMIRecord r) {
    category = r.category;
    activity = r.activity;
    age = r.age;
    weightKg = r.weightKg;
    final t = CalorieService.forRecord(r);
    targetKcal = t.kcal;
    goal = t.goal;
    needsCare = t.needsCare;
  }

  final RxInt selectedDay = 1.obs;

  bool isEaten(String key) => eaten.contains(key);

  void markEaten(String key) => eaten.add(key);

  /// Meals eaten on [day] of the current category's plan (0–3).
  int eatenOnDay(int day) =>
      eaten.where((k) => k.startsWith('${category.name}_d${day}_')).length;

  /// Meals eaten in the current category's whole week (0–21).
  int get eatenInPlan =>
      eaten.where((k) => k.startsWith('${category.name}_d')).length;

  /// Days on which all three meals were eaten.
  int get daysCompleted =>
      [for (int d = 1; d <= 7; d++) eatenOnDay(d)].where((n) => n == 3).length;

  /// Consecutive fully-completed days counting back from the first day.
  int get streak {
    int s = 0;
    for (int d = 1; d <= 7; d++) {
      if (eatenOnDay(d) == 3) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  /// First day that still has an uneaten meal (1–7).
  int get currentDay {
    for (int d = 1; d <= 7; d++) {
      if (eatenOnDay(d) < 3) return d;
    }
    return 7;
  }
}
