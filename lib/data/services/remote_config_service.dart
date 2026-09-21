import 'dart:convert';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

import '../models/remote_model.dart';
import 'storage_service.dart';
import 'subscription_service.dart';

class RemoteConfigService extends GetxService {
  final StorageService? _storage;

  static const String keyRemoteConfig = 'bmi_calculator_remote_config';
  final Rx<RemoteModel> model = RemoteModel.defaults().obs;

  RemoteConfigService([this._storage]);

  static RemoteConfigService get to => Get.find<RemoteConfigService>();

  RemoteModel get current => model.value;
  String get firstTimeOnboarding => model.value.firstTimeOnboarding;
  bool get isFirstTimeOnboardingEnabled => model.value.isFirstTimeOnboarding;
  String get secondTimeOnboarding => model.value.secondTimeOnboarding;
  bool get isSecondTimeOnboardingEnabled => model.value.isSecondTimeOnboarding;
  String get paywallBtnText => model.value.paywallBtnText;
  String get buttonText => model.value.paywallBtnText;
  int get crossDelaySeconds => model.value.crossDelay;
  String get monthlyProductId => model.value.monthlyProductId;
  String get yearlyProductId => model.value.yearlyProductId;
  String get nativeAdId => model.value.nativeAdId;
  String get ads => model.value.ads;
  bool get isAdsEnabled => model.value.isAdsEnabled;
  String get localNotification => model.value.localNotification;
  bool get isLocalNotificationEnabled => model.value.isLocalNotificationEnabled;

  Future<RemoteConfigService> init() async {
    loadCachedConfig();
    await fetchRemoteConfig();
    return this;
  }

  void loadCachedConfig() {
    if (_storage == null) return;
    try {
      final cachedJson = _storage.getRemoteButtonText();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final parsed = RemoteModel.fromRemoteConfig(decoded);
          model.value = parsed;
          remoteModel = parsed;
        } catch (_) {}
      }
    } catch (e) {
      log('Error loading cached remote config: $e');
    }
  }

  Future<void> fetchRemoteConfig({int attempts = 2}) async {
    log('Fetching RemoteConfig values...');
    for (int i = 0; i < attempts; i++) {
      try {
        final map = RemoteConfig.getAllValuesAsMap();
        if (map.isNotEmpty) {
          updateWithMap(map);
        }
        log(
          'RemoteConfig fetched successfully: firstTimeOnboarding=${model.value.firstTimeOnboarding}, secondTimeOnboarding=${model.value.secondTimeOnboarding}, paywallBtnText="${model.value.paywallBtnText}", crossDelay=${model.value.crossDelay}, monthlyId="${model.value.monthlyProductId}", yearlyId="${model.value.yearlyProductId}", ads=${model.value.ads}, localNotification=${model.value.localNotification}',
        );
        return;
      } catch (e) {
        log('fetch attempt ${i + 1} failed: $e');
        if (i < attempts - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    log('Remote config fetch failed; ensuring default values are active');
    if (model.value.monthlyProductId.isEmpty) {
      final defaults = RemoteModel.defaults();
      model.value = defaults;
      remoteModel = defaults;
    }
  }

  void updateWithMap(Map<String, dynamic> remoteConfigMap) {
    final parsed = RemoteModel.fromRemoteConfig(remoteConfigMap);
    model.value = parsed;
    remoteModel = parsed;
    _storage?.setRemoteButtonText(jsonEncode(parsed.toJson()));
  }

  void updateModel(RemoteModel newModel) {
    model.value = newModel;
    remoteModel = newModel;
    _storage?.setRemoteButtonText(jsonEncode(newModel.toJson()));
  }

  String getProductId(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.monthly:
        return model.value.monthlyProductId;
      case SubscriptionPlan.yearly:
        return model.value.yearlyProductId;
    }
  }
}

class RemoteConfig {
  static final FirebaseRemoteConfig remoteConfig =
      FirebaseRemoteConfig.instance;

  static const String _key = RemoteConfigService.keyRemoteConfig;

  static Future<String> initialize() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: Duration.zero,
        ),
      );
      final activated = await remoteConfig.fetchAndActivate();
      log(
        activated
            ? 'RemoteConfig fetched & activated fresh values'
            : 'RemoteConfig fetch succeeded, using activated values',
      );
      final configMap = getAllValuesAsMap();
      if (configMap.isNotEmpty && Get.isRegistered<RemoteConfigService>()) {
        RemoteConfigService.to.updateWithMap(configMap);
      }
      return 'success';
    } catch (e) {
      log('RemoteConfig.initialize failed: $e');
      return 'failed: $e';
    }
  }

  static Map<String, dynamic> getAllValuesAsMap() {
    final Map<String, dynamic> result = {};

    final val = remoteConfig.getString(_key).trim();
    if (val.isNotEmpty && val != "{}" && val != "off") {
      try {
        final decoded = json.decode(val);
        if (decoded is Map<String, dynamic>) {
          result.addAll(decoded);
        }
      } catch (e) {
        log('RemoteConfig: failed to decode bundle JSON string: $e');
      }
    }

    final allParams = remoteConfig.getAll();
    for (final entry in allParams.entries) {
      if (entry.key == _key) continue;
      final rawStr = entry.value.asString().trim();
      if (rawStr.isNotEmpty) {
        if (rawStr.startsWith('{') && rawStr.endsWith('}')) {
          try {
            final parsed = json.decode(rawStr);
            if (parsed is Map && parsed.containsKey('value')) {
              result[entry.key] = parsed['value'];
              continue;
            }
          } catch (_) {}
        }
        result[entry.key] = rawStr;
      }
    }

    return result;
  }

  static String getString(String key) => remoteConfig.getString(key);
  static int getInt(String key) => remoteConfig.getInt(key);
  static bool getBool(String key) => remoteConfig.getBool(key);
  static double getDouble(String key) => remoteConfig.getDouble(key);
}
