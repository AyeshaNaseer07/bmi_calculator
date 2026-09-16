enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
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
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extraActive:
        return 'Extra Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise. Desk job or spending most of the day sitting.';
      case ActivityLevel.lightlyActive:
        return 'Light exercise or sports 1-3 days per week.';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise or sports 3-5 days per week.';
      case ActivityLevel.veryActive:
        return 'Hard exercise or sports 6-7 days per week.';
      case ActivityLevel.extraActive:
        return 'Very hard exercise, physical job or training twice a day';
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
        return 'Lose Weight';
      case HealthGoal.buildMuscle:
        return 'Build Muscle';
      case HealthGoal.maintainWeight:
        return 'Maintain Weight';
      case HealthGoal.improveHealth:
        return 'Improve Health';
    }
  }

  String get description {
    switch (this) {
      case HealthGoal.loseWeight:
        return 'I want to lose weight and improve my health.';
      case HealthGoal.buildMuscle:
        return 'I want to build muscle and gain strength.';
      case HealthGoal.maintainWeight:
        return 'I want to maintain my current weight and stay healthy.';
      case HealthGoal.improveHealth:
        return 'I want to improve my overall health and wellness.';
    }
  }
}

enum UnitSystem {
  metric,
  imperial;

  String get title {
    switch (this) {
      case UnitSystem.metric:
        return 'Metric (kg, cm)';
      case UnitSystem.imperial:
        return 'Imperial (lb, ft/in)';
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
  final ActivityLevel activityLevel;
  final HealthGoal healthGoal;

  const UserProfile({
    this.name = '',
    this.age = 25,
    this.gender = Gender.male,
    this.heightCm = 175.0,
    this.weightKg = 70.0,
    this.goalWeightKg = 60.0,
    this.activityLevel = ActivityLevel.sedentary,
    this.healthGoal = HealthGoal.loseWeight,
  });

  String get displayName =>
      (name.trim().isEmpty || name.trim().toLowerCase() == 'alex')
          ? ''
          : name.trim();

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
      'activityLevel': activityLevel.name,
      'healthGoal': healthGoal.name,
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
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.sedentary,
      ),
      healthGoal: HealthGoal.values.firstWhere(
        (e) => e.name == json['healthGoal'],
        orElse: () => HealthGoal.loseWeight,
      ),
    );
  }
}
