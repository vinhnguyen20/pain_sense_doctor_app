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
