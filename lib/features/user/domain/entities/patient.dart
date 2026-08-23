import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:json_annotation/json_annotation.dart';

class Patient extends User {
  final TrackingLogs? trackingLogs;
  final String? painType;

  const Patient({
    required super.id,
    super.email,
    super.phone,
    super.countryCode,
    super.firstName,
    super.lastName,
    super.address,
    super.birthdate,
    super.gender,
    super.emergencyContact,
    super.status,
    this.trackingLogs,
    this.painType,
  });

  @override
  Patient copyWith({
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
    UserStatus? status,
    TrackingLogs? trackingLogs,
    String? painType,
    DateTime? createdAt,
    AuthInfo? authInfo,
  }) {
    return Patient(
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
      status: status ?? this.status,
      trackingLogs: trackingLogs ?? this.trackingLogs,
      painType: painType ?? this.painType,
    );
  }

  @override
  List<Object?> get props => [...super.props, trackingLogs, painType];
}

class TrackingLogs extends Equatable {
  final String? lbpScore;
  final String? status;
  final String? color;

  const TrackingLogs({this.lbpScore, this.status, this.color});

  int? get lbpScoreValue {
    if (lbpScore == null || lbpScore == 'N/A' || lbpScore!.isEmpty) return null;
    final score = int.tryParse(lbpScore!.split('/').first);
    if (score == null || score < 0) return null;
    return score;
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  Color? get scoreColor {
    final colorHex = color;
    if (colorHex == null || lbpScoreValue == null) return null;
    final raw = colorHex.replaceFirst('#', '0xFF');
    final value = int.tryParse(raw);
    if (value == null) return null;
    return Color(value);
  }

  @override
  List<Object?> get props => [lbpScore, status, color];
}
