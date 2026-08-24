import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_calculator/data/models/bmi_record_model.dart';
import 'package:bmi_calculator/data/services/bmi_service.dart';

void main() {
  group('BMI Calculation & Category Tests', () {
    test('Calculates Normal BMI correctly (70kg, 175cm -> ~22.9)', () {
      final bmi = BMIService.calculateBMI(weightKg: 70.0, heightCm: 175.0);
      expect(bmi, equals(22.9));
      expect(BMIService.getCategory(bmi), equals(BMICategory.normal));
    });

    test('Calculates Underweight BMI correctly (45kg, 175cm -> 14.7)', () {
      final bmi = BMIService.calculateBMI(weightKg: 45.0, heightCm: 175.0);
      expect(bmi, equals(14.7));
      expect(BMIService.getCategory(bmi), equals(BMICategory.underweight));
    });

    test('Calculates Overweight BMI correctly (85kg, 175cm -> 27.8)', () {
      final bmi = BMIService.calculateBMI(weightKg: 85.0, heightCm: 175.0);
      expect(bmi, equals(27.8));
      expect(BMIService.getCategory(bmi), equals(BMICategory.overweight));
    });

    test('Calculates Obesity BMI correctly (105kg, 175cm -> 34.3)', () {
      final bmi = BMIService.calculateBMI(weightKg: 105.0, heightCm: 175.0);
      expect(bmi, equals(34.3));
      expect(BMIService.getCategory(bmi), equals(BMICategory.obese));
    });

    test('Throws ArgumentError for zero height', () {
      expect(
        () => BMIService.calculateBMI(weightKg: 70.0, heightCm: 0.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Throws ArgumentError for negative height or weight', () {
      expect(
        () => BMIService.calculateBMI(weightKg: -10.0, heightCm: 175.0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => BMIService.calculateBMI(weightKg: 70.0, heightCm: -175.0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Unit Conversion Tests', () {
    test('Metric to Imperial conversions (kg to lbs, cm to inches)', () {
      final lbs = BMIService.kgToLbs(70.0);
      expect(lbs, closeTo(154.3, 0.2));

      final kg = BMIService.lbsToKg(154.3);
      expect(kg, closeTo(70.0, 0.2));

      final inches = BMIService.cmToInches(175.0);
      expect(inches, closeTo(68.9, 0.2));

      final (feet, inch) = BMIService.cmToFeetAndInches(175.0);
      expect(feet, equals(5));
      expect(inch, equals(9));
    });

    test('Imperial BMI calculation (154.3 lbs, 5 ft 9 in)', () {
      final bmi = BMIService.calculateBMIImperial(
        weightLb: 154.3,
        heightFeet: 5,
        heightInches: 9,
      );
      expect(bmi, closeTo(22.8, 0.3));
      expect(BMIService.getCategory(bmi), equals(BMICategory.normal));
    });

    test('Gauge progress is normalized between 0.0 and 1.0', () {
      final lowProgress = BMIService.getGaugeProgress(12.0);
      expect(lowProgress, equals(0.0));

      final highProgress = BMIService.getGaugeProgress(38.0);
      expect(highProgress, equals(1.0));

      final midProgress = BMIService.getGaugeProgress(25.0);
      expect(midProgress, greaterThan(0.0));
      expect(midProgress, lessThan(1.0));
    });
  });
}
