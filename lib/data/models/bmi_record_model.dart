import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

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

  String get rangeText {
    switch (this) {
      case BMICategory.underweight:
        return '<18.5';
      case BMICategory.normal:
        return '18.5–24.9';
      case BMICategory.overweight:
        return '25–29.9';
      case BMICategory.obese:
        return '30–34.9';
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
        return 'Your BMI is below the standard range. A nutrient-dense diet and fitness plan can support healthy weight gain.';
      case BMICategory.normal:
        return 'Great job! Your BMI is in the normal range. Keep maintaining a healthy lifestyle.';
      case BMICategory.overweight:
        return 'Your BMI is slightly elevated. Consistent physical activity and mindful nutrition can help bring it to a healthy balance.';
      case BMICategory.obese:
        return 'Your BMI indicates high risk. We recommend focusing on regular active routines and consulting a healthcare advisor.';
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

  const BMIRecord({
    required this.id,
    required this.bmiValue,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.category,
    required this.date,
  });

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
    );
  }
}
