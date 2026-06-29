import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends User with EntityConvertible<UserModel, User> {
  @JsonKey(name: 'id')
  @override
  final String id;

  @JsonKey(name: 'email')
  @override
  final String? email;

  @JsonKey(name: 'phone')
  @override
  final String? phone;

  @JsonKey(name: 'country_code')
  @override
  final String? countryCode;

  @JsonKey(name: 'first_name')
  @override
  final String? firstName;

  @JsonKey(name: 'last_name')
  @override
  final String? lastName;

  @JsonKey(name: 'address')
  @override
  final String? address;

  @JsonKey(name: 'birthdate')
  @override
  final String? birthdate;

  @JsonKey(name: 'gender', fromJson: _genderFromJson, toJson: _genderToJson)
  @override
  final Gender? gender;

  @JsonKey(name: 'emergency_contact')
  @override
  final EmergencyContactModel? emergencyContact;

  @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)
  @override
  final UserStatus? status;

  const UserModel({
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
    this.status,
  }) : super(
         id: id,
         email: email,
         phone: phone,
         countryCode: countryCode,
         firstName: firstName,
         lastName: lastName,
         address: address,
         birthdate: birthdate,
         gender: gender,
         emergencyContact: emergencyContact,
         status: status,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  User toEntity() {
    return User(
      id: id,
      email: email,
      phone: phone,
      countryCode: countryCode,
      firstName: firstName,
      lastName: lastName,
      address: address,
      birthdate: birthdate,
      gender: gender,
      emergencyContact: emergencyContact?.toEntity(),
      status: status,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      countryCode: entity.countryCode,
      firstName: entity.firstName,
      lastName: entity.lastName,
      address: entity.address,
      birthdate: entity.birthdate,
      gender: entity.gender,
      emergencyContact: entity.emergencyContact != null
          ? EmergencyContactModel.fromEntity(entity.emergencyContact!)
          : null,
      status: entity.status,
    );
  }

  static Gender? _genderFromJson(String? gender) =>
      gender != null ? Gender.fromString(gender) : null;
  static String? _genderToJson(Gender? gender) => gender?.name;

  static UserStatus? _statusFromJson(String? status) =>
      status != null ? UserStatus.fromString(status) : null;
  static String? _statusToJson(UserStatus? status) => status?.name;
}

@JsonSerializable()
class EmergencyContactModel extends EmergencyContact
    with EntityConvertible<EmergencyContactModel, EmergencyContact> {
  @JsonKey(name: 'country_code')
  @override
  final String countryCode;

  const EmergencyContactModel({
    required super.name,
    required super.phone,
    required this.countryCode,
  }) : super(countryCode: countryCode);

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactModelToJson(this);

  @override
  EmergencyContact toEntity() =>
      EmergencyContact(name: name, phone: phone, countryCode: countryCode);

  factory EmergencyContactModel.fromEntity(EmergencyContact entity) =>
      EmergencyContactModel(
        name: entity.name,
        phone: entity.phone,
        countryCode: entity.countryCode,
      );
}
