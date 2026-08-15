import 'package:app_doctor/core/providers/storage_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_service.g.dart';

@Riverpod(keepAlive: true)
class TokenService extends _$TokenService {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _customTokenKey = 'customToken';

  @override
  Future<String?> build() async {
    return _readAccessToken();
  }

  Future<String?> _readAccessToken() async {
    try {
      return await ref.read(secureStorageProvider).read(key: _accessTokenKey);
    } catch (e) {
      debugPrint('TokenService _readAccessToken error: $e');
      return null;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String customToken = '',
  }) async {
    final storage = ref.read(secureStorageProvider);
    await Future.wait([
      storage.write(key: _accessTokenKey, value: accessToken),
      storage.write(key: _customTokenKey, value: customToken),
      if (refreshToken != null)
        storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
    state = AsyncData(accessToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await ref
        .read(secureStorageProvider)
        .write(key: _accessTokenKey, value: accessToken);
    state = AsyncData(accessToken);
  }

  Future<void> clearTokens() async {
    await ref.read(secureStorageProvider).deleteAll();
    state = const AsyncData(null);
  }

  Future<String?> getAccessToken() => _readAccessToken();
  Future<String?> getRefreshToken() async {
    try {
      return await ref.read(secureStorageProvider).read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('TokenService getRefreshToken error: $e');
      return null;
    }
  }

  Future<String?> getCustomToken() async {
    try {
      return await ref.read(secureStorageProvider).read(key: _customTokenKey);
    } catch (e) {
      debugPrint('TokenService getCustomToken error: $e');
      return null;
    }
  }

  Future<bool> hasValidSession() async {
    final token = await _readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
