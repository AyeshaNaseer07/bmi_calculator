import 'dart:convert';
import 'dart:developer';

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
  int get crossDelaySeconds => model.value.splashProductCrossDelay;
  String get monthlyProductId => model.value.splashProductId;
  String get yearlyProductId => model.value.splashYearlyProductId;
  String get monthlyPrice => model.value.monthlyPrice;
  String get yearlyPrice => model.value.yearlyPrice;
  String get buttonText => model.value.splashProductBtnText;
  String get trialSubtitle => model.value.trialSubtitle;

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
        await Future.delayed(const Duration(milliseconds: 100));
        log(
          'RemoteConfig fetched successfully: crossDelay=${model.value.splashProductCrossDelay}, buttonText="${model.value.splashProductBtnText}", monthlyId="${model.value.splashProductId}", yearlyId="${model.value.splashYearlyProductId}"',
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
    if (model.value.splashProductId.isEmpty) {
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
        return model.value.splashProductId;
      case SubscriptionPlan.yearly:
        return model.value.splashYearlyProductId;
    }
  }

  String getPlanPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.monthly:
        return model.value.monthlyPrice;
      case SubscriptionPlan.yearly:
        return model.value.yearlyPrice;
    }
  }
}
