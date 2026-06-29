import 'package:flutter/material.dart';
import 'package:app_doctor/core/config/theme/color_system.dart';

export 'package:app_doctor/core/config/theme/design_tokens.dart';
export 'package:app_doctor/core/config/theme/color_system.dart';
export 'package:app_doctor/core/config/theme/color_roles.dart';
export 'package:app_doctor/core/config/theme/responsive_extension.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  AppSemanticColors get semantic =>
      theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;
  TextTheme get textStyles => theme.textTheme;

  Color get primary => colors.primary;
  Color get onPrimary => colors.onPrimary;

  Color get secondary => colors.secondary;
  Color get onSecondary => colors.onSecondary;

  Color get surface => colors.surface;
  Color get onSurface => colors.onSurface;

  Color get background => theme.scaffoldBackgroundColor;

  Color get error => colors.error;
  Color get onError => colors.onError;

  Color get border => colors.outline;
  Color get success => semantic.success;
  Color get warning => semantic.warning;
  Color get info => semantic.info;
  Color get neutralMuted => semantic.neutralMuted;
  Color get neutralWeak => semantic.neutralWeak;
  Color get tooltipBackground => semantic.tooltipBackground;
  Color get tooltipForeground => semantic.tooltipForeground;
  Color get scrim => semantic.scrim;
  Color get navShadow => semantic.navShadow;
  Color get chartPrimary => semantic.chartPrimary;
  Color get chartSecondary => semantic.chartSecondary;
  Color get chartTertiary => semantic.chartTertiary;
  Color get chatIncomingBubble => semantic.chatIncomingBubble;
  Color get chatIncomingText => semantic.chatIncomingText;
  Color get chatIncomingMeta => semantic.chatIncomingMeta;
  Color get chatReadReceipt => semantic.chatReadReceipt;
  Color get voiceGradientStart => semantic.voiceGradientStart;
  Color get voiceGradientEnd => semantic.voiceGradientEnd;
  Color get voiceOverlay => semantic.voiceOverlay;

  TextStyle? get displayLarge => textStyles.displayLarge;
  TextStyle? get displayMedium => textStyles.displayMedium;
  TextStyle? get displaySmall => textStyles.displaySmall;

  TextStyle? get headlineLarge => textStyles.headlineLarge;
  TextStyle? get headlineMedium => textStyles.headlineMedium;
  TextStyle? get headlineSmall => textStyles.headlineSmall;

  TextStyle? get titleLarge => textStyles.titleLarge;
  TextStyle? get titleMedium => textStyles.titleMedium;
  TextStyle? get titleSmall => textStyles.titleSmall;

  TextStyle? get bodyLarge => textStyles.bodyLarge;
  TextStyle? get bodyMedium => textStyles.bodyMedium;
  TextStyle? get bodySmall => textStyles.bodySmall;

  TextStyle? get labelLarge => textStyles.labelLarge;
  TextStyle? get labelMedium => textStyles.labelMedium;
  TextStyle? get labelSmall => textStyles.labelSmall;
}
