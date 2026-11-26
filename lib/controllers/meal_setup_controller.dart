import 'package:get/get.dart';

import '../data/models/bmi_record_model.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/bmi_service.dart';
import '../data/services/storage_service.dart';
import 'bmi_controller.dart';
import 'meal_plan_controller.dart';
import 'profile_controller.dart';

class MealSetupController extends GetxController {
  static MealSetupController get to => Get.isRegistered<MealSetupController>()
      ? Get.find<MealSetupController>()
      : Get.put(MealSetupController(), permanent: true);

  final StorageService _storage = Get.find<StorageService>();

  static const int totalSteps = 5;

  // ── Step 1: health profile (stored in cm / kg) ──
  final RxnInt age = RxnInt();
  final Rxn<Gender> gender = Rxn<Gender>();
  final RxnDouble heightCm = RxnDouble();
  final RxnDouble weightKg = RxnDouble();
  final Rxn<HealthGoal> goal = Rxn<HealthGoal>();
  final Rxn<ActivityLevel> activity = Rxn<ActivityLevel>();
  final RxBool heightInCm = true.obs;
  final RxBool weightInKg = true.obs;

  // ── Step 2: medical conditions ──
  final RxSet<String> conditions = <String>{}.obs;
  final RxString otherCondition = ''.obs;
  final RxBool noConditions = false.obs;

  // ── Step 3: food allergies ──
  final RxSet<String> allergies = <String>{}.obs;
  final RxString otherAllergy = ''.obs;
  final RxBool noAllergies = false.obs;

  // ── Step 4: dietary preferences ──
  final RxnString dietType = RxnString();
  final RxnString cuisine = RxnString();
  final RxSet<String> dislikes = <String>{}.obs;
  final RxString otherDislikes = ''.obs;
  final RxnString mealsPerDay = RxnString();
  final RxnString cooking = RxnString();
  final RxnString budget = RxnString();

  // ── Step 5: lifestyle ──
  final RxnString sleep = RxnString();
  final RxnString water = RxnString();
  final RxnString mealTiming = RxnString();
  final RxString notes = ''.obs;

