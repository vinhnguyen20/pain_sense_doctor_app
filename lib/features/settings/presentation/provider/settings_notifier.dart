import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

class SettingsState {
  final bool isLoading;
  final DateTime? birthdate;

  const SettingsState({this.isLoading = false, this.birthdate});

  SettingsState copyWith({bool? isLoading, DateTime? birthdate}) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      birthdate: birthdate ?? this.birthdate,
    );
  }
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    final user = ref.watch(userProvider).user;
    return SettingsState(birthdate: _parseBirthdate(user?.birthdate));
  }

  DateTime? _parseBirthdate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  void setBirthdate(DateTime? date) {
    state = state.copyWith(birthdate: date);
  }

  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String emergencyName,
    required String emergencyPhone,
  }) async {
    final currentUser = ref.read(userProvider).user;
    if (currentUser == null) return 'User not found';

    state = state.copyWith(isLoading: true);

    try {
      final updated = currentUser.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        birthdate: state.birthdate?.toIso8601String() ?? currentUser.birthdate,
        emergencyContact: EmergencyContact(
          name: emergencyName.trim(),
          phone: emergencyPhone.trim(),
          countryCode: currentUser.emergencyContact?.countryCode ?? '',
        ),
      );

      final response = await ref.read(updateUserUseCaseProvider).call(updated);

      if (response.isSuccess) {
        await ref
            .read(userProvider.notifier)
            .getCurrentUser(forceRefresh: true);
        return null;
      }

      return response.message;
    } catch (e) {
      return ExceptionHandler.handle(e).message;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
