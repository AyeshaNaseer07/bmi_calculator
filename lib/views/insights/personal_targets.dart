import '../../data/models/user_profile_model.dart' show ActivityLevel;

/// Water and sleep suggestions personalised from the user's profile.
class PersonalTargets {
  PersonalTargets._();

  /// Daily water in ml: about 33 ml per kg plus extra for activity.
  static int waterMl(double weightKg, ActivityLevel activity) {
    double extra;
    switch (activity) {
      case ActivityLevel.sedentary:
        extra = 0;
        break;
      case ActivityLevel.lightlyActive:
        extra = 250;
        break;
      case ActivityLevel.moderatelyActive:
        extra = 400;
        break;
      case ActivityLevel.veryActive:
        extra = 600;
        break;
      case ActivityLevel.extraActive:
        extra = 800;
        break;
    }
    final ml = (weightKg * 33 + extra).clamp(1500.0, 4000.0);
    return (ml / 50).round() * 50;
  }

  /// Number of 250 ml glasses, kept between 6 and 12.
  static int glasses(int ml) => (ml / 250).ceil().clamp(6, 12);

  static String litres(int ml) => (ml / 1000).toStringAsFixed(1);

  /// Recommended sleep range in hours for an age.
  static (int, int) sleepHours(int age) {
    if (age < 6) return (10, 13);
    if (age < 14) return (9, 12);
    if (age < 18) return (8, 10);
    if (age < 65) return (7, 9);
    return (7, 8);
  }

  static String sleepText(int age) {
    final (lo, hi) = sleepHours(age);
    return '$lo–$hi';
  }

  /// Suggested bedtime for a 7:00 AM wake-up, e.g. `10:30 PM — 7:00 AM`.
  static String bedtimeText(int age) {
    final (lo, hi) = sleepHours(age);
    // Aim for the upper-middle of the range, e.g. 8.5 h for adults.
    final hours = lo + (hi - lo) * 0.75;
    var bed = (7 * 60 - (hours * 60).round()) % 1440;
    if (bed < 0) bed += 1440;
    final h24 = bed ~/ 60;
    final m = bed % 60;
    final period = h24 >= 12 ? 'PM' : 'AM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $period — 7:00 AM';
  }
}
