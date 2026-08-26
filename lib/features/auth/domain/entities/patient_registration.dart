class PatientRegistration {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String password;
  final String countryCode;

  const PatientRegistration({
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.countryCode = '+84',
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'phone': phone,
    'country_code': countryCode,
    'first_name': firstName,
    'last_name': lastName,
    'password': password,
  };
}

class PatientProfileSetup {
  final int age;
  final String emergencyContactName;
  final String emergencyContactEmail;
  final String emergencyContactPhone;
  final String countryCode;

  const PatientProfileSetup({
    required this.age,
    required this.emergencyContactName,
    required this.emergencyContactEmail,
    required this.emergencyContactPhone,
    this.countryCode = '+84',
  });

  Map<String, dynamic> toUpdateJson(DateTime now) {
    final birthYear = now.year - age;
    return {
      'birthdate': DateTime.utc(birthYear, 1, 1).toIso8601String(),
      'emergency_contact': {
        'name': emergencyContactName,
        'phone': emergencyContactPhone,
        'country_code': countryCode,
      },
    };
  }
}
