import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/bmi_controller.dart';
import '../../controllers/health_insight_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/weight_tracker_controller.dart';
import '../../core/routes/app_routes.dart';

class QuickActionsService {
  static const MethodChannel _channel =
      MethodChannel('com.funsoltechnologies.bmi/quick_actions');

  static final QuickActionsService instance = QuickActionsService._();
  QuickActionsService._();

  String? _pendingShortcut;

  void initialize() {
    if (!Platform.isIOS) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onShortcut') {
        final shortcutType = call.arguments as String?;
        if (shortcutType != null) {
          handleShortcut(shortcutType);
        }
      }
    });

    _checkInitialShortcut();
  }

  Future<void> _checkInitialShortcut() async {
    try {
      final initial = await _channel.invokeMethod<String>('getInitialShortcut');
      if (initial != null && initial.isNotEmpty) {
        handleShortcut(initial);
      }
    } catch (_) {}
  }

  void handleShortcut(String type) {
    // If the app is currently on the splash screen or context isn't ready yet, defer it
    if (Get.currentRoute == AppRoutes.splash || Get.key.currentState == null) {
      _pendingShortcut = type;
      return;
    }

    _ensureDependencies();
    _navigate(type);
  }

  /// Call this when the app arrives at HomeScreen to consume any cold-start shortcut
  void consumePendingAction() {
    if (_pendingShortcut != null) {
      final shortcut = _pendingShortcut!;
      _pendingShortcut = null;
      _ensureDependencies();
      _navigate(shortcut);
    }
  }

  void _navigate(String type) {
    final String targetRoute;
    switch (type) {
      case 'calculate_bmi':
        targetRoute = AppRoutes.bmiCalculator;
        break;
      case 'track_progress':
        targetRoute = AppRoutes.weightTracking;
        break;
      case 'insights':
        targetRoute = AppRoutes.healthInsights;
        break;
      default:
        return;
    }

    if (Get.currentRoute != targetRoute) {
      Get.toNamed(targetRoute);
    }
  }

  void _ensureDependencies() {
    if (!Get.isRegistered<BMIController>()) {
      Get.put(BMIController(), permanent: true);
    }
    if (!Get.isRegistered<WeightTrackerController>()) {
      Get.put(WeightTrackerController(), permanent: true);
    }
    if (!Get.isRegistered<HealthInsightController>()) {
      Get.put(HealthInsightController(), permanent: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
  }
}
