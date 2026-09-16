import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:bmi_calculator/data/models/user_profile_model.dart';
import 'package:bmi_calculator/data/services/storage_service.dart';
import 'package:bmi_calculator/controllers/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfile Model & ProfileController Tests', () {
    test('Default UserProfile has empty name and displayName is empty', () {
      const profile = UserProfile();
      expect(profile.name, isEmpty);
      expect(profile.displayName, isEmpty);
    });

    test('Legacy Alex name is treated as empty displayName', () {
      final json = {'name': 'Alex', 'age': 25};
      final profile = UserProfile.fromJson(json);
      expect(profile.name, isEmpty);
      expect(profile.displayName, isEmpty);
    });

    test('Custom user name is preserved and displayed correctly', () {
      final json = {'name': 'Sarah Connor', 'age': 28};
      final profile = UserProfile.fromJson(json);
      expect(profile.name, equals('Sarah Connor'));
      expect(profile.displayName, equals('Sarah Connor'));
    });

    test('ProfileController updateName updates profile and storage', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService().init();
      Get.put<StorageService>(storage, permanent: true);

      final profileController = ProfileController();
      expect(profileController.userProfile.value.displayName, isEmpty);

      await profileController.updateName('Ayesha');
      expect(profileController.userProfile.value.displayName, equals('Ayesha'));

      // Verify persisted in storage
      final loaded = storage.getUserProfile();
      expect(loaded.displayName, equals('Ayesha'));

      Get.delete<ProfileController>();
      Get.delete<StorageService>();
    });
  });
}
