import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String? customToken;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.customToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, customToken];
}
