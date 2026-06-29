import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/core/services/auth/token_service.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_notifier.g.dart';

class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({User? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

//  NOTIFIER

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  static const Duration _cacheTtl = Duration(seconds: 45);
  DateTime? _lastFetchedAt;
  String? _lastAccessToken;

  bool get _isCacheFresh {
    final lastFetchedAt = _lastFetchedAt;
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  @override
  UserState build() {
    ref.listen(tokenServiceProvider, (_, next) {
      next.when(
        data: (token) {
          if (token != null) {
            final shouldForceRefresh = token != _lastAccessToken;
            _lastAccessToken = token;
            getCurrentUser(forceRefresh: shouldForceRefresh);
          } else {
            _lastAccessToken = null;
            clearUser();
          }
        },
        loading: () {},
        error: (e, _) {
          _lastAccessToken = null;
          clearUser();
        },
      );
    });

    return const UserState();
  }

  Future<void> getCurrentUser({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.user != null && _isCacheFresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ref.read(getCurrentUserUseCaseProvider).call();

      if (response.isSuccess) {
        _lastFetchedAt = DateTime.now();
        state = state.copyWith(user: response.data, isLoading: false);
      } else {
        _lastFetchedAt = null;
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      _lastFetchedAt = null;
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: ExceptionHandler.handle(e).message,
      );
    }
  }

  void clearUser() {
    _lastFetchedAt = null;
    state = const UserState();
  }
}
