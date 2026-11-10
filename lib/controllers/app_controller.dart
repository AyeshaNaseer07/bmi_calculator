import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';

import '../data/models/user_profile_model.dart';
import '../data/services/localization_service.dart';
import '../data/services/remote_config_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/subscription_service.dart';
import '../data/services/analytics_service.dart';

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
  final RxBool isPremium = false.obs;
  final RxBool onboardingSeen = false.obs;

  late final Future<void> subscriptionVerified;
  AppLifecycleListener? _lifecycle;

  @override
  void onInit() {
    super.onInit();
    subscriptionService = SubscriptionService(_storage);
    selectedLanguage.value = _storage.getLanguage();
    unitSystem.value = _storage.getUnitSystem();
    final isRemoteNotificationEnabled =
        remoteConfigService.isLocalNotificationEnabled;
    notificationsEnabled.value =
        isRemoteNotificationEnabled && _storage.getNotificationsEnabled();
    isPremium.value = _storage.getIsPremium();
    onboardingSeen.value = _storage.getOnboardingSeen();

    subscriptionService.onChanged = (premium) => isPremium.value = premium;
    subscriptionService.start();
    // Only turns premium off for expired/refunded subs: at launch and
    // whenever the app comes back to the foreground.
    subscriptionVerified = subscriptionService.checkExpiry();
    _lifecycle = AppLifecycleListener(
      onResume: () => subscriptionService.checkExpiry(),
    );

    if (isRemoteNotificationEnabled) {
      _checkLocalNotificationPermission();
    }
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    subscriptionService.dispose();
    super.onClose();
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
    AnalyticsService.log(AnalyticsService.languageChanged, {'language': code});
    _storage.setLanguage(code);
    LocalizationService.applyIntlLocale(code);
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

  Future<PremiumPurchaseResult> upgradeToPremium(
    SubscriptionPlan plan,
    PaywallType paywall,
  ) async {
    final remoteProductId = remoteConfigService.getProductId(plan, paywall);
    final params = {
      'plan': plan.name,
      'type': paywall.name,
      'product': remoteProductId,
    };
    AnalyticsService.log(AnalyticsService.purchaseStart, params);
    return subscriptionService.purchase(remoteProductId);
  }

  Future<PremiumRestoreResult> restorePurchases() => subscriptionService.restore();

  void completeOnboarding() {
    onboardingSeen.value = true;
    AnalyticsService.log(AnalyticsService.onboardingComplete);
    _storage.setOnboardingSeen(true);
  }
}
