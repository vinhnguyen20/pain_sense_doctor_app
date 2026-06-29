import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  static const String firstLaunch = 'first_launch';
}

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _prefs.setBool(StorageKeys.firstLaunch, isFirstLaunch);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(StorageKeys.firstLaunch) ?? true;
  }

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

class LocalStorageException implements Exception {
  final String message;

  const LocalStorageException(this.message);

  @override
  String toString() => 'LocalStorageException: $message';
}