  /// Steps (1–5) the user has finished with "Next".
  final RxSet<int> completedSteps = <int>{}.obs;
  final RxBool isComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    prefillHealthProfile();
  }

  // ── Validation ──

  static bool validAge(int? v) => v != null && v >= 2 && v <= 120;
  static bool validHeight(double? cm) => cm != null && cm >= 50 && cm <= 272;
  static bool validWeight(double? kg) => kg != null && kg >= 10 && kg <= 400;

  bool get healthProfileValid =>
      validAge(age.value) &&
      gender.value != null &&
      validHeight(heightCm.value) &&
      validWeight(weightKg.value) &&
      goal.value != null &&
      activity.value != null;

  bool get medicalValid =>
      noConditions.value ||
      conditions.isNotEmpty ||
      otherCondition.value.trim().isNotEmpty;

  bool get allergiesValid =>
      noAllergies.value ||
      allergies.isNotEmpty ||
      otherAllergy.value.trim().isNotEmpty;

  /// Key of the exclusive "None" chip under Foods You Dislike.
  static const String noDislikesKey = 'none';

  bool get dislikesValid {
    final typed = otherDislikes.value.trim().isNotEmpty;
    // "Other" needs the foods typed in.
    if (dislikes.contains('other') && !typed) return false;
    return dislikes.isNotEmpty || typed;
  }

  bool get dietValid =>
      dietType.value != null &&
      cuisine.value != null &&
      dislikesValid &&
      mealsPerDay.value != null &&
      cooking.value != null &&
      budget.value != null;

  bool get lifestyleValid =>
      activity.value != null &&
      sleep.value != null &&
      water.value != null &&
      mealTiming.value != null;

  bool isStepValid(int step) => switch (step) {
    1 => healthProfileValid,
    2 => medicalValid,
    3 => allergiesValid,
    4 => dietValid,
    _ => lifestyleValid,
  };

  // ── Mutations ──

  void toggleCondition(String key) {
    if (!conditions.remove(key)) conditions.add(key);
    if (conditions.isNotEmpty) noConditions.value = false;
  }

  void toggleNoConditions() {
    noConditions.toggle();
    if (noConditions.value) {
      conditions.clear();
      otherCondition.value = '';
    }
  }

  void setOtherCondition(String v) {
    otherCondition.value = v;
    if (v.trim().isNotEmpty) noConditions.value = false;
  }

  void toggleAllergy(String key) {
    if (!allergies.remove(key)) allergies.add(key);
    if (allergies.isNotEmpty) noAllergies.value = false;
  }

  void toggleNoAllergies() {
    noAllergies.toggle();
    if (noAllergies.value) {
      allergies.clear();
      otherAllergy.value = '';
    }
  }

  void setOtherAllergy(String v) {
    otherAllergy.value = v;
    if (v.trim().isNotEmpty) noAllergies.value = false;
  }

  /// "None" is exclusive with the other dislike chips and typed foods.
  void toggleDislike(String key) {
    if (dislikes.remove(key)) return;
    if (key == noDislikesKey) {
      dislikes.clear();
      otherDislikes.value = '';
    } else {
      dislikes.remove(noDislikesKey);
    }
    dislikes.add(key);
  }

  void setOtherDislikes(String v) {
    otherDislikes.value = v;
    if (v.trim().isNotEmpty) dislikes.remove(noDislikesKey);
  }

  void completeStep(int step) {
    completedSteps.add(step);
    save();
  }

  /// Fills empty health fields from the latest BMI record and profile.
  void prefillHealthProfile() {
    final unit = _storage.getUnitSystem();
    final record = Get.isRegistered<BMIController>()
        ? Get.find<BMIController>().latestRecord.value
        : null;
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().userProfile.value
        : (_storage.hasUserProfile() ? _storage.getUserProfile() : null);

    if (record != null) {
      age.value ??= record.age;
      gender.value ??= Gender.values.firstWhereOrNull(
        (g) => g.name == record.gender.trim().toLowerCase(),
      );
      heightCm.value ??= record.heightCm;
      weightKg.value ??= record.weightKg;
      activity.value ??= record.activity;
      if (!completedSteps.contains(1)) {
        heightInCm.value = record.isCm;
        weightInKg.value = record.isKg;
      }
    } else if (!completedSteps.contains(1)) {
      heightInCm.value = unit == UnitSystem.metric;
      weightInKg.value = unit == UnitSystem.metric;
    }
    if (profile != null) {
      goal.value ??= profile.healthGoal;
      activity.value ??= profile.activityLevel;
    }
  }

  /// Marks setup done and feeds the health profile into the meal plan.
  Future<void> finish() async {
    completedSteps.add(totalSteps);
    isComplete.value = true;
    await save();
    applyToPlan();
  }

  /// Updates the meal plan's BMI category and calorie target from step 1.
  void applyToPlan() {
    if (!healthProfileValid) return;
    final h = heightCm.value!;
    final w = weightKg.value!;
    final bmi = BMIService.calculateBMI(weightKg: w, heightCm: h);
    MealPlanController.to.useRecord(
      BMIRecord(
        id: 'meal_setup',
        bmiValue: bmi,
        weightKg: w,
        heightCm: h,
        age: age.value!,
        gender: gender.value!.name,
        category: BMIService.getCategory(bmi),
        date: DateTime.now(),
        isCm: heightInCm.value,
        isKg: weightInKg.value,
        activity: activity.value!,
      ),
    );
  }

  // ── Persistence ──

  Future<void> save() => _storage.saveMealSetup({
    'age': age.value,
    'gender': gender.value?.name,
    'heightCm': heightCm.value,
    'weightKg': weightKg.value,
    'goal': goal.value?.name,
    'activity': activity.value?.name,
    'heightInCm': heightInCm.value,
    'weightInKg': weightInKg.value,
    'conditions': conditions.toList(),
    'otherCondition': otherCondition.value,
    'noConditions': noConditions.value,
    'allergies': allergies.toList(),
    'otherAllergy': otherAllergy.value,
    'noAllergies': noAllergies.value,
    'dietType': dietType.value,
    'cuisine': cuisine.value,
    'dislikes': dislikes.toList(),
    'otherDislikes': otherDislikes.value,
    'mealsPerDay': mealsPerDay.value,
    'cooking': cooking.value,
    'budget': budget.value,
    'sleep': sleep.value,
    'water': water.value,
    'mealTiming': mealTiming.value,
    'notes': notes.value,
    'completedSteps': completedSteps.toList(),
    'isComplete': isComplete.value,
  });

  void _load() {
    final j = _storage.getMealSetup();
    if (j == null) return;
    List<String> strings(String k) =>
        (j[k] as List?)?.whereType<String>().toList() ?? const [];

    age.value = (j['age'] as num?)?.toInt();
    gender.value = Gender.values.firstWhereOrNull((e) => e.name == j['gender']);
    heightCm.value = (j['heightCm'] as num?)?.toDouble();
    weightKg.value = (j['weightKg'] as num?)?.toDouble();
    goal.value = HealthGoal.values.firstWhereOrNull((e) => e.name == j['goal']);
    activity.value = ActivityLevel.values.firstWhereOrNull(
      (e) => e.name == j['activity'],
    );
    heightInCm.value = j['heightInCm'] as bool? ?? true;
    weightInKg.value = j['weightInKg'] as bool? ?? true;
    conditions.assignAll(strings('conditions'));
    otherCondition.value = j['otherCondition'] as String? ?? '';
    noConditions.value = j['noConditions'] as bool? ?? false;
    allergies.assignAll(strings('allergies'));
    otherAllergy.value = j['otherAllergy'] as String? ?? '';
    noAllergies.value = j['noAllergies'] as bool? ?? false;
    dietType.value = j['dietType'] as String?;
    cuisine.value = j['cuisine'] as String?;
    dislikes.assignAll(strings('dislikes'));
    otherDislikes.value = j['otherDislikes'] as String? ?? '';
    mealsPerDay.value = j['mealsPerDay'] as String?;
    cooking.value = j['cooking'] as String?;
    budget.value = j['budget'] as String?;
    sleep.value = j['sleep'] as String?;
    water.value = j['water'] as String?;
    mealTiming.value = j['mealTiming'] as String?;
    notes.value = j['notes'] as String? ?? '';
    completedSteps.assignAll(
      (j['completedSteps'] as List?)?.whereType<int>() ?? const <int>[],
    );
    isComplete.value = j['isComplete'] as bool? ?? false;
  }
}
