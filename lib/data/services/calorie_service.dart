import '../models/bmi_record_model.dart';
import '../models/user_profile_model.dart' show ActivityLevel;

/// Multiplier applied to resting metabolic rate for each activity level.
extension ActivityLevelFactor on ActivityLevel {
  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }
}

/// A personalised daily calorie suggestion.
class CalorieTarget {
  final int kcal;
  final int maintenance;
  final String goal;

  /// True when a generic plan is not appropriate (e.g. under 18) and the user
  /// should be told to talk to a professional.
  final bool needsCare;

  const CalorieTarget({
    required this.kcal,
    required this.maintenance,
    required this.goal,
    required this.needsCare,
  });
}

/// Estimates daily calories with the Mifflin-St Jeor equation, then applies a
/// modest goal adjustment for the user's BMI category.
class CalorieService {
  CalorieService._();

  static const int _minFemale = 1200;
  static const int _minMale = 1500;

  static CalorieTarget forRecord(BMIRecord r) {
    final g = r.gender.trim().toLowerCase();
    final genderOffset = g == 'male' ? 5.0 : (g == 'female' ? -161.0 : -78.0);
    final bmr = 10 * r.weightKg + 6.25 * r.heightCm - 5 * r.age + genderOffset;
    final maintenance = bmr * r.activity.factor;

    final minimum = g == 'male' ? _minMale : _minFemale;
    final isMinor = r.age < 18;

    double adjust;
    String goal;
    switch (r.category) {
      case BMICategory.underweight:
        adjust = isMinor ? 0 : 400;
        goal = isMinor ? 'Support healthy growth' : 'Gain weight gradually';
        break;
      case BMICategory.normal:
        adjust = 0;
        goal = 'Maintain your weight';
        break;
      case BMICategory.overweight:
        adjust = isMinor ? 0 : -400;
        goal = isMinor ? 'Support healthy growth' : 'Lose weight gradually';
        break;
      case BMICategory.obese:
        adjust = isMinor ? 0 : -500;
        goal = isMinor ? 'Support healthy growth' : 'Lose weight gradually';
        break;
    }

    var target = maintenance + adjust;
    if (adjust < 0 && target < minimum) target = minimum.toDouble();

    return CalorieTarget(
      kcal: _round50(target),
      maintenance: _round50(maintenance),
      goal: goal,
      needsCare: isMinor,
    );
  }

  static int _round50(double v) => (v / 50).round() * 50;
}
