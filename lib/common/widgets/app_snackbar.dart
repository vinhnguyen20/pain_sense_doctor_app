import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

enum SnackbarType { error, success, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = _resolveColors(context, type);
    final icon = _resolveIcon(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: colors.foreground, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: context.bodyMedium?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static void error(BuildContext context, String message) =>
      show(context, message, type: SnackbarType.error);

  static void success(BuildContext context, String message) =>
      show(context, message, type: SnackbarType.success);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: SnackbarType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, type: SnackbarType.info);
}

class _SnackbarColors {
  final Color background;
  final Color foreground;
  const _SnackbarColors({required this.background, required this.foreground});
}

_SnackbarColors _resolveColors(BuildContext context, SnackbarType type) {
  return switch (type) {
    SnackbarType.error => const _SnackbarColors(
      background: Color(0xFFFEF2F2),
      foreground: Color(0xFFDC2626),
    ),
    SnackbarType.success => const _SnackbarColors(
      background: Color(0xFFF0FDF4),
      foreground: Color(0xFF16A34A),
    ),
    SnackbarType.warning => const _SnackbarColors(
      background: Color(0xFFFFFBEB),
      foreground: Color(0xFFD97706),
    ),
    SnackbarType.info => const _SnackbarColors(
      background: Color(0xFFEFF6FF),
      foreground: Color(0xFF2563EB),
    ),
  };
}

IconData _resolveIcon(SnackbarType type) {
  return switch (type) {
    SnackbarType.error => Icons.error_outline_rounded,
    SnackbarType.success => Icons.check_circle_outline_rounded,
    SnackbarType.warning => Icons.warning_amber_rounded,
    SnackbarType.info => Icons.info_outline_rounded,
  };
}
