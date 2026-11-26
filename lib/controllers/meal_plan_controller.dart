import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/ai_meal_plan_model.dart';
import '../data/models/user_profile_model.dart' show ActivityLevel;
import '../data/models/bmi_record_model.dart';
import '../data/services/calorie_service.dart';
import '../data/services/gemini_meal_plan_generator.dart';
import '../data/services/localization_service.dart';
import '../data/services/meal_plan_generator.dart';
import '../data/services/remote_config_service.dart';
import '../data/services/storage_service.dart';
import '../views/insights/meal_plan_data.dart';

class MealPlanController extends GetxController {
  static MealPlanController get to => Get.isRegistered<MealPlanController>()
      ? Get.find<MealPlanController>()
      : Get.put(MealPlanController(), permanent: true);

  final StorageService _storage = Get.find<StorageService>();

  final RxSet<String> eaten = <String>{}.obs;

  BMICategory category = BMICategory.normal;

  int targetKcal = 0;
  String goal = '';
  bool needsCare = false;
  ActivityLevel activity = ActivityLevel.lightlyActive;
  int age = 25;
  double weightKg = 70;

  // ── AI (Gemini) plan ──

  /// The generated plan, or null when the built-in 7-day plan is shown.
  final Rxn<AiMealPlan> aiPlan = Rxn<AiMealPlan>();

  /// `planId_week` entries for weeks being generated / that failed.
  final RxSet<String> _loading = <String>{}.obs;
  final RxSet<String> _failed = <String>{}.obs;

  /// The first week couldn't be generated, so the built-in plan is shown.
  final RxBool aiFailed = false.obs;

