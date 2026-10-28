import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/photo_permission.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/storage_service.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();
  final Rx<UserProfile> userProfile = const UserProfile().obs;
  final RxnString profileImagePath = RxnString();
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    userProfile.value = _storage.getUserProfile();
    profileImagePath.value = _storage.getProfileImagePath();
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

  Future<void> pickProfileImage() async {
    if (isUploading.value) return;
    if (!await PhotoPermission.request()) return;
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    isUploading.value = true;
    try {
      await Future.wait([
        _storage.setProfileImagePath(picked.path),
        Future.delayed(const Duration(milliseconds: 900)),
      ]);
      profileImagePath.value = picked.path;
    } finally {
      isUploading.value = false;
    }
  }
}
