import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bmi_controller.dart';
import '../../controllers/health_insight_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/weight_tracker_controller.dart';
import '../../views/bmi_calculator/bmi_calculator_screen.dart';
import '../../views/bmi_calculator/bmi_result_screen.dart';
import '../../views/health_insights/activity_level_screen.dart';
import '../../views/health_insights/add_health_data_screen.dart';
import '../../views/health_insights/health_insight_result_screen.dart';
import '../../views/health_insights/your_goal_screen.dart';
import '../../views/history/history_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/language/language_selection_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/onboarding/paywall_screen.dart';
import '../../views/profile/change_password_screen.dart';
import '../../views/profile/languages_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/weight_tracking/add_weight_screen.dart';
import '../../views/weight_tracking/weight_tracking_screen.dart';
import 'app_routes.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.paywall,
      page: () => const PaywallScreen(),
      popGesture: false,
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BMIController>()) {
          Get.put(BMIController(), permanent: true);
        }
        if (!Get.isRegistered<WeightTrackerController>()) {
          Get.put(WeightTrackerController(), permanent: true);
        }
        if (!Get.isRegistered<HealthInsightController>()) {
          Get.put(HealthInsightController(), permanent: true);
        }
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.bmiCalculator,
      page: () => const BMICalculatorScreen(),
    ),
    GetPage(
      name: AppRoutes.bmiResult,
      page: () => const BMIResultScreen(),
    ),
    GetPage(
      name: AppRoutes.weightTracking,
      page: () => const WeightTrackingScreen(),
    ),
    GetPage(
      name: AppRoutes.addWeight,
      page: () => const AddWeightScreen(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.healthInsights,
      page: () => const AddHealthDataScreen(),
    ),
    GetPage(
      name: AppRoutes.activityLevel,
      page: () => const ActivityLevelScreen(),
    ),
    GetPage(
      name: AppRoutes.yourGoal,
      page: () => const YourGoalScreen(),
    ),
    GetPage(
      name: AppRoutes.healthInsightResult,
      page: () => const HealthInsightResultScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.languagesSettings,
      page: () => const LanguagesScreen(),
    ),
  ];
}
