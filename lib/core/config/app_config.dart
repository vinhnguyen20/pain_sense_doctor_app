import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String _readEnv(String key) => dotenv.env[key]?.trim() ?? '';

  static String get baseUrl {
    final baseUrl = _readEnv('BASE_URL');
    return baseUrl.isNotEmpty ? baseUrl : 'http://52.220.128.244:8001';
  }

  static String get apiUrl => '$baseUrl/api/v1';
  static String get socketUrl => baseUrl;
}
