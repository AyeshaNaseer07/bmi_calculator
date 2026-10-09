import 'package:flutter/material.dart';

import '../../data/models/user_profile_model.dart' show ActivityLevel;
import '../../data/models/bmi_record_model.dart';

/// One day of the weekly activity routine.
class ActivityDay {
  final String key;
  final String dayLabel;
  final String title;
  final String blurb;
  final IconData icon;

  /// Session length in minutes; 0 means a recovery day.
  final int minutes;

  const ActivityDay({
    required this.key,
    required this.dayLabel,
    required this.title,
    required this.blurb,
    required this.icon,
    required this.minutes,
  });

  String get chip => minutes == 0 ? 'Recovery' : '$minutes min';
}

class _Base {
  final String title;
  final String blurb;
  final IconData icon;
  final int minutes;
  const _Base(this.title, this.blurb, this.icon, this.minutes);
}

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _rest = _Base(
  'Rest & stretch',
  'Take it easy and stretch gently.',
  Icons.self_improvement_rounded,
  0,
);

// Minutes below are for a "Light" activity level and are scaled per user.
const Map<BMICategory, List<_Base>> _plans = {
  // Strength-focused, light cardio so energy is kept for gaining weight.
  BMICategory.underweight: [
    _Base('Strength basics', 'Simple bodyweight moves to build muscle.',
        Icons.fitness_center_rounded, 25),
    _Base('Easy walk', 'Keep cardio gentle to save energy.',
        Icons.directions_walk_rounded, 15),
    _Base('Strength basics', 'Squats, push-ups and lunges at your pace.',
        Icons.fitness_center_rounded, 25),
    _Base('Yoga & stretch', 'Improve flexibility and relax.',
        Icons.self_improvement_rounded, 15),
    _Base('Strength basics', 'Add a little more resistance than last week.',
        Icons.fitness_center_rounded, 25),
    _Base('Easy walk', 'A relaxed walk or some light play.',
        Icons.park_outlined, 20),
    _rest,
  ],
  BMICategory.normal: [
    _Base('Brisk walk', 'Walk fast enough to raise your heart rate.',
        Icons.directions_walk_rounded, 30),
    _Base('Strength circuit', 'Bodyweight moves for legs, core and arms.',
        Icons.fitness_center_rounded, 20),
    _Base('Cycling or jog', 'A steady cardio session you enjoy.',
        Icons.directions_bike_rounded, 25),
    _Base('Yoga & stretch', 'Improve flexibility and recover.',
        Icons.self_improvement_rounded, 15),
    _Base('Brisk walk', 'Keep a steady, comfortable pace.',
        Icons.directions_walk_rounded, 30),
    _Base('Active fun', 'Sport, hiking or anything that gets you moving.',
        Icons.park_outlined, 30),
    _rest,
  ],
  // Low-impact choices that are kind to the joints.
  BMICategory.overweight: [
    _Base('Brisk walk', 'Walk at a pace where you can still talk.',
        Icons.directions_walk_rounded, 25),
    _Base('Bodyweight strength', 'Chair squats, wall push-ups and bridges.',
        Icons.fitness_center_rounded, 20),
    _Base('Cycling', 'Low-impact cardio, outdoors or stationary.',
        Icons.directions_bike_rounded, 25),
    _Base('Stretching', 'Loosen up and recover.',
        Icons.self_improvement_rounded, 15),
    _Base('Brisk walk', 'Aim to feel warm and slightly breathless.',
        Icons.directions_walk_rounded, 25),
    _Base('Swim or active fun', 'Gentle on joints and fun to do.',
        Icons.pool_rounded, 30),
    _rest,
  ],
  // Start small and build up slowly.
  BMICategory.obese: [
    _Base('Easy walk', 'Start at a comfortable pace, rest when you need to.',
        Icons.directions_walk_rounded, 15),
    _Base('Seated strength', 'Gentle chair-based moves for arms and legs.',
        Icons.chair_alt_rounded, 10),
    _Base('Easy walk', 'Try to add a few minutes each week.',
        Icons.directions_walk_rounded, 15),
    _Base('Gentle stretching', 'Move slowly and breathe deeply.',
        Icons.self_improvement_rounded, 10),
    _Base('Easy walk', 'Keep it steady and pain-free.',
        Icons.directions_walk_rounded, 20),
    _Base('Water or low-impact fun', 'Walking in a pool or a relaxed dance.',
        Icons.pool_rounded, 20),
    _rest,
  ],
};

const Map<BMICategory, String> _tips = {
  BMICategory.underweight:
      'Strength training helps turn extra calories into muscle. Eat a snack '
          'within an hour after exercise.',
  BMICategory.normal:
      'Mix cardio, strength and stretching to keep your weight and energy '
          'steady.',
  BMICategory.overweight:
      'Low-impact activity protects your joints. Consistency matters more than '
          'intensity.',
  BMICategory.obese:
      'Start small and add a few minutes each week. Every bit of movement '
          'counts.',
};

class ActivityPlanData {
  ActivityPlanData._();

  static double _factor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 0.75;
      case ActivityLevel.lightlyActive:
        return 1.0;
      case ActivityLevel.moderatelyActive:
        return 1.25;
      case ActivityLevel.veryActive:
        return 1.5;
      case ActivityLevel.extraActive:
        return 1.6;
    }
  }

  static List<ActivityDay> weekFor(BMICategory cat, ActivityLevel level) {
    final f = _factor(level);
    final base = _plans[cat]!;
    return [
      for (int i = 0; i < 7; i++)
        ActivityDay(
          key: '${cat.name}_${_days[i].toLowerCase()}',
          dayLabel: _days[i],
          title: base[i].title,
          blurb: base[i].blurb,
          icon: base[i].icon,
          minutes: base[i].minutes == 0
              ? 0
              : ((base[i].minutes * f) / 5).round() * 5,
        ),
    ];
  }

  /// Today's routine entry (Monday = first).
  static ActivityDay today(BMICategory cat, ActivityLevel level) =>
      weekFor(cat, level)[DateTime.now().weekday - 1];

  static String tipFor(BMICategory cat) => _tips[cat]!;

  static int weeklyMinutes(BMICategory cat, ActivityLevel level) =>
      weekFor(cat, level).fold(0, (a, d) => a + d.minutes);
}
