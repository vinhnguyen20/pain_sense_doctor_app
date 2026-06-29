import 'package:equatable/equatable.dart';

class UserFeedback extends Equatable {
  final String? comment;
  final String status;

  const UserFeedback({this.comment, required this.status});

  @override
  List<Object?> get props => [comment, status];
}
