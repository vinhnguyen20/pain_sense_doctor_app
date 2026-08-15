import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/core/services/auth/token_service.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewState {
  final AuthState state;
  final String? errorMessage;
  final bool isLoading;

  const AuthViewState({
    required this.state,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthViewState copyWith({
    AuthState? state,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return AuthViewState(
      state: state ?? this.state,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => state == AuthState.authenticated;
  bool get isUnauthenticated => state == AuthState.unauthenticated;
  bool get hasError => state == AuthState.error;
  bool get isInitial => state == AuthState.initial;
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthViewState build() {
    _initialize();
    return const AuthViewState(state: AuthState.initial);
  }

  void _initialize() {
    ref.listen(tokenServiceProvider, (_, next) {
      next.when(
        data: (token) {
          if (state.isLoading) return;

          state = state.copyWith(
            state: token != null
                ? AuthState.authenticated
                : AuthState.unauthenticated,
          );

          FlutterNativeSplash.remove();
        },
        error: (_, __) {
          state = state.copyWith(state: AuthState.unauthenticated);
          FlutterNativeSplash.remove();
        },
        loading: () {},
      );
    });
  }

  Future<void> signInWithGoogle() async {}

  Future<void> signInWithEmailPassword(String email, String password) async {
    _clearError();
    _setLoading(true);

    try {
      final res = await ref
          .read(signInWithEmailPasswordUseCaseProvider)
          .call(email, password);

      if (res.data != null) {
        await ref
            .read(tokenServiceProvider.notifier)
            .saveTokens(
              accessToken: res.data!.accessToken,
              refreshToken: res.data!.refreshToken,
              customToken: res.data!.customToken ?? '',
            );
        state = state.copyWith(state: AuthState.authenticated);
      } else {
        state = state.copyWith(
          state: AuthState.error,
          errorMessage: res.message,
        );
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _clearError();
    _setLoading(true);

    try {
      await ref.read(tokenServiceProvider.notifier).clearTokens();

      state = state.copyWith(
        state: AuthState.unauthenticated,
        isLoading: false,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      if (state.isLoading) _setLoading(false);
    }
  }

  Future<String> getInitialRoute() async {
    try {
      final hasSession = await ref
          .read(tokenServiceProvider.notifier)
          .hasValidSession();

      if (hasSession) {
        state = state.copyWith(state: AuthState.authenticated);
        return '/home';
      }

      state = state.copyWith(state: AuthState.unauthenticated);
      return '/login';
    } catch (e) {
      return '/login';
    }
  }

  void forceLogout() {
    ref.read(tokenServiceProvider.notifier).clearTokens();
    state = state.copyWith(state: AuthState.unauthenticated, clearError: true);
  }

  void _setLoading(bool loading) {
    state = state.copyWith(
      isLoading: loading,
      state: loading ? AuthState.loading : state.state,
    );
  }

  void _clearError() {
    state = state.copyWith(clearError: true);
  }

  void _handleError(dynamic error) {
    final message = ExceptionHandler.handle(error).message;
    state = state.copyWith(
      errorMessage: message,
      state: AuthState.error,
      isLoading: false,
    );
    debugPrint('AuthNotifier Error: $error');
  }
}
