import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        return 'underweight'.tr;
      case BMICategory.normal:
        return 'normal'.tr;
      case BMICategory.overweight:
        return 'overweight'.tr;
      case BMICategory.obese:
        return 'obese'.tr;
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

  /// Light-mode pastel fill for the health feedback banner.
  Color get feedbackBackground {
    switch (this) {
      case BMICategory.underweight:
        return const Color(0xFFCCEBF8);
      case BMICategory.normal:
        return const Color(0xFFE8F9F7);
      case BMICategory.overweight:
        return const Color(0xFFFDDBB2);
      case BMICategory.obese:
        return const Color(0xFFFEB4B4);
    }
  }

  String get feedbackMessage {
    switch (this) {
      case BMICategory.underweight:
        return 'your_bmi_is_in_the_underweight'.tr;
      case BMICategory.normal:
        return 'great_job_your_bmi_is_in'.tr;
      case BMICategory.overweight:
        return 'your_bmi_is_in_the_overweight'.tr;
      case BMICategory.obese:
        return 'your_bmi_is_in_the_obese'.tr;
    }
  }

  String get bmiRangeDescription {
    switch (this) {
      case BMICategory.underweight:
        return 'your_bmi_is_below_the_healthy'.tr;
      case BMICategory.normal:
        return 'your_bmi_is_within_the_healthy'.tr;
      case BMICategory.overweight:
        return 'your_bmi_is_above_the_healthy'.tr;
      case BMICategory.obese:
        return 'your_bmi_is_in_the_obesity'.tr;
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

  String get heightDisplay {
    if (isCm) return '${heightCm.toStringAsFixed(0)} ${'unit_cm'.tr}';
    final totalInches = (heightCm / 2.54).round();
    return "${totalInches ~/ 12}'${totalInches % 12}\"";
  }

  String get weightDisplay {
    if (isKg) return '${weightKg.toStringAsFixed(1)} ${'unit_kg'.tr}';
    return '${(weightKg * 2.20462).toStringAsFixed(1)} ${'unit_lb'.tr}';
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
