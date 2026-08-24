import 'dart:math';
import '../models/bmi_record_model.dart';

class BMIService {
  /// Calculates BMI: weightKg / (heightMeters ^ 2)
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    if (heightCm <= 0 || weightKg <= 0) {
      throw ArgumentError('Height and weight must be greater than zero.');
    }
    final heightMeters = heightCm / 100.0;
    final bmi = weightKg / pow(heightMeters, 2);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Calculates BMI from Imperial units (lb and ft/in)
  static double calculateBMIImperial({
    required double weightLb,
    required double heightFeet,
    double heightInches = 0.0,
  }) {
    final totalInches = (heightFeet * 12) + heightInches;
    if (totalInches <= 0 || weightLb <= 0) {
      throw ArgumentError('Height and weight must be greater than zero.');
    }
    final weightKg = lbsToKg(weightLb);
    final heightCm = inchesToCm(totalInches);
    return calculateBMI(weightKg: weightKg, heightCm: heightCm);
  }

  /// Classifies BMI into category
  static BMICategory getCategory(double bmi) {
    if (bmi < 18.5) {
      return BMICategory.underweight;
    } else if (bmi <= 24.9) {
      return BMICategory.normal;
    } else if (bmi <= 29.9) {
      return BMICategory.overweight;
    } else {
      return BMICategory.obese;
    }
  }

  /// Unit conversion utilities
  static double kgToLbs(double kg) => double.parse((kg * 2.20462).toStringAsFixed(1));
  static double lbsToKg(double lbs) => double.parse((lbs / 2.20462).toStringAsFixed(1));

  static double cmToInches(double cm) => cm / 2.54;
  static double inchesToCm(double inches) => double.parse((inches * 2.54).toStringAsFixed(1));
  static double feetToCm(double feet) => inchesToCm(feet * 12);

  static (int feet, int inches) cmToFeetAndInches(double cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet, inches);
  }

  /// Returns normalized gauge needle percentage (0.0 to 1.0)
  /// Scale from BMI 12 to BMI 38
  static double getGaugeProgress(double bmi) {
    const minBmi = 12.0;
    const maxBmi = 38.0;
    final clamped = bmi.clamp(minBmi, maxBmi);
    return (clamped - minBmi) / (maxBmi - minBmi);
  }

  /// Ideal weight range for a given height in cm
  static (double minKg, double maxKg) getIdealWeightRange(double heightCm) {
    if (heightCm <= 0) return (0.0, 0.0);
    final heightMeters = heightCm / 100.0;
    final minKg = 18.5 * pow(heightMeters, 2);
    final maxKg = 24.9 * pow(heightMeters, 2);
    return (
      double.parse(minKg.toStringAsFixed(1)),
      double.parse(maxKg.toStringAsFixed(1)),
    );
  }
}
