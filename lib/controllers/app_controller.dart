import 'package:flutter/material.dart' show ThemeMode;
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/theme/app_palette.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/localization_service.dart';
import '../data/services/remote_config_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/subscription_service.dart';

class AppController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  StorageService get storage => _storage;
  late final SubscriptionService subscriptionService;

  RemoteConfigService get remoteConfigService {
    if (Get.isRegistered<RemoteConfigService>()) {
      return Get.find<RemoteConfigService>();
    }
    final service = RemoteConfigService(_storage);
    Get.put<RemoteConfigService>(service, permanent: true);
    return service;
  }

  final RxString selectedLanguage = 'en'.obs;
  final Rx<UnitSystem> unitSystem = UnitSystem.metric.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isPremium = false.obs;
  final RxBool onboardingSeen = false.obs;

  late final Future<void> subscriptionVerified;

  @override
  void onInit() {
    super.onInit();
    subscriptionService = SubscriptionService(_storage);
    selectedLanguage.value = _storage.getLanguage();
    unitSystem.value = _storage.getUnitSystem();
    isDarkMode.value = _storage.getDarkMode();
    AppPalette.isDark = isDarkMode.value;
    final isRemoteNotificationEnabled =
        remoteConfigService.isLocalNotificationEnabled;
    notificationsEnabled.value =
        isRemoteNotificationEnabled && _storage.getNotificationsEnabled();
    isPremium.value = _storage.getIsPremium();
    onboardingSeen.value = _storage.getOnboardingSeen();

    subscriptionVerified = _verifySubscription();
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

    if (isRemoteNotificationEnabled) {
      _checkLocalNotificationPermission();
    }
  }

  @override
  void onClose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.onClose();
  }

  Future<void> _verifySubscription() async {
    final active = await subscriptionService.verifyWithStore();
    if (active != null) isPremium.value = active;
  }

  Future<void> _onCustomerInfoUpdated(CustomerInfo info) async {
    isPremium.value = await subscriptionService.applyCustomerInfo(info);
  }

  Future<void> _checkLocalNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    } catch (_) {}
  }

  void changeLanguage(String code) {
    selectedLanguage.value = code;
    _storage.setLanguage(code);
    final locale = LocalizationService.getLocaleFromLanguage(code);
    Get.updateLocale(locale);
  }

  void setUnitSystem(UnitSystem system) {
    unitSystem.value = system;
    _storage.setUnitSystem(system);
  }

  void setDarkMode(bool enabled) {
    isDarkMode.value = enabled;
    AppPalette.isDark = enabled;
    _storage.setDarkMode(enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
    // Screens read AppPalette directly, so rebuild everything.
    Get.forceAppUpdate();
  }

  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
    _storage.setNotificationsEnabled(enabled);
  }

  Future<bool> upgradeToPremium(SubscriptionPlan plan) async {
    final remoteProductId = remoteConfigService.getProductId(plan);
    final success = await subscriptionService.purchase(
      plan,
      productId: remoteProductId,
    );
    if (success) {
      isPremium.value = true;
    }
    return success;
  }

  void completeOnboarding() {
    onboardingSeen.value = true;
    _storage.setOnboardingSeen(true);
  }
}
