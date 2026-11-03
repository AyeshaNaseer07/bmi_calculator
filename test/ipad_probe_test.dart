import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:bmi_calculator/controllers/app_controller.dart';
import 'package:bmi_calculator/data/services/storage_service.dart';
import 'package:bmi_calculator/views/insights/nutrition_screens.dart';
import 'package:bmi_calculator/views/insights/lifestyle_screens.dart';
import 'package:bmi_calculator/views/insights/sleep_screens.dart';
import 'package:bmi_calculator/views/insights/hydration_screens.dart';
import 'package:bmi_calculator/views/insights/meal_screens.dart' as m;
import 'package:bmi_calculator/views/insights/meal_progress_screens.dart' as mp;
import 'package:bmi_calculator/views/insights/hydration_goal_screens.dart' as hg;

class _Fake extends GetxController implements AppController {
  @override
  dynamic noSuchMethod(Invocation i) => null;
  @override
  final isPremium = false.obs;
}

class _FS implements StorageService {
  @override
  dynamic noSuchMethod(Invocation i) => <String>{};
}


void main() {
  final screens = <String, Widget Function()>{
    'EatBalanced': () => const EatBalancedMealsScreen(),
    'Veg': () => const EatVegetablesScreen(),
    'Lean': () => const LeanProteinScreen(),
    'Portion': () => const PortionSizesScreen(),
    'Sleep': () => const SleepWellScreen(),
    'Active': () => const StayActiveScreen(),
    'Routine': () => const ActivityRoutineScreen(),
    'Hydrated': () => const StayHydratedScreen(),
    'Energy': () => const BoostsEnergyScreen(),
    'Digestion': () => const SupportsDigestionScreen(),
    'Plan': () => const m.DailyMealPlanScreen(),
    'Progress': () => const mp.MealProgressScreen(),
    'DailyGoal': () => const hg.DailyGoalScreen(),
    'Skin': () => const GoodForSkinScreen(),
  };
  screens.forEach((name, build) {
    testWidgets(name, (t) async {
      t.view.physicalSize = const Size(1668, 2388);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      Get.put<StorageService>(_FS());
      Get.put<AppController>(_Fake());
      addTearDown(Get.reset);
      await t.pumpWidget(ScreenUtilInit(
        designSize: const Size(375 * 0.9, 812),
        builder: (_, __) => GetMaterialApp(home: build()),
      ));
      await t.pump(const Duration(seconds: 1));
    });
  });
}
