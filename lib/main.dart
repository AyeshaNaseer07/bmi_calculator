import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controllers/app_controller.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'data/services/health_kit_service.dart';
import 'data/services/localization_service.dart';
import 'data/services/remote_config_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        );
      },
    );
  }
}
