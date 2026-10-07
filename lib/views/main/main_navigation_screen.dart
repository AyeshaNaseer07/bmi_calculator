import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/routes/app_routes.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../weight_tracking/weight_tracking_screen.dart';
import '../widgets/main_bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeScreen(),
    ProfileScreen(),
    WeightTrackingScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Obx(() {
        // Hidden on Home when there is no BMI record and the native ad failed.
        final bmi = Get.find<BMIController>();
        final noRecord =
            bmi.bmiHistory.isEmpty || bmi.latestRecord.value == null;
        if (_currentIndex == 0 && noRecord && homeAdFailed.value) {
          return const SizedBox.shrink();
        }
        return MainBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          onAddTap: () => Get.toNamed(AppRoutes.bmiCalculator),
        );
      }),
    );
  }
}
