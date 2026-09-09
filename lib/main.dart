import 'package:app_doctor/core/config/app_config.dart';
import 'package:app_doctor/core/providers/storage_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Use a non-hidden asset so static hosts such as Netlify do not omit it.
    await dotenv.load(fileName: "app.env");
  } catch (e) {
    debugPrint("Warning: app.env file not found.");
  }

  if (kDebugMode) {
    debugPrint('[API_CONFIG] API_URL=${AppConfig.apiUrl}');
  }

  tz.initializeTimeZones();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
