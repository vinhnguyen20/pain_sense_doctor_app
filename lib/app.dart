import 'package:app_doctor/common/widgets/responsive_app_viewport.dart';
import 'package:app_doctor/core/config/routers/router.dart';
import 'package:app_doctor/core/config/theme/app_theme.dart';
import 'package:app_doctor/core/providers/theme_notifier.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(ref);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider);
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.isAuthenticated),
    );

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Back Belt App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      builder: (context, child) => ResponsiveAppViewport(
        enabled: isAuthenticated,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
