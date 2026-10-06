import 'package:get/get.dart';

/// Tracks which meals of the daily plan were marked as eaten.
class MealPlanController extends GetxController {
  static MealPlanController get to => Get.isRegistered<MealPlanController>()
      ? Get.find<MealPlanController>()
      : Get.put(MealPlanController(), permanent: true);

  final RxSet<String> eaten = <String>{}.obs;

  int get completedCount => eaten.length;

  bool isEaten(String key) => eaten.contains(key);

  void markEaten(String key) => eaten.add(key);
}
