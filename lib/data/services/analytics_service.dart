import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

class AnalyticsService {
  AnalyticsService._();

  // Event names.
  static const onboardingComplete = 'onboarding_complete';
  static const paywallView = 'paywall_view';
  static const paywallClose = 'paywall_close';
  static const purchaseStart = 'purchase_start';
  static const bmiCalculated = 'bmi_calculated';
  static const weightLogged = 'weight_logged';
  static const insightsGenerated = 'insights_generated';
  static const languageChanged = 'language_changed';
  static const profilePhotoUpdated = 'profile_photo_updated';
  static const recordsDeleted = 'history_records_deleted';

  static Future<void> log(String name, [Map<String, Object?>? params]) async {
    try {
      final clean = <String, Object>{
        for (final e in (params ?? const <String, Object?>{}).entries)
          if (e.value != null) e.key: e.value!,
      };
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: clean.isEmpty ? null : clean,
      );
    } catch (e) {
      debugPrint('Analytics "$name" skipped: $e');
    }
  }

  static Future<void> setUserProperty(String name, String? value) async {
    try {
      await FirebaseAnalytics.instance.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      debugPrint('Analytics property "$name" skipped: $e');
    }
  }

  static Future<void> logScreen(String? name) async {
    if (name == null || name.isEmpty) return;
    try {
      await FirebaseAnalytics.instance.logScreenView(screenName: name);
    } catch (e) {
      debugPrint('Analytics screen "$name" skipped: $e');
    }
  }
}

/// Logs a `screen_view` for every named GetX route push / pop-back.
class AnalyticsRouteObserver extends NavigatorObserver {
  String? _name(Route<dynamic>? r) {
    final n = r?.settings.name;
    // Skip dialogs, sheets and unnamed routes.
    if (r is! PageRoute || n == null || n.isEmpty) return null;
    return n.startsWith('/') && n.length > 1 ? n.substring(1) : n;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AnalyticsService.logScreen(_name(route));

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      AnalyticsService.logScreen(_name(newRoute));

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      AnalyticsService.logScreen(_name(previousRoute));
}
