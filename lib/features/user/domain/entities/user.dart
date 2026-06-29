import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String? countryCode;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? birthdate;
  final Gender? gender;
  final EmergencyContact? emergencyContact;
  final DateTime? createdAt;
  final UserStatus? status;
  final AuthInfo? authInfo;

  const User({
    required this.id,
    this.email,
    this.phone,
    this.countryCode,
    this.firstName,
    this.lastName,
    this.address,
    this.birthdate,
    this.gender,
    this.emergencyContact,
    this.createdAt,
    this.status,
    this.authInfo,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  int? get age {
    if (birthdate == null || birthdate!.isEmpty) return null;
    final dob = DateTime.tryParse(birthdate!);
    if (dob == null) return null;
    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? countryCode,
    String? firstName,
    String? lastName,
    String? address,
    String? birthdate,
    Gender? gender,
    EmergencyContact? emergencyContact,
    DateTime? createdAt,
    UserStatus? status,
    AuthInfo? authInfo,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      authInfo: authInfo ?? this.authInfo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    countryCode,
    firstName,
    lastName,
    address,
    birthdate,
    gender,
    emergencyContact,
    createdAt,
    status,
    authInfo,
  ];
}

class AuthInfo extends Equatable {
  final UserRole role;

  const AuthInfo({required this.role});

  @override
  List<Object?> get props => [role];
}

class EmergencyContact extends Equatable {
  final String name;
  final String phone;
  final String countryCode;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.countryCode,
  });

  @override
  List<Object?> get props => [name, phone, countryCode];
}

enum UserRole {
  patient,
  doctor;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserRole.patient,
    );
  }
}

enum Gender {
  male,
  female,
  other;

  static Gender? fromString(String? value) {
    if (value == null) return null;
    return Gender.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Gender.other,
    );
  }
}

enum UserStatus {
  active,
  inactive,
  suspended,
  deleted;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserStatus.inactive,
    );
  }
}
