import 'package:get/get.dart';

import '../data/models/user_profile_model.dart';
import '../data/services/localization_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/subscription_service.dart';

class AppController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  late final SubscriptionService subscriptionService;

  final RxString selectedLanguage = 'en'.obs;
  final Rx<UnitSystem> unitSystem = UnitSystem.metric.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isPremium = false.obs;
  final RxBool onboardingSeen = false.obs;

  @override
  void onInit() {
    super.onInit();
    subscriptionService = SubscriptionService(_storage);
    selectedLanguage.value = _storage.getLanguage();
    unitSystem.value = _storage.getUnitSystem();
    notificationsEnabled.value = _storage.getNotificationsEnabled();
    isPremium.value = _storage.getIsPremium();
    onboardingSeen.value = _storage.getOnboardingSeen();
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

  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
    _storage.setNotificationsEnabled(enabled);
  }

  Future<bool> upgradeToPremium(SubscriptionPlan plan) async {
    final success = await subscriptionService.purchase(plan);
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
