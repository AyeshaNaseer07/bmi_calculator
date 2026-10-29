import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_contants.dart';

/// Starts the AppLovin MAX SDK once. Every ad waits on [ready] before
/// loading, so startup doesn't have to block on it.
class AppLovinSdk {
  AppLovinSdk._();

  static const Duration _initTimeout = Duration(seconds: 10);

  static Future<bool>? _ready;

  /// Completes with whether the SDK started; false if [initialize] was never
  /// called.
  static Future<bool> get ready => _ready ?? Future.value(false);

  static void initialize() {
    _ready ??= () async {
      try {
        // Bounded so a stuck init can't hold up the splash screen.
        final config = await AppLovinMAX.initialize(appLovinSdkKey)
            .timeout(_initTimeout);
        debugPrint('[AppLovin] initialized: ${config != null}');
        return config != null;
      } catch (e) {
        debugPrint('[AppLovin] init failed: $e');
        return false;
      }
    }();
  }
}
