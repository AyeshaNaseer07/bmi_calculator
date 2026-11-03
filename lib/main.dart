import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:applovin_max/applovin_max.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bmi_calculator/core/constants/app_contants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/routes/app_pages.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'data/services/localization_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await _waitUntilAppActive();
  final PermissionStatus status = await Permission.appTrackingTransparency
      .request();
  debugPrint('ATT status: $status');
  await showCMP();

  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);

  await LocalizationService.init();
  LocalizationService.applyIntlLocale(storageService.getLanguage());
  final currentLocale = LocalizationService.getLocaleFromLanguage(
    storageService.getLanguage(),
  );

  runApp(BMIApp(initialLocale: currentLocale));
}

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
void logMaxAdRevenue(MaxAd ad, {required String adType}) => logAdRevenue(
  networkName: ad.networkName,
  revenue: ad.revenue,
  adUnitId: ad.adUnitId,
  adType: adType,
);

/// Same as [logMaxAdRevenue], for ads that don't come as a [MaxAd] (the
/// natively rendered native ads).
void logAdRevenue({
  required String networkName,
  required double revenue,
  required String adUnitId,
  required String adType,
}) {
  try {
    appsflyerSdk?.logAdRevenue(
      AdRevenueData(
        monetizationNetwork: networkName,
        mediationNetwork: AFMediationNetwork.applovinMax.value,
        currencyIso4217Code: 'USD',
        revenue: revenue,
        additionalParameters: {
          "country": getDeviceCountry(),
          "adUnit": adUnitId,
          "adType": adType,
        },
      ),
    );
    debugPrint("✅ logMaxAdRevenue: $adType $revenue USD");
  } catch (e, stackTrace) {
    debugPrint("❌ logMaxAdRevenue failed: $e");
    debugPrint("📌 Stack trace: $stackTrace");
  }
}

const Size _phoneDesignSize = Size(375, 812);

bool _isTabletScreen(Size screen) =>
    !screen.isEmpty && screen.shortestSide >= 600;

// Tablets use the full width in portrait; landscape keeps the portrait width
// so rows and cards don't stretch across the whole screen.
double _contentWidthFor(Size screen) =>
    _isTabletScreen(screen) ? screen.shortestSide : screen.width;

// Tablets scale the phone design up as far as the screen height allows, so
// the design height stays at 812 (every phone layout still fits vertically)
// and only the width grows. Measured on the content column, so landscape
// scales the same as portrait.
double _tabletScaleFor(Size screen) {
  final double width = _contentWidthFor(screen);
  return math.min(
    width / _phoneDesignSize.width,
    screen.height / _phoneDesignSize.height,
  );
}

Size _designSizeFor(Size screen) {
  if (!_isTabletScreen(screen)) return _phoneDesignSize;
  final double scale = _tabletScaleFor(screen);
  return Size(screen.width / scale, screen.height / scale);
}

Size _screenSize(BuildContext context) {
  final mqSize = MediaQuery.maybeSizeOf(context);
  if (mqSize != null && !mqSize.isEmpty) return mqSize;
  final view = View.maybeOf(context);
  if (view != null) {
    final ratio = view.devicePixelRatio;
    if (ratio > 0 && !view.physicalSize.isEmpty) {
      return view.physicalSize / ratio;
    }
  }
  return _phoneDesignSize;
}

class BMIApp extends StatelessWidget {
  final Locale initialLocale;

  const BMIApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _designSizeFor(_screenSize(context)),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'app_name'.tr,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          translations: LocalizationService(),
          locale: initialLocale,
          fallbackLocale: LocalizationService.fallbackLocale,
          supportedLocales: LocalizationService.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          navigatorObservers: [appRouteObserver, AnalyticsRouteObserver()],
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
