import 'package:get/get.dart';

class ActivityPlanController extends GetxController {
  static ActivityPlanController get to =>
      Get.isRegistered<ActivityPlanController>()
      ? Get.find<ActivityPlanController>()
      : Get.put(ActivityPlanController(), permanent: true);

  final RxSet<String> done = <String>{}.obs;

  bool isDone(String key) => done.contains(key);

  void toggle(String key) {
    if (!done.remove(key)) done.add(key);
  }

  int doneCount(Iterable<String> keys) => keys.where(done.contains).length;
}
