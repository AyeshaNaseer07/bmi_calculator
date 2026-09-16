import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/user_profile_model.dart';
import '../data/services/storage_service.dart';

import 'profile_controller.dart';

class HealthInsightController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  final Rx<Gender?> selectedGender = Rx<Gender?>(null);
  final Rx<ActivityLevel?> selectedActivity = Rx<ActivityLevel?>(null);
  final Rx<HealthGoal?> selectedGoal = Rx<HealthGoal?>(null);

  final RxBool hasInsights = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    final profile = _storage.getUserProfile();
    final name = profile.displayName;
    if (name.isNotEmpty || profile.heightCm != 175.0) {
      fullNameController.text = name;
      ageController.text = profile.age.toString();
      heightController.text = profile.heightCm.toStringAsFixed(0);
      weightController.text = profile.weightKg.toStringAsFixed(1);
      selectedGender.value = profile.gender;
      selectedActivity.value = profile.activityLevel;
      selectedGoal.value = profile.healthGoal;
      hasInsights.value = true;
    }
  }

  void setGender(Gender gender) {
    selectedGender.value = gender;
  }

  void setActivity(ActivityLevel level) {
    selectedActivity.value = level;
  }

  void setGoal(HealthGoal goal) {
    selectedGoal.value = goal;
  }

  Future<void> saveProfileAndInsights() async {
    final profile = UserProfile(
      name: fullNameController.text.trim(),
      age: int.tryParse(ageController.text.trim()) ?? 25,
      gender: selectedGender.value ?? Gender.male,
      heightCm: double.tryParse(heightController.text.trim()) ?? 175.0,
      weightKg: double.tryParse(weightController.text.trim()) ?? 70.0,
      activityLevel: selectedActivity.value ?? ActivityLevel.sedentary,
      healthGoal: selectedGoal.value ?? HealthGoal.loseWeight,
    );

    await _storage.saveUserProfile(profile);
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }
    hasInsights.value = true;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }
}
