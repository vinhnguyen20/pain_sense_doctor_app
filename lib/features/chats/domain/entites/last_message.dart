import 'package:equatable/equatable.dart';

class LastMessage extends Equatable {
  final String text;
  final DateTime sentAt;
  final String sendBy;

  const LastMessage({
    required this.text,
    required this.sentAt,
    required this.sendBy,
  });

  @override
  List<Object?> get props => [text, sentAt, sendBy];
}
