import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_contants.dart';

class AppLovinSdk {
  AppLovinSdk._();

  static const Duration _initTimeout = Duration(seconds: 10);
  static const bool _openMediationDebugger = bool.fromEnvironment(
    'APPLOVIN_DEBUGGER',
  );

  static Future<bool>? _ready;
  static Future<bool> get ready => _ready ?? Future.value(false);
  static void initialize() {
    _ready ??= () async {
      if (kDebugMode) AppLovinMAX.setVerboseLogging(true);
      try {
        if (kDebugMode) {
          AppLovinMAX.setTestDeviceAdvertisingIds([
            "C674A36D-E635-4171-A79C-83116CED0909",
          ]);
        }
        final config = await AppLovinMAX.initialize(appLovinSdkKey)
            .timeout(_initTimeout);
        debugPrint(
          '[AppLovin] initialized: ${config != null}, '
          'testMode: ${config?.isTestModeEnabled}, '
          'country: ${config?.countryCode}, '
          'ATT: ${config?.appTrackingStatus?.name}',
        );
        if (config != null && _openMediationDebugger) {
          AppLovinMAX.showMediationDebugger();
        }
        return config != null;
      } catch (e) {
        debugPrint('[AppLovin] init failed: $e');
        return false;
      }
    }();
  }
}
