import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appointment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AppointmentModel extends Appointment
    with EntityConvertible<AppointmentModel, Appointment> {
  @JsonKey(name: 'id')
  @override
  final String id;

  @JsonKey(name: 'title')
  @override
  final String title;

  @JsonKey(name: 'description')
  @override
  final String description;

  @JsonKey(name: 'patient_id')
  @override
  final String patientId;

  @JsonKey(name: 'patient_name', defaultValue: '')
  @override
  final String patientName;

  @JsonKey(name: 'doctor_id')
  @override
  final String doctorId;

  @JsonKey(name: 'doctor_name', defaultValue: '')
  @override
  final String doctorName;

  @JsonKey(name: 'created_by', defaultValue: '')
  @override
  final String createdBy;

  @JsonKey(name: 'type', fromJson: _typeFromJson, toJson: _typeToJson)
  @override
  final AppointmentType type;

  @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)
  @override
  final AppointmentStatus status;

  @JsonKey(name: 'meeting_link')
  @override
  final String? meetingLink;

  @JsonKey(name: 'is_sent')
  @override
  final bool isSent;

  @JsonKey(name: 'schedule')
  @override
  final AppointmentScheduleModel schedule;

  @JsonKey(name: 'meeting_meta')
  @override
  final MeetingMetaModel? meetingMeta;

  @JsonKey(name: 'created_at')
  @override
  final DateTime? createdAt;

  const AppointmentModel({
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
  }) : super(
         id: id,
         title: title,
         description: description,
         patientId: patientId,
         patientName: patientName,
         doctorId: doctorId,
         doctorName: doctorName,
         createdBy: createdBy,
         type: type,
         status: status,
         meetingLink: meetingLink,
         isSent: isSent,
         schedule: schedule,
         meetingMeta: meetingMeta,
         createdAt: createdAt,
       );

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  @override
  Appointment toEntity() {
    return Appointment(
      id: id,
      title: title,
      description: description,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      createdBy: createdBy,
      type: type,
      status: status,
      meetingLink: meetingLink,
      isSent: isSent,
      schedule: schedule.toEntity(),
      meetingMeta: meetingMeta?.toEntity(),
      createdAt: createdAt,
    );
  }

  factory AppointmentModel.fromEntity(Appointment entity) {
    return AppointmentModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      patientId: entity.patientId,
      patientName: entity.patientName,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      createdBy: entity.createdBy,
      type: entity.type,
      status: entity.status,
      meetingLink: entity.meetingLink,
      isSent: entity.isSent,
      schedule: AppointmentScheduleModel.fromEntity(entity.schedule),
      meetingMeta: entity.meetingMeta != null
          ? MeetingMetaModel.fromEntity(entity.meetingMeta!)
          : null,
      createdAt: entity.createdAt,
    );
  }

  static AppointmentType _typeFromJson(String value) =>
      AppointmentType.fromString(value);
  static String _typeToJson(AppointmentType type) {
    // video_call, in_person
    return type.name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
  }

  static AppointmentStatus _statusFromJson(dynamic value) =>
      AppointmentStatus.fromDynamic(value);
  static int _statusToJson(AppointmentStatus status) => status.toInt();
}

@JsonSerializable()
class AppointmentScheduleModel extends AppointmentSchedule
    with EntityConvertible<AppointmentScheduleModel, AppointmentSchedule> {
  @JsonKey(name: 'date')
  @override
  final String date;

  @JsonKey(name: 'start_time')
  @override
  final String startTime;

  @JsonKey(name: 'end_time')
  @override
  final String endTime;

  @JsonKey(name: 'timezone')
  @override
  final String timezone;

  const AppointmentScheduleModel({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.timezone,
  }) : super(
         date: date,
         startTime: startTime,
         endTime: endTime,
         timezone: timezone,
       );

  factory AppointmentScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentScheduleModelToJson(this);

  @override
  AppointmentSchedule toEntity() => AppointmentSchedule(
    date: date,
    startTime: startTime,
    endTime: endTime,
    timezone: timezone,
  );

  factory AppointmentScheduleModel.fromEntity(AppointmentSchedule entity) =>
      AppointmentScheduleModel(
        date: entity.date,
        startTime: entity.startTime,
        endTime: entity.endTime,
        timezone: entity.timezone,
      );
}

@JsonSerializable()
class MeetingMetaModel extends MeetingMeta
    with EntityConvertible<MeetingMetaModel, MeetingMeta> {
  @JsonKey(name: 'access_token')
  @override
  final String? accessToken;

  @JsonKey(name: 'room_id')
  @override
  final String? roomId;

  @JsonKey(name: 'recording_url')
  @override
  final String? recordingUrl;

  const MeetingMetaModel({this.accessToken, this.roomId, this.recordingUrl})
    : super(
        accessToken: accessToken,
        roomId: roomId,
        recordingUrl: recordingUrl,
      );

  factory MeetingMetaModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingMetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingMetaModelToJson(this);

  @override
  MeetingMeta toEntity() => MeetingMeta(
    accessToken: accessToken,
    roomId: roomId,
    recordingUrl: recordingUrl,
  );

  factory MeetingMetaModel.fromEntity(MeetingMeta entity) => MeetingMetaModel(
    accessToken: entity.accessToken,
    roomId: entity.roomId,
    recordingUrl: entity.recordingUrl,
  );
}
