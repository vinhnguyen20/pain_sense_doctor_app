import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registration payload matches UserCreate schema', () {
    const registration = PatientRegistration(
      email: 'patient@example.com',
      phone: '901234567',
      firstName: 'Pain',
      lastName: 'Sense',
      password: 'password',
    );

    expect(registration.toJson(), {
      'email': 'patient@example.com',
      'phone': '901234567',
      'country_code': '+84',
      'first_name': 'Pain',
      'last_name': 'Sense',
      'password': 'password',
    });
  });

  test('profile payload converts age and emergency contact', () {
    const profile = PatientProfileSetup(
      age: 30,
      emergencyContactName: 'Emergency Person',
      emergencyContactEmail: 'emergency@example.com',
      emergencyContactPhone: '987654321',
    );

    final json = profile.toUpdateJson(DateTime(2026, 8, 26));
    expect(json['birthdate'], '1996-01-01T00:00:00.000Z');
    expect(json['emergency_contact'], {
      'name': 'Emergency Person',
      'phone': '987654321',
      'country_code': '+84',
    });
  });
}
