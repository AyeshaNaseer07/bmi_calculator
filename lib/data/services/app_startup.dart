import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../notifications/notification_service.dart';
import '../../views/widgets/ads/app_open_ad_manager.dart';
import '../../views/widgets/ads/applovin_sdk.dart';
import '../../views/widgets/ads/interstitial_ad_manager.dart';
import '../../views/widgets/ads/native_ad_card.dart';
import 'analytics_service.dart';
import 'logger_service.dart';
import 'price_service.dart';
import 'quick_actions_service.dart';
import 'remote_config_service.dart';
import 'storage_service.dart';

class AppStartup {
  AppStartup._();

  static Future<void>? _run;
  static Future<void> run() => _run ??= _start();
  static Future<void> _start() async {
    AppLovinSdk.initialize();

    await _initializeFirebase();

    try {
      await NotificationService.instance.initialize();
    } catch (e) {
      AppLogger.e('NotificationService initialization failed: $e');
    }

    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      AppLogger.e(
        'FlutterError: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    };

    // Pass uncaught async errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    final storageService = Get.find<StorageService>();
    final remoteConfigService = await RemoteConfigService(storageService)
        .init();
    Get.put<RemoteConfigService>(remoteConfigService, permanent: true);

    Get.put<AppController>(AppController(), permanent: true);

    PriceService.preload(remoteConfigService);

    try {
      QuickActionsService.instance.initialize();
    } catch (e) {
      AppLogger.e('QuickActionsService initialization failed: $e');
    }

    _loadAds();
  }

  static void _loadAds() {
    // The language screen comes straight after the splash.
    NativeAds.preload(NativeAdPlacement.language);
    InterstitialAdManager.instance.initialize();
    for (final placement in InterstitialPlacement.values) {
      InterstitialAdManager.instance.load(placement);
    }
    AppOpenAdManager.instance.start();
  }

  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      log("Firebase initialized");

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      // Release analytics events queued since launch (e.g. the splash view).
      AnalyticsService.markFirebaseReady();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      await RemoteConfig.initialize()
          .then((value) {
            log("RemoteConfig initialized: $value");
          })
          .catchError((e) {
            log("Error initializing Firebase Remote Config: $e");
          });
      log("Firebase initialization complete");
    } catch (e) {
      log("Error initializing Firebase: $e");
    } finally {
      // Also on failure, so queued calls run (and are skipped) instead of waiting.
      AnalyticsService.markFirebaseReady();
    }
  }
}
