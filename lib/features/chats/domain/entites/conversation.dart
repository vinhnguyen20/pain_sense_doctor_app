import 'package:app_doctor/features/chats/domain/entites/un_read_info.dart';
import 'package:equatable/equatable.dart';
import 'last_message.dart';

class Conversation extends Equatable {
  final String id;
  final String name;
  final List<String> participants;
  final LastMessage? lastMessage;
  final String status;
  final int unreadCountDoctor;
  final int unreadCountPatient;
  final List<UnReadInfo> unreadInfo;

  const Conversation({
    required this.id,
    required this.participants,
    required this.name,
    this.lastMessage,
    required this.status,
    required this.unreadCountDoctor,
    required this.unreadInfo,
    required this.unreadCountPatient,
  });

  Conversation copyWith({
    String? id,
    List<String>? participants,
    String? name,
    LastMessage? lastMessage,
    String? status,
    int? unreadCountDoctor,
    int? unreadCountPatient,
    List<UnReadInfo>? unreadInfo,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      status: status ?? this.status,
      unreadCountDoctor: unreadCountDoctor ?? this.unreadCountDoctor,
      unreadCountPatient: unreadCountPatient ?? this.unreadCountPatient,
      unreadInfo: unreadInfo ?? this.unreadInfo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    participants,
    lastMessage,
    status,
    unreadCountDoctor,
    unreadCountPatient,
    unreadInfo,
  ];
}