  MealPlanRequest? _request;
  GeminiMealPlanGenerator? _generator;
  Future<void> _queue = Future.value();

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.getEatenMeals();
    if (saved.isNotEmpty) eaten.addAll(saved);
    // Back on the 7-day plan: don't leave a day past its end selected.
    ever<AiMealPlan?>(aiPlan, (_) {
      if (selectedDay.value > totalDays) selectedDay.value = 1;
    });
  }

  void useRecord(BMIRecord r) {
    category = r.category;
    activity = r.activity;
    age = r.age;
    weightKg = r.weightKg;
    final t = CalorieService.forRecord(r);
    targetKcal = t.kcal;
    goal = t.goal;
    needsCare = t.needsCare;
  }

  void usePlanRequest(MealPlanRequest request) {
    final remote = Get.isRegistered<RemoteConfigService>()
        ? RemoteConfigService.to
        : null;
    if (remote == null || !remote.isGeminiMealPlanEnabled) {
      aiPlan.value = null;
      return;
    }
    if (_generator?.apiKey != remote.geminiApiKey ||
        !listEquals(_generator?.models, remote.geminiModels)) {
      _generator = GeminiMealPlanGenerator(
        apiKey: remote.geminiApiKey,
        models: remote.geminiModels,
      );
    }
    _request = request;
    aiFailed.value = false;

    final current = aiPlan.value ?? _storage.getAiMealPlan();
    if (current != null && current.signature == request.signature) {
      if (aiPlan.value?.id != current.id) {
        aiPlan.value = current;
        selectedDay.value = currentDay;
      }
    } else {
      // First plan, or the setup answers changed: start a new one.
      aiPlan.value = AiMealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        signature: request.signature,
        createdAt: DateTime.now(),
        totalWeeks: request.totalWeeks,
        slots: request.slots,
      );
      selectedDay.value = 1;
    }
    _ensureAhead();
  }

  /// Answers the current AI plan is being made with (for the loading copy).
  MealPlanRequest? get planRequest => _request;

  bool get isAiPlan => aiPlan.value != null;
  int get totalDays => aiPlan.value?.totalDays ?? MealPlanData.days;
  int get totalWeeks => aiPlan.value?.totalWeeks ?? 1;

  /// Meal slots of each day: the AI plan's, or the built-in three.
  List<String> get slots => aiPlan.value?.slots ?? AiMealPlan.standardSlots;

  /// Meals in one plan day (2–5 for an AI plan, 3 for the built-in plan).
  int get mealsPerDay => slots.length;

  /// Prefix of every meal key in the active plan.
  String get keyPrefix {
    final plan = aiPlan.value;
    return plan == null ? category.name : 'ai_${plan.id}';
  }

  /// Meals for a plan day, or null while that AI week is not ready.
  List<MealInfo>? mealsFor(int day) {
    final plan = aiPlan.value;
    if (plan == null) {
      return MealPlanData.mealsFor(category, day, targetKcal: targetKcal);
    }
    final meals = plan.mealsForDay(day);
    if (meals == null || meals.length < plan.slots.length) return null;
    return MealPlanData.aiMealsFor(
      category,
      keyPrefix,
      day,
      meals,
      slots: plan.slots,
      targetKcal: targetKcal,
    );
  }

  bool isWeekLoading(int week) {
    final plan = aiPlan.value;
    return plan != null && _loading.contains('${plan.id}_$week');
  }

  bool isWeekFailed(int week) {
    final plan = aiPlan.value;
    return plan != null && _failed.contains('${plan.id}_$week');
  }

  void selectWeek(int week) {
    selectedDay.value = (week - 1) * 7 + 1;
    ensureWeek(week);
  }

  Future<void> ensureWeek(int week) {
    final plan = aiPlan.value;
    final base = _request;
    final generator = _generator;
    if (plan == null || base == null || generator == null) {
      return Future.value();
    }
    final tag = '${plan.id}_$week';
    if (week < 1 ||
        week > plan.totalWeeks ||
        plan.hasWeek(week) ||
        _loading.contains(tag)) {
      return Future.value();
    }
    _loading.add(tag);
    _failed.remove(tag);
    final next = _queue.then(
      (_) => _generate(plan, week, base, generator, tag),
    );
    _queue = next.catchError((_) {});
    return next;
  }

  Future<void> _generate(
    AiMealPlan plan,
    int week,
    MealPlanRequest base,
    MealPlanGenerator generator,
    String tag,
  ) async {
    try {
      if (aiPlan.value?.id != plan.id) return; // replaced while queued
      final days = await generator.generateWeek(
        base.copyWith(
          week: week,
          totalWeeks: plan.totalWeeks,
          avoidNames: plan.usedNames,
          language: _languageName(),
        ),
      );
      // A new plan may have started while this week was generating.
      if (aiPlan.value?.id != plan.id) return;
      plan.weeks[week] = days;
      await _storage.saveAiMealPlan(plan);
      aiPlan.refresh();
    } catch (e) {
      debugPrint('[MealPlan] week $week failed: $e');
      if (aiPlan.value?.id != plan.id) return;
      if (plan.weeks.isEmpty) {
        // Nothing generated yet: show the built-in plan instead.
        aiPlan.value = null;
        aiFailed.value = true;
      } else {
        _failed.add(tag);
      }
    } finally {
      _loading.remove(tag);
    }
  }

  /// Retries after the first week failed and the built-in plan took over.
  void retryAiPlan() {
    final r = _request;
    if (r != null) usePlanRequest(r);
  }

  /// Keeps the current week and the one after it ready.
  void _ensureAhead() {
    final plan = aiPlan.value;
    if (plan == null) return;
    final week = AiMealPlan.weekOfDay(currentDay);
    ensureWeek(week);
    ensureWeek(AiMealPlan.weekOfDay(selectedDay.value));
    ensureWeek(week + 1);
  }

  static String _languageName() {
    final code = Get.locale?.languageCode ?? 'en';
    return LocalizationService.supportedLanguages
            .firstWhereOrNull((l) => l.code == code)
            ?.englishName ??
        'English';
  }

  // ── Progress ──

  final RxInt selectedDay = 1.obs;

  int get selectedWeek => AiMealPlan.weekOfDay(selectedDay.value);

  bool isEaten(String key) => eaten.contains(key);

  void markEaten(String key) {
    eaten.add(key);
    _storage.saveEatenMeals(eaten.toSet());
    _ensureAhead();
  }

  int eatenOnDay(int day) {
    final prefix = '${keyPrefix}_d${day}_';
    return eaten.where((k) => k.startsWith(prefix)).length;
  }

  int get eatenInPlan {
    final prefix = '${keyPrefix}_d';
    return eaten.where((k) => k.startsWith(prefix)).length;
  }

  int get daysCompleted =>
      [for (int d = 1; d <= totalDays; d++) eatenOnDay(d)]
          .where((n) => n >= mealsPerDay)
          .length;

  int get streak {
    int s = 0;
    for (int d = 1; d <= totalDays; d++) {
      if (eatenOnDay(d) >= mealsPerDay) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  int get currentDay {
    for (int d = 1; d <= totalDays; d++) {
      if (eatenOnDay(d) < mealsPerDay) return d;
    }
    return totalDays;
  }
}
