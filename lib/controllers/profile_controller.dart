import 'package:get/get.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/storage_service.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final Rx<UserProfile> userProfile = const UserProfile().obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    userProfile.value = _storage.getUserProfile();
  }

  Future<void> updateName(String newName) async {
    final current = userProfile.value;
    final updated = current.copyWith(name: newName.trim());
    userProfile.value = updated;
    await _storage.saveUserProfile(updated);
  }

  Future<void> updateProfile(UserProfile updated) async {
    userProfile.value = updated;
    await _storage.saveUserProfile(updated);
  }
}
