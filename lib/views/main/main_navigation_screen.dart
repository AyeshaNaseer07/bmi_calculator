import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../weight_tracking/weight_tracking_screen.dart';
import '../widgets/main_bottom_nav_bar.dart';
import 'main_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    mainTabIndex.value = 0;
  }

  static const _tabs = [
    HomeScreen(),
    ProfileScreen(),
    WeightTrackingScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = mainTabIndex.value;
      return Scaffold(
        body: IndexedStack(index: currentIndex, children: _tabs),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) => mainTabIndex.value = index,
          onAddTap: () => Get.toNamed(AppRoutes.bmiCalculator),
        ),
      );
    });
  }
}
