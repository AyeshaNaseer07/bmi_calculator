import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import 'user_profile_model.dart' show ActivityLevel;

enum BMICategory {
  underweight,
  normal,
  overweight,
  obese;

  String get label {
    switch (this) {
      case BMICategory.underweight:
        return 'Underweight';
      case BMICategory.normal:
        return 'Normal';
      case BMICategory.overweight:
        return 'Overweight';
      case BMICategory.obese:
        return 'Obese';
    }
  }

  Color get color {
    switch (this) {
      case BMICategory.underweight:
        return AppColors.underweight;
      case BMICategory.normal:
        return AppColors.normal;
      case BMICategory.overweight:
        return AppColors.overweight;
      case BMICategory.obese:
        return AppColors.obese;
    }
  }

  String get feedbackMessage {
    switch (this) {
      case BMICategory.underweight:
        return ' Your BMI is in the underweight range. Nourish your body with healthy foods.';
      case BMICategory.normal:
        return 'Great job! Your BMI is in the normal range. Keep maintaining a healthy lifestyle.';
      case BMICategory.overweight:
        return 'Your BMI is in the overweight range. Stay active and eat balanced meals.';
      case BMICategory.obese:
        return 'Your BMI is in the obese range. Start making healthier choices and work toward a healthier weight.';
    }
  }

  String get bmiRangeDescription {
    switch (this) {
      case BMICategory.underweight:
        return 'Your BMI is below the healthy range.';
      case BMICategory.normal:
        return 'Your BMI is within the healthy range.';
      case BMICategory.overweight:
        return 'Your BMI is above the healthy range.';
      case BMICategory.obese:
        return 'Your BMI is in the obesity range.';
    }
  }

  Widget buildFeedbackIcon({double size = 20}) {
    switch (this) {
      case BMICategory.underweight:
        return Image.asset(
          AppAssets.categoryCross,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      case BMICategory.normal:
        return Image.asset(
          AppAssets.shieldicon,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      case BMICategory.overweight:
        return Image.asset(
          AppAssets.categoryCross,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      case BMICategory.obese:
        return Image.asset(
          AppAssets.categoryCross,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
    }
  }
}

class BMIRecord {
  final String id;
  final double bmiValue;
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender;
  final BMICategory category;
  final DateTime date;
  final bool isCm;
  final bool isKg;
  final ActivityLevel activity;

  const BMIRecord({
    required this.id,
    required this.bmiValue,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.category,
    required this.date,
    this.isCm = true,
    this.isKg = true,
    this.activity = ActivityLevel.lightlyActive,
  });

  /// Height formatted in the unit the user entered, e.g. `175 cm` or `5'9"`.
  String get heightDisplay {
    if (isCm) return '${heightCm.toStringAsFixed(0)} cm';
    final totalInches = (heightCm / 2.54).round();
    return "${totalInches ~/ 12}'${totalInches % 12}\"";
  }

  /// Weight formatted in the unit the user entered, e.g. `70.0 kg` or `154.3 lb`.
  String get weightDisplay {
    if (isKg) return '${weightKg.toStringAsFixed(1)} kg';
    return '${(weightKg * 2.20462).toStringAsFixed(1)} lb';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bmiValue': bmiValue,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
      'gender': gender,
      'category': category.name,
      'date': date.toIso8601String(),
      'isCm': isCm,
      'isKg': isKg,
      'activity': activity.name,
    };
  }

  factory BMIRecord.fromJson(Map<String, dynamic> json) {
    return BMIRecord(
      id: json['id'] as String,
      bmiValue: (json['bmiValue'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      age: json['age'] as int,
      gender: json['gender'] as String,
      category: BMICategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BMICategory.normal,
      ),
      date: DateTime.parse(json['date'] as String),
      isCm: json['isCm'] as bool? ?? true,
      isKg: json['isKg'] as bool? ?? true,
      activity: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activity'],
        orElse: () => ActivityLevel.lightlyActive,
      ),
    );
  }
}
