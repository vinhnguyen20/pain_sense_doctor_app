import 'package:equatable/equatable.dart';

class UnReadInfo extends Equatable {
  final String userId;
  final int count;
  final DateTime? lastReadAt;

  const UnReadInfo({
    required this.userId,
    required this.count,
    this.lastReadAt,
  });

  @override
  List<Object?> get props => [userId, count, lastReadAt];
}
