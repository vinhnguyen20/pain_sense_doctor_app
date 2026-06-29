import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const Color primaryTeal = Color(0xFF009688);
  static const Color secondaryMint = Color(0xFF03DAC6);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  static const Color chartBlue = Color(0xFF4285F4);
  static const Color chartViolet = Color(0xFF9C6FE4);
  static const Color chartPink = Color(0xFFE91E8C);

  static const Color tooltipDark = Color(0xFF2C2C2C);
}

abstract final class AppLightColors {
  static const Color primary = AppPalette.primaryTeal;
  static const Color secondary = AppPalette.secondaryMint;
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  static const Color border = Color(0xFFE0E0E0);
}

abstract final class AppDarkColors {
  static const Color primary = Color(0xFF4DB6AC);
  static const Color secondary = Color(0xFF80CBC4);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFCF6679);
  static const Color border = Color(0xFF2C2C2C);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color warning;
  final Color info;

  final Color chartPrimary;
  final Color chartSecondary;
  final Color chartTertiary;

  final Color tooltipBackground;
  final Color tooltipForeground;
  final Color scrim;
  final Color navShadow;

  final Color chatIncomingBubble;
  final Color chatIncomingText;
  final Color chatIncomingMeta;
  final Color chatReadReceipt;

  final Color neutralMuted;
  final Color neutralWeak;

  final Color voiceGradientStart;
  final Color voiceGradientEnd;
  final Color voiceOverlay;

  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.chartPrimary,
    required this.chartSecondary,
    required this.chartTertiary,
    required this.tooltipBackground,
    required this.tooltipForeground,
    required this.scrim,
    required this.navShadow,
    required this.chatIncomingBubble,
    required this.chatIncomingText,
    required this.chatIncomingMeta,
    required this.chatReadReceipt,
    required this.neutralMuted,
    required this.neutralWeak,
    required this.voiceGradientStart,
    required this.voiceGradientEnd,
    required this.voiceOverlay,
  });

  static const AppSemanticColors light = AppSemanticColors(
    success: AppPalette.success,
    warning: AppPalette.warning,
    info: AppPalette.info,
    chartPrimary: AppPalette.chartBlue,
    chartSecondary: AppPalette.chartViolet,
    chartTertiary: AppPalette.chartPink,
    tooltipBackground: AppPalette.tooltipDark,
    tooltipForeground: AppPalette.white,
    scrim: Color(0x66000000),
    navShadow: Color(0x11000000),
    chatIncomingBubble: Color(0xFFE5E7EB),
    chatIncomingText: Color(0xFF111827),
    chatIncomingMeta: Color(0xFF6B7280),
    chatReadReceipt: Color(0xFF93C5FD),
    neutralMuted: Color(0xFF9CA3AF),
    neutralWeak: Color(0xFFD1D5DB),
    voiceGradientStart: Color(0xFF6B8E23),
    voiceGradientEnd: Color(0xFF556B2F),
    voiceOverlay: Color(0x33FFFFFF),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    chartPrimary: AppPalette.chartBlue,
    chartSecondary: AppPalette.chartViolet,
    chartTertiary: AppPalette.chartPink,
    tooltipBackground: Color(0xFF111827),
    tooltipForeground: Color(0xFFE5E7EB),
    scrim: Color(0x80000000),
    navShadow: Color(0x33000000),
    chatIncomingBubble: Color(0xFF1F2937),
    chatIncomingText: Color(0xFFE5E7EB),
    chatIncomingMeta: Color(0xFF9CA3AF),
    chatReadReceipt: Color(0xFF60A5FA),
    neutralMuted: Color(0xFF9CA3AF),
    neutralWeak: Color(0xFF4B5563),
    voiceGradientStart: Color(0xFF6B8E23),
    voiceGradientEnd: Color(0xFF556B2F),
    voiceOverlay: Color(0x33FFFFFF),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? chartPrimary,
    Color? chartSecondary,
    Color? chartTertiary,
    Color? tooltipBackground,
    Color? tooltipForeground,
    Color? scrim,
    Color? navShadow,
    Color? chatIncomingBubble,
    Color? chatIncomingText,
    Color? chatIncomingMeta,
    Color? chatReadReceipt,
    Color? neutralMuted,
    Color? neutralWeak,
    Color? voiceGradientStart,
    Color? voiceGradientEnd,
    Color? voiceOverlay,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      chartPrimary: chartPrimary ?? this.chartPrimary,
      chartSecondary: chartSecondary ?? this.chartSecondary,
      chartTertiary: chartTertiary ?? this.chartTertiary,
      tooltipBackground: tooltipBackground ?? this.tooltipBackground,
      tooltipForeground: tooltipForeground ?? this.tooltipForeground,
      scrim: scrim ?? this.scrim,
      navShadow: navShadow ?? this.navShadow,
      chatIncomingBubble: chatIncomingBubble ?? this.chatIncomingBubble,
      chatIncomingText: chatIncomingText ?? this.chatIncomingText,
      chatIncomingMeta: chatIncomingMeta ?? this.chatIncomingMeta,
      chatReadReceipt: chatReadReceipt ?? this.chatReadReceipt,
      neutralMuted: neutralMuted ?? this.neutralMuted,
      neutralWeak: neutralWeak ?? this.neutralWeak,
      voiceGradientStart: voiceGradientStart ?? this.voiceGradientStart,
      voiceGradientEnd: voiceGradientEnd ?? this.voiceGradientEnd,
      voiceOverlay: voiceOverlay ?? this.voiceOverlay,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      chartPrimary: Color.lerp(chartPrimary, other.chartPrimary, t)!,
      chartSecondary: Color.lerp(chartSecondary, other.chartSecondary, t)!,
      chartTertiary: Color.lerp(chartTertiary, other.chartTertiary, t)!,
      tooltipBackground: Color.lerp(
        tooltipBackground,
        other.tooltipBackground,
        t,
      )!,
      tooltipForeground: Color.lerp(
        tooltipForeground,
        other.tooltipForeground,
        t,
      )!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      navShadow: Color.lerp(navShadow, other.navShadow, t)!,
      chatIncomingBubble: Color.lerp(
        chatIncomingBubble,
        other.chatIncomingBubble,
        t,
      )!,
      chatIncomingText: Color.lerp(
        chatIncomingText,
        other.chatIncomingText,
        t,
      )!,
      chatIncomingMeta: Color.lerp(
        chatIncomingMeta,
        other.chatIncomingMeta,
        t,
      )!,
      chatReadReceipt: Color.lerp(chatReadReceipt, other.chatReadReceipt, t)!,
      neutralMuted: Color.lerp(neutralMuted, other.neutralMuted, t)!,
      neutralWeak: Color.lerp(neutralWeak, other.neutralWeak, t)!,
      voiceGradientStart: Color.lerp(
        voiceGradientStart,
        other.voiceGradientStart,
        t,
      )!,
      voiceGradientEnd: Color.lerp(
        voiceGradientEnd,
        other.voiceGradientEnd,
        t,
      )!,
      voiceOverlay: Color.lerp(voiceOverlay, other.voiceOverlay, t)!,
    );
  }
}
