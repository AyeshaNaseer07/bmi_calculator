import 'package:get/get.dart';

import '../data/services/storage_service.dart';

class ActivityPlanController extends GetxController {
  static ActivityPlanController get to =>
      Get.isRegistered<ActivityPlanController>()
      ? Get.find<ActivityPlanController>()
      : Get.put(ActivityPlanController(), permanent: true);

  final StorageService _storage = Get.find<StorageService>();

  final RxSet<String> done = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.getDoneActivities();
    if (saved.isNotEmpty) done.addAll(saved);
  }

  bool isDone(String key) => done.contains(key);

  void toggle(String key) {
    if (!done.remove(key)) done.add(key);
    _storage.saveDoneActivities(done.toSet());
  }

  int doneCount(Iterable<String> keys) => keys.where(done.contains).length;
}
