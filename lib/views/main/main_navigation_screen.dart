import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/services/analytics_service.dart';
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

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _tabFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );
  late final Animation<double> _tabOpacity = CurvedAnimation(
    parent: _tabFade,
    curve: Curves.easeOut,
  );

  static const _tabs = [
    HomeScreen(),
    ProfileScreen(showBackButton: false),
    WeightTrackingScreen(showBackButton: false),
    HistoryScreen(showBackButton: false),
  ];

  // Screen names for the tabs above (same order). Home is logged by the route
  // observer when the shell is pushed.
  static const _tabScreenNames = [
    'home',
    'profile',
    'weight-tracking',
    'history',
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    AnalyticsService.logScreen(_tabScreenNames[index]);
    _tabFade.forward(from: 0);
  }

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _tabOpacity,
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        onAddTap: () => Get.toNamed(AppRoutes.bmiCalculator),
      ),
    );
  }
}
