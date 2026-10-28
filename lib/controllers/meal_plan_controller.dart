import 'package:get/get.dart';

import '../data/models/user_profile_model.dart' show ActivityLevel;
import '../data/models/bmi_record_model.dart';
import '../data/services/calorie_service.dart';

class MealPlanController extends GetxController {
  static MealPlanController get to => Get.isRegistered<MealPlanController>()
      ? Get.find<MealPlanController>()
      : Get.put(MealPlanController(), permanent: true);

  final RxSet<String> eaten = <String>{}.obs;

  BMICategory category = BMICategory.normal;

  int targetKcal = 0;
  String goal = '';
  bool needsCare = false;
  ActivityLevel activity = ActivityLevel.lightlyActive;
  int age = 25;
  double weightKg = 70;

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

  int eatenOnDay(int day) =>
      eaten.where((k) => k.startsWith('${category.name}_d${day}_')).length;

  int get eatenInPlan =>
      eaten.where((k) => k.startsWith('${category.name}_d')).length;

  int get daysCompleted =>
      [for (int d = 1; d <= 7; d++) eatenOnDay(d)].where((n) => n == 3).length;
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

  int get currentDay {
    for (int d = 1; d <= 7; d++) {
      if (eatenOnDay(d) < 3) return d;
    }
    return 7;
  }
}
