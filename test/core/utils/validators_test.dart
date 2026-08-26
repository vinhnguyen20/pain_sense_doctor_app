import 'package:app_doctor/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppValidators', () {
    group('validateEmail', () {
      test('rejects empty or null', () {
        expect(AppValidators.validateEmail(null), isNotNull);
        expect(AppValidators.validateEmail(''), isNotNull);
        expect(AppValidators.validateEmail('   '), isNotNull);
      });

      test('rejects invalid email formats', () {
        expect(AppValidators.validateEmail('invalid'), isNotNull);
        expect(AppValidators.validateEmail('invalid@'), isNotNull);
        expect(AppValidators.validateEmail('@invalid.com'), isNotNull);
        expect(AppValidators.validateEmail('user@.com'), isNotNull);
        expect(AppValidators.validateEmail('user@domain'), isNotNull);
        expect(AppValidators.validateEmail('user@domain.'), isNotNull);
        expect(AppValidators.validateEmail('user space@domain.com'), isNotNull);
      });

      test('accepts valid email formats', () {
        expect(AppValidators.validateEmail('john.doe@example.com'), isNull);
        expect(AppValidators.validateEmail('user+tag@domain.co.uk'), isNull);
        expect(AppValidators.validateEmail('doctor123@hospital.org'), isNull);
      });
    });

    group('validatePhone', () {
      test('rejects empty or null', () {
        expect(AppValidators.validatePhone(null), isNotNull);
        expect(AppValidators.validatePhone(''), isNotNull);
      });

      test('rejects alphabetic or invalid symbols', () {
        expect(AppValidators.validatePhone('1234abc567'), isNotNull);
        expect(AppValidators.validatePhone('phone#123'), isNotNull);
      });

      test('rejects numbers that are too short or too long', () {
        expect(AppValidators.validatePhone('12345'), isNotNull);
        expect(AppValidators.validatePhone('12345678901234567890'), isNotNull);
      });

      test('accepts valid phone numbers in various standard formats', () {
        expect(AppValidators.validatePhone('0901234567'), isNull);
        expect(AppValidators.validatePhone('+84901234567'), isNull);
        expect(AppValidators.validatePhone('+1 (888) 462-5539'), isNull);
        expect(AppValidators.validatePhone('123-456-7890'), isNull);
      });
    });

    group('validateName', () {
      test('rejects empty or null', () {
        expect(AppValidators.validateName(null), isNotNull);
        expect(AppValidators.validateName(''), isNotNull);
      });

      test('rejects single character', () {
        expect(AppValidators.validateName('A'), isNotNull);
      });

      test('rejects names with numbers or forbidden special characters', () {
        expect(AppValidators.validateName('John2'), isNotNull);
        expect(AppValidators.validateName('Jane@Doe'), isNotNull);
      });

      test('accepts valid names including Unicode Vietnamese characters', () {
        expect(AppValidators.validateName('John Doe'), isNull);
        expect(AppValidators.validateName("O'Connor"), isNull);
        expect(AppValidators.validateName('Mary-Jane'), isNull);
        expect(AppValidators.validateName('Nguyễn Văn A'), isNull);
        expect(AppValidators.validateName('Trần Thị Bích'), isNull);
      });
    });

    group('validatePassword and validateConfirmPassword', () {
      test('rejects short passwords', () {
        expect(AppValidators.validatePassword('12345'), isNotNull);
      });

      test('accepts passwords >= 6 characters', () {
        expect(AppValidators.validatePassword('123456'), isNull);
        expect(AppValidators.validatePassword('secretPass!'), isNull);
      });

      test('validates matching confirmation password', () {
        expect(
          AppValidators.validateConfirmPassword('pass123', 'pass123'),
          isNull,
        );
        expect(
          AppValidators.validateConfirmPassword('pass123', 'different'),
          isNotNull,
        );
      });
    });

    group('validateAge', () {
      test('rejects empty, non-numbers, <= 0 or > 120', () {
        expect(AppValidators.validateAge(null), isNotNull);
        expect(AppValidators.validateAge('abc'), isNotNull);
        expect(AppValidators.validateAge('0'), isNotNull);
        expect(AppValidators.validateAge('-5'), isNotNull);
        expect(AppValidators.validateAge('150'), isNotNull);
      });

      test('accepts valid age', () {
        expect(AppValidators.validateAge('25'), isNull);
        expect(AppValidators.validateAge('1'), isNull);
        expect(AppValidators.validateAge('120'), isNull);
      });
    });
  });
}
