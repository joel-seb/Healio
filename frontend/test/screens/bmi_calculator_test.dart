import 'package:flutter_test/flutter_test.dart';

// Pure functions extracted from BMICalculatorScreen._calculateCurrentBMI()
// and ._categorizeBMI() for isolated unit testing.

double calculateBMI(double weightKg, double heightCm) {
  if (weightKg <= 0 || heightCm <= 0) return 0;
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

String categorizeBMI(double bmi) {
  if (bmi < 16)    return 'Severely Underweight';
  if (bmi < 18.5)  return 'Underweight';
  if (bmi < 25)    return 'Normal';
  if (bmi < 30)    return 'Overweight';
  return 'Obese';
}

void main() {
  group('calculateBMI', () {
    test('returns 0 for zero weight', () {
      expect(calculateBMI(0, 175), 0);
    });

    test('returns 0 for zero height', () {
      expect(calculateBMI(70, 0), 0);
    });

    test('computes correct BMI for standard values (70 kg, 175 cm → ~22.86)', () {
      final bmi = calculateBMI(70, 175);
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('computes correct BMI for lightweight case (50 kg, 170 cm → ~17.30)', () {
      final bmi = calculateBMI(50, 170);
      expect(bmi, closeTo(17.30, 0.01));
    });

    test('computes correct BMI for overweight case (90 kg, 170 cm → ~31.14)', () {
      final bmi = calculateBMI(90, 170);
      expect(bmi, closeTo(31.14, 0.01));
    });
  });

  group('categorizeBMI', () {
    test('below 16 → Severely Underweight', () {
      expect(categorizeBMI(14.0), 'Severely Underweight');
      expect(categorizeBMI(15.9), 'Severely Underweight');
    });

    test('16–18.49 → Underweight', () {
      expect(categorizeBMI(16.0), 'Underweight');
      expect(categorizeBMI(18.4), 'Underweight');
    });

    test('18.5–24.99 → Normal', () {
      expect(categorizeBMI(18.5), 'Normal');
      expect(categorizeBMI(22.0), 'Normal');
      expect(categorizeBMI(24.9), 'Normal');
    });

    test('25–29.99 → Overweight', () {
      expect(categorizeBMI(25.0), 'Overweight');
      expect(categorizeBMI(27.5), 'Overweight');
      expect(categorizeBMI(29.9), 'Overweight');
    });

    test('30 and above → Obese', () {
      expect(categorizeBMI(30.0), 'Obese');
      expect(categorizeBMI(40.0), 'Obese');
    });

    test('boundary: exactly 25.0 is Overweight, not Normal', () {
      expect(categorizeBMI(25.0), 'Overweight');
    });

    test('boundary: exactly 18.5 is Normal, not Underweight', () {
      expect(categorizeBMI(18.5), 'Normal');
    });
  });

  group('calculateBMI + categorizeBMI integration', () {
    test('70 kg / 175 cm is Normal', () {
      expect(categorizeBMI(calculateBMI(70, 175)), 'Normal');
    });

    test('50 kg / 170 cm is Underweight', () {
      expect(categorizeBMI(calculateBMI(50, 170)), 'Underweight');
    });

    test('100 kg / 170 cm is Obese', () {
      expect(categorizeBMI(calculateBMI(100, 170)), 'Obese');
    });

    test('85 kg / 175 cm is Overweight', () {
      expect(categorizeBMI(calculateBMI(85, 175)), 'Overweight');
    });
  });
}
