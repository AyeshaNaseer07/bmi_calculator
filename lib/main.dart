import 'dart:async';
import 'dart:math' as math;

import 'package:bmi_calculator/core/constants/app_contants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

const Size _phoneDesignSize = Size(375, 812);

bool _isTabletScreen(Size screen) =>
    !screen.isEmpty && screen.shortestSide >= 600;

double _contentWidthFor(Size screen) =>
    _isTabletScreen(screen) ? screen.shortestSide : screen.width;

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
