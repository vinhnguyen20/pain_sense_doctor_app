import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String title;
  final String description;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String createdBy;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? meetingLink;
  final bool isSent;
  final AppointmentSchedule schedule;
  final MeetingMeta? meetingMeta;
  final DateTime? createdAt;

  const Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.createdBy,
    required this.type,
    required this.status,
    this.meetingLink,
    required this.isSent,
    required this.schedule,
    this.meetingMeta,
    this.createdAt,
  });

  Appointment copyWith({
    String? id,
    String? title,
    String? description,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? createdBy,
    AppointmentType? type,
    AppointmentStatus? status,
    String? meetingLink,
    bool? isSent,
    AppointmentSchedule? schedule,
    MeetingMeta? meetingMeta,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      status: status ?? this.status,
      meetingLink: meetingLink ?? this.meetingLink,
      isSent: isSent ?? this.isSent,
      schedule: schedule ?? this.schedule,
      meetingMeta: meetingMeta ?? this.meetingMeta,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    patientId,
    patientName,
    doctorId,
    doctorName,
    createdBy,
    type,
    status,
    meetingLink,
    isSent,
    schedule,
    meetingMeta,
    createdAt,
  ];
}

class AppointmentSchedule extends Equatable {
  final String date;
  final String startTime;
  final String endTime;
  final String timezone;

  const AppointmentSchedule({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.timezone,
  });

  @override
  List<Object?> get props => [date, startTime, endTime, timezone];
}

class MeetingMeta extends Equatable {
  final String? accessToken;
  final String? roomId;
  final String? recordingUrl;

  const MeetingMeta({this.accessToken, this.roomId, this.recordingUrl});

  @override
  List<Object?> get props => [accessToken, roomId, recordingUrl];
}

enum AppointmentType {
  videoCall,
  inPerson;

  static AppointmentType fromString(String value) {
    return AppointmentType.values.firstWhere(
      (e) => e.name == _toCamelCase(value),
      orElse: () => AppointmentType.videoCall,
    );
  }

  static String _toCamelCase(String value) {
    final parts = value.split('_');
    if (parts.length == 1) return parts[0].toLowerCase();
    return parts[0].toLowerCase() +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  static AppointmentStatus fromInt(int value) {
    const map = {
      0: AppointmentStatus.pending,
      1: AppointmentStatus.confirmed,
      2: AppointmentStatus.cancelled,
      3: AppointmentStatus.completed,
    };
    return map[value] ?? AppointmentStatus.pending;
  }

  static AppointmentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'pending':
      case 'scheduled':
      default:
        return AppointmentStatus.pending;
    }
  }

  static AppointmentStatus fromDynamic(dynamic value) {
    if (value is int) return fromInt(value);
    if (value is String) return fromString(value);
    return AppointmentStatus.pending;
  }

  int toInt() {
    const map = {
      AppointmentStatus.pending: 0,
      AppointmentStatus.confirmed: 1,
      AppointmentStatus.cancelled: 2,
      AppointmentStatus.completed: 3,
    };
    return map[this]!;
  }
}
