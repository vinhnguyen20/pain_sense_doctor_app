import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';

class GetAllPatientsUseCase {
  final UserRepository _userRepository;

  GetAllPatientsUseCase(this._userRepository);

  Future<ApiResponse<PaginatedResponse<Patient>>> call({
    String? cursor,
    int? limit,
    String? search,
  }) async {
    return await _userRepository.getAllPatients(
      cursor: cursor,
      limit: limit,
      search: search,
    );
  }
}
