import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/storage_service.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final Rx<UserProfile> userProfile = const UserProfile().obs;
  final RxBool isPasswordUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    userProfile.value = _storage.getUserProfile();
  }

  Future<bool> changePassword() async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all password fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    }

    if (newPass != confirm) {
      Get.snackbar(
        'Error',
        'New passwords do not match.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    }

    isPasswordUpdating.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isPasswordUpdating.value = false;

    Get.snackbar(
      'Success',
      'Password updated successfully (local demo).',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );

    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    return true;
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFF4D4F),
      onConfirm: () async {
        Get.back();
        Get.snackbar('Logged Out', 'You have been logged out.');
      },
    );
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
