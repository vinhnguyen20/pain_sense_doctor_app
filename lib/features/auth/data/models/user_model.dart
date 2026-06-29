import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthTokenModel extends AuthToken
    with EntityConvertible<AuthTokenModel, AuthToken> {
  @JsonKey(name: 'access_token')
  @override
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  @override
  final String refreshToken;

  @JsonKey(name: 'custom_token')
  @override
  final String? customToken;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.customToken,
  }) : super(
         accessToken: accessToken,
         refreshToken: refreshToken,
         customToken: customToken,
       );

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  @override
  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      customToken: customToken,
    );
  }

  factory AuthTokenModel.fromEntity(AuthToken entity) {
    return AuthTokenModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      customToken: entity.customToken,
    );
  }
}
