import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:bmi_calculator/controllers/app_controller.dart';
import 'package:bmi_calculator/data/services/health_kit_service.dart';
import 'package:bmi_calculator/data/services/storage_service.dart';
import 'package:bmi_calculator/main.dart';

void main() {
  testWidgets('BMI Calculator app boots up into Splash Screen and shows tagline', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService().init();
    Get.put<StorageService>(storage, permanent: true);
    Get.put<HealthKitService>(HealthKitService(), permanent: true);
    Get.put<AppController>(AppController(), permanent: true);

    await tester.pumpWidget(const BMIApp(initialLocale: Locale('en', 'US')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Know Your Body. Live Healthier'), findsOneWidget);

    // Fast-forward remaining timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
