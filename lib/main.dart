import 'dart:developer';
import 'dart:ui' as ui;

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bmi_calculator/core/constants/app_contants.dart';
import 'package:bmi_calculator/core/constants/device_util.dart';
import 'package:bmi_calculator/data/services/local_storage_service.dart';
import 'package:bmi_calculator/data/services/logger_service.dart';
import 'package:bmi_calculator/data/services/purchase_connector.dart';
import 'package:bmi_calculator/data/services/revenue_cat_service.dart';
import 'package:bmi_calculator/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import 'controllers/app_controller.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'data/services/health_kit_service.dart';
import 'data/services/localization_service.dart';
import 'data/services/remote_config_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final PermissionStatus status = await Permission.appTrackingTransparency
      .request();
  if (status.isGranted) {
    await showCMP();
    debugPrint('ATT Permission granted');
  }
  await initializeFirebase();
  AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
    afDevKey: "HpMZN7qSFkAnYvUMpVMhBP",
    appId: "6779616188",
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
  await RevenueCat.configStore();
  final storage = await LocalStorageService.init();
  Get.put(storage, permanent: true);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);
    await FirebaseRemoteConfig.instance.ensureInitialized();
  } catch (e) {
    AppLogger.e('Firebase initialization failed: $e');
  }
  await MobileAds.instance.initialize();
  try {
    await RevenueCat.configStore();
  } catch (e) {
    AppLogger.e('RevenueCat initialization failed: $e');
  }

  // Pass Flutter framework errors to Crashlytics
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
  await DeviceUtils.init();
  // Initialize Storage Service (SharedPreferences)
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);

  // Initialize Remote Config Service
  final remoteConfigService = await RemoteConfigService(storageService).init();
  Get.put<RemoteConfigService>(remoteConfigService, permanent: true);

  // Initialize HealthKit Service (graceful optional fallback)
  final healthKitService = HealthKitService();
  Get.put<HealthKitService>(healthKitService, permanent: true);

  // Initialize Global App Controller
  final appController = Get.put<AppController>(
    AppController(),
    permanent: true,
  );

  // Initialize Localization Service from JSON assets
  await LocalizationService.init();

  // Determine initial locale
  final currentLocale = LocalizationService.getLocaleFromLanguage(
    appController.selectedLanguage.value,
  );

  runApp(BMIApp(initialLocale: currentLocale));
}

Future<void> initializeFirebase() async {
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

String getDeviceCountry() {
  try {
    final locale = ui.PlatformDispatcher.instance.locale;
    return locale.countryCode ?? "";
  } catch (e) {
    return "";
  }
}

Future<void> logAdRevenue({
  required String adNetwork,
  required dynamic revenue, // can be double, int, or String from macros
  required String currency,
  required String adFormat, // e.g. native, rewarded, interstitial
  required String adUnitId,
  required String mediationNetwork,
  required String adType,
}) async {
  double parsedRevenue = 0.0;
  try {
    debugPrint(
      "📢 logAdRevenue called with: adNetwork=$adNetwork, revenue=$revenue, currency=$currency, adFormat=$adFormat, adUnitId=$adUnitId, mediationNetwork=$mediationNetwork, adType=$adType",
    );

    if (revenue is num) {
      parsedRevenue = revenue.toDouble();
    } else if (revenue is String) {
      parsedRevenue = double.tryParse(revenue.trim()) ?? 0.0;
    }

    // Convert micros to standard currency and format to 5 decimals
    parsedRevenue = double.parse(
      (parsedRevenue / 1000000.0).toStringAsFixed(5),
    );

    // Log to AppsFlyer
    appsflyerSdk?.logAdRevenue(
      AdRevenueData(
        monetizationNetwork: adNetwork,
        mediationNetwork: AFMediationNetwork.googleAdMob.value,
        currencyIso4217Code: currency,
        revenue: parsedRevenue,
        additionalParameters: {
          "country": getDeviceCountry(),
          "adUnit": adUnitId,
          "adType": adType,
        },
      ),
    );

    debugPrint("✅ logAdRevenue successful. Parsed revenue: $parsedRevenue");
  } catch (e, stackTrace) {
    debugPrint("❌ logAdRevenue failed: $e");
    debugPrint("📌 Stack trace: $stackTrace");
  }
}

class BMIApp extends StatelessWidget {
  final Locale initialLocale;

  const BMIApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'BMI Calculator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          translations: LocalizationService(),
          locale: initialLocale,
          fallbackLocale: LocalizationService.fallbackLocale,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          navigatorObservers: [appRouteObserver],
          defaultTransition: Transition.cupertino,
          builder: (context, child) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );
          },
        );
      },
    );
  }
}
