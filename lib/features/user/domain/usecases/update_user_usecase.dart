import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<ApiResponse<User>> call(User user) async {
    final updatedUser = user;
    return await _repository.updateUser(updatedUser);
  }
}
