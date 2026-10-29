import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:applovin_max/applovin_max.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bmi_calculator/core/constants/app_contants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/routes/app_pages.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'data/services/localization_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ATT first, then the CMP consent form whatever the user chose. Both are
  // answered over the launch screen, before the splash screen shows.
  await _waitUntilAppActive();
  final PermissionStatus status = await Permission.appTrackingTransparency
      .request();
  debugPrint('ATT status: $status');
  await showCMP();

  // Only what the first frame needs. Firebase, the SDKs and the ads are
  // started from the splash screen (see AppStartup).
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);
  AppPalette.isDark = storageService.getDarkMode();

  await LocalizationService.init();
  final currentLocale = LocalizationService.getLocaleFromLanguage(
    storageService.getLanguage(),
  );

  runApp(BMIApp(initialLocale: currentLocale));
}

/// iOS only shows the ATT prompt while the app is active; asked any earlier
/// it returns "not determined" without showing anything.
Future<void> _waitUntilAppActive() async {
  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    return;
  }
  final active = Completer<void>();
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      if (state == AppLifecycleState.resumed && !active.isCompleted) {
        active.complete();
      }
    },
  );
  await active.future.timeout(const Duration(seconds: 3), onTimeout: () {});
  listener.dispose();
}

String getDeviceCountry() {
  try {
    final locale = ui.PlatformDispatcher.instance.locale;
    return locale.countryCode ?? "";
  } catch (e) {
    return "";
  }
}

/// Sends an AppLovin MAX impression's revenue (in USD) to AppsFlyer.
void logMaxAdRevenue(MaxAd ad, {required String adType}) {
  try {
    appsflyerSdk?.logAdRevenue(
      AdRevenueData(
        monetizationNetwork: ad.networkName,
        mediationNetwork: AFMediationNetwork.applovinMax.value,
        currencyIso4217Code: 'USD',
        revenue: ad.revenue,
        additionalParameters: {
          "country": getDeviceCountry(),
          "adUnit": ad.adUnitId,
          "adType": adType,
        },
      ),
    );
    debugPrint("✅ logMaxAdRevenue: $adType ${ad.revenue} USD");
  } catch (e, stackTrace) {
    debugPrint("❌ logMaxAdRevenue failed: $e");
    debugPrint("📌 Stack trace: $stackTrace");
  }
}

const Size _phoneDesignSize = Size(375, 812);

const double _tabletMaxContentWidth = 640;

bool _isTabletScreen(Size screen) =>
    !screen.isEmpty && screen.shortestSide >= 600;

double _contentWidthFor(Size screen) => _isTabletScreen(screen)
    ? math.min(screen.shortestSide, _tabletMaxContentWidth)
    : screen.width;

double _tabletScaleFor(Size screen) =>
    (screen.shortestSide / 375 * 0.62).clamp(1.15, 1.4).toDouble();
Size _designSizeFor(Size screen) {
  if (!_isTabletScreen(screen)) return _phoneDesignSize;
  final double scale = _tabletScaleFor(screen);
  return Size(screen.width / scale, screen.height / scale);
}

class BMIApp extends StatelessWidget {
  final Locale initialLocale;

  const BMIApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _designSizeFor(MediaQuery.sizeOf(context)),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'BMI Calculator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppPalette.isDark ? ThemeMode.dark : ThemeMode.light,
          translations: LocalizationService(),
          locale: initialLocale,
          fallbackLocale: LocalizationService.fallbackLocale,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          navigatorObservers: [appRouteObserver],
          defaultTransition: Transition.cupertino,
          builder: (context, child) {
            Widget content = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );

            final mq = MediaQuery.of(context);
            if (_isTabletScreen(mq.size)) {
              final double contentWidth = _contentWidthFor(mq.size);
              content = MediaQuery(
                data: mq.copyWith(size: Size(contentWidth, mq.size.height)),
                child: content,
              );
              content = ColoredBox(
                color: AppPalette.background,
                child: Center(
                  child: SizedBox(width: contentWidth, child: content),
                ),
              );
            }
            return content;
          },
        );
      },
    );
  }
}
