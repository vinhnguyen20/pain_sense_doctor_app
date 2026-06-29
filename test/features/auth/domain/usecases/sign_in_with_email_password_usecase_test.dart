import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/auth/domain/entities/user.dart';
import 'package:app_doctor/features/auth/domain/repository/auth_repository.dart';
import 'package:app_doctor/features/auth/domain/usecases/sign_in_with_email_password_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  final ApiResponse<AuthToken> response;

  _FakeAuthRepository(this.response);

  @override
  Future<ApiResponse<AuthToken>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return response;
  }
}

void main() {
  test('returns failure response from repository without throwing', () async {
    final useCase = SignInWithEmailPasswordUseCase(
      _FakeAuthRepository(
        const ApiResponse<AuthToken>(code: -1, message: 'Connection refused'),
      ),
    );

    final result = await useCase('doctor@example.com', 'password');

    expect(result.isFailure, isTrue);
    expect(result.data, isNull);
    expect(result.message, 'Connection refused');
  });

  test('returns success response from repository', () async {
    const token = AuthToken(
      accessToken: 'access',
      refreshToken: 'refresh',
      customToken: 'custom',
    );

    final useCase = SignInWithEmailPasswordUseCase(
      _FakeAuthRepository(ApiResponse<AuthToken>.success(token)),
    );

    final result = await useCase('doctor@example.com', 'password');

    expect(result.isSuccess, isTrue);
    expect(result.data, token);
  });
}
