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

  static double inchesToCm(double inches) => double.parse((inches * 2.54).toStringAsFixed(1));

  static (int feet, int inches) cmToFeetAndInches(double cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet, inches);
  }

  /// Returns normalized gauge needle position (0.0 = left end, 1.0 = right).
  ///
  /// The gauge is drawn as four equal quarters (underweight, normal,
  /// overweight, obese) labelled 9.9 at the left end and 34.9 at the right,
  /// so each category maps onto its own quarter. Anything above 34.9 sits on
  /// the extreme right edge and anything below 9.9 on the extreme left.
  static double getGaugeProgress(double bmi) {
    const stops = <(double, double)>[
      (9.9, 0.0),
      (18.5, 0.25),
      (25.0, 0.5),
      (30.0, 0.75),
      (34.9, 1.0),
    ];
    if (bmi <= stops.first.$1) return 0.0;
    if (bmi >= stops.last.$1) return 1.0;
    for (var i = 1; i < stops.length; i++) {
      final (b1, p1) = stops[i];
      if (bmi <= b1) {
        final (b0, p0) = stops[i - 1];
        return p0 + (bmi - b0) / (b1 - b0) * (p1 - p0);
      }
    }
    return 1.0;
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
