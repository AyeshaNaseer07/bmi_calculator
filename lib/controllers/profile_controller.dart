import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/storage_service.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  final Rx<UserProfile> userProfile = const UserProfile().obs;

  /// Null means no image selected — show the default placeholder.
  final RxnString profileImagePath = RxnString();

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

  /// Opens the device gallery and, if the user picks an image, saves its path.
  Future<void> pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    profileImagePath.value = picked.path;
    await _storage.setProfileImagePath(picked.path);
  }
}
