import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/auth/domain/entities/user.dart';
import 'package:app_doctor/features/auth/domain/repository/auth_repository.dart';

class SignInWithEmailPasswordUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailPasswordUseCase(this._authRepository);

  Future<ApiResponse<AuthToken>> call(String email, String password) async {
    return _authRepository.signInWithEmailPassword(email, password);
  }
}
