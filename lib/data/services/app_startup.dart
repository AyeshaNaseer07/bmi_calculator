import 'dart:developer';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_contants.dart';
import '../../notifications/notification_service.dart';
import '../../views/widgets/ads/app_open_ad_manager.dart';
import '../../views/widgets/ads/applovin_sdk.dart';
import '../../views/widgets/ads/interstitial_ad_manager.dart';
import '../../views/widgets/ads/native_ad_card.dart';
import 'logger_service.dart';
import 'price_service.dart';
import 'purchase_connector.dart';
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

    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: "HpMZN7qSFkAnYvUMpVMhBP",
      appId: "6812737379",
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 30,
      manualStart: false,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
    );
    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    await appsflyerSdk?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    PurchaseManager.instance
        .initialize()
        .then((_) {
          log("PurchaseManager initialized successfully.");
        })
        .catchError((error) {
          log("Error initializing PurchaseManager: $error");
        });
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

    // Fetch both paywalls' store products now, in the background, so their
    // prices are ready by the time the user reaches a paywall.
    PriceService.preload(remoteConfigService);

    try {
      QuickActionsService.instance.initialize();
    } catch (e) {
      AppLogger.e('QuickActionsService initialization failed: $e');
    }

    _loadAds();
  }

  /// Needs Remote Config (switches + ad unit IDs) and AppController (premium).
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
    }
  }
}
