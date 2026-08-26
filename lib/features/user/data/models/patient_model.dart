import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/user/data/models/user_model.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patient_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PatientModel extends Patient
    with EntityConvertible<PatientModel, Patient> {
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

  @JsonKey(name: 'avatar_url')
  @override
  final String? avatarUrl;

  @JsonKey(name: 'facebook_id')
  @override
  final String? facebookId;

  @JsonKey(name: 'gmail_id')
  @override
  final String? gmailId;

  @JsonKey(name: 'apple_id')
  @override
  final String? appleId;

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

  @JsonKey(name: 'tracking_logs')
  @override
  final TrackingLogsModel? trackingLogs;

  @JsonKey(name: 'pain_type')
  @override
  final String? painType;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  AuthInfo? get authInfo => null;

  const PatientModel({
    required this.id,
    this.email,
    this.phone,
    this.countryCode,
    this.firstName,
    this.lastName,
    this.address,
    this.avatarUrl,
    this.facebookId,
    this.gmailId,
    this.appleId,
    this.birthdate,
    this.gender,
    this.emergencyContact,
    this.status,
    this.trackingLogs,
    this.painType,
  }) : super(
         id: id,
         email: email,
         phone: phone,
         countryCode: countryCode,
         firstName: firstName,
         lastName: lastName,
         address: address,
         avatarUrl: avatarUrl,
         facebookId: facebookId,
         gmailId: gmailId,
         appleId: appleId,
         birthdate: birthdate,
         gender: gender,
         emergencyContact: emergencyContact,
         status: status,
         trackingLogs: trackingLogs,
         painType: painType,
       );

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientModelToJson(this);

  @override
  Patient toEntity() {
    return Patient(
      id: id,
      email: email,
      phone: phone,
      countryCode: countryCode,
      firstName: firstName,
      lastName: lastName,
      address: address,
      avatarUrl: avatarUrl,
      facebookId: facebookId,
      gmailId: gmailId,
      appleId: appleId,
      birthdate: birthdate,
      gender: gender,
      emergencyContact: emergencyContact?.toEntity(),
      status: status,
      trackingLogs: trackingLogs?.toEntity(),
      painType: painType,
    );
  }

  factory PatientModel.fromEntity(Patient entity) {
    return PatientModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      countryCode: entity.countryCode,
      firstName: entity.firstName,
      lastName: entity.lastName,
      address: entity.address,
      avatarUrl: entity.avatarUrl,
      facebookId: entity.facebookId,
      gmailId: entity.gmailId,
      appleId: entity.appleId,
      birthdate: entity.birthdate,
      gender: entity.gender,
      emergencyContact: entity.emergencyContact != null
          ? EmergencyContactModel.fromEntity(entity.emergencyContact!)
          : null,
      status: entity.status,
      trackingLogs: entity.trackingLogs != null
          ? TrackingLogsModel.fromEntity(entity.trackingLogs!)
          : null,
      painType: entity.painType,
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
class TrackingLogsModel extends TrackingLogs
    with EntityConvertible<TrackingLogsModel, TrackingLogs> {
  @JsonKey(name: 'lbp_score')
  @override
  final String? lbpScore;

  @JsonKey(name: 'status')
  @override
  final String? status;

  @JsonKey(name: 'color')
  @override
  final String? color;

  const TrackingLogsModel({this.lbpScore, this.status, this.color})
    : super(lbpScore: lbpScore, status: status, color: color);

  factory TrackingLogsModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingLogsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingLogsModelToJson(this);

  @override
  TrackingLogs toEntity() =>
      TrackingLogs(lbpScore: lbpScore, status: status, color: color);

  factory TrackingLogsModel.fromEntity(TrackingLogs entity) =>
      TrackingLogsModel(
        lbpScore: entity.lbpScore,
        status: entity.status,
        color: entity.color,
      );
}
