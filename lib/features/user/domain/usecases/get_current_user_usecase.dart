import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';

class GetCurrentUserUseCase {
  final UserRepository _userRepository;

  GetCurrentUserUseCase(this._userRepository);

  Future<ApiResponse<User?>> call() async {
    return await _userRepository.getCurrentUser();
  }
}
