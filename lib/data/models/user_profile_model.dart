import 'package:get/get.dart';

enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'male'.tr;
      case Gender.female:
        return 'female'.tr;
      case Gender.other:
        return 'other'.tr;
    }
  }
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive;

  String get title {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'sedentary'.tr;
      case ActivityLevel.lightlyActive:
        return 'lightly_active'.tr;
      case ActivityLevel.moderatelyActive:
        return 'moderately_active'.tr;
      case ActivityLevel.veryActive:
        return 'very_active'.tr;
      case ActivityLevel.extraActive:
        return 'extra_active'.tr;
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'little_or_no_exercise_desk_job'.tr;
      case ActivityLevel.lightlyActive:
        return 'light_exercise_or_sports_1_3'.tr;
      case ActivityLevel.moderatelyActive:
        return 'moderate_exercise_or_sports_3_5'.tr;
      case ActivityLevel.veryActive:
        return 'hard_exercise_or_sports_6_7'.tr;
      case ActivityLevel.extraActive:
        return 'very_hard_exercise_physical_job_or'.tr;
    }
  }
}

enum HealthGoal {
  loseWeight,
  buildMuscle,
  maintainWeight,
  improveHealth;

  String get title {
    switch (this) {
      case HealthGoal.loseWeight:
        return 'lose_weight'.tr;
      case HealthGoal.buildMuscle:
        return 'build_muscle'.tr;
      case HealthGoal.maintainWeight:
        return 'maintain_weight'.tr;
      case HealthGoal.improveHealth:
        return 'improve_health'.tr;
    }
  }

  String get description {
    switch (this) {
      case HealthGoal.loseWeight:
        return 'i_want_to_lose_weight_and'.tr;
      case HealthGoal.buildMuscle:
        return 'i_want_to_build_muscle_and'.tr;
      case HealthGoal.maintainWeight:
        return 'i_want_to_maintain_my_current'.tr;
      case HealthGoal.improveHealth:
        return 'i_want_to_improve_my_overall'.tr;
    }
  }
}

enum UnitSystem {
  metric,
  imperial;

  String get title {
    switch (this) {
      case UnitSystem.metric:
        return 'metric_kg_cm'.tr;
      case UnitSystem.imperial:
        return 'imperial_lb_ft_in'.tr;
    }
  }
}

class UserProfile {
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final double goalWeightKg;
  final ActivityLevel? activityLevel;
  final HealthGoal? healthGoal;

  const UserProfile({
    this.name = '',
    this.age = 25,
    this.gender = Gender.male,
    this.heightCm = 175.0,
    this.weightKg = 70.0,
    this.goalWeightKg = 60.0,
    this.activityLevel,
    this.healthGoal,
  });

  String get displayName =>
      (name.trim().isEmpty || name.trim().toLowerCase() == 'alex')
      ? ''
      : name.trim();

  String get homeDisplayName {
    final parts = displayName.split(RegExp(r'\s+'));
    if (parts.length < 3) return displayName;
    return '${parts[0].substring(0, 1).toUpperCase()}. ${parts[1]}';
  }

  UserProfile copyWith({
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    ActivityLevel? activityLevel,
    HealthGoal? healthGoal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      healthGoal: healthGoal ?? this.healthGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender.name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goalWeightKg': goalWeightKg,
      'activityLevel': activityLevel?.name,
      'healthGoal': healthGoal?.name,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String? ?? '';
    return UserProfile(
      name: rawName == 'Alex' ? '' : rawName,
      age: json['age'] as int? ?? 25,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.male,
      ),
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble() ?? 60.0,
      activityLevel: json['activityLevel'] == null
          ? null
          : ActivityLevel.values.cast<ActivityLevel?>().firstWhere(
              (e) => e?.name == json['activityLevel'],
              orElse: () => null,
            ),
      healthGoal: json['healthGoal'] == null
          ? null
          : HealthGoal.values.cast<HealthGoal?>().firstWhere(
              (e) => e?.name == json['healthGoal'],
              orElse: () => null,
            ),
    );
  }
}
