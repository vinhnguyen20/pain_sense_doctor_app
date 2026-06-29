import 'package:app_doctor/core/config/theme/color_system.dart';
import 'package:flutter/material.dart';

class AppAuthColorRoles {
  final BuildContext _context;
  const AppAuthColorRoles(this._context);

  ThemeData get _theme => Theme.of(_context);
  ColorScheme get _cs => _theme.colorScheme;

  Color get brandBlockBackground => _cs.primary.withValues(alpha: 0.1);
  Color get mutedText => _cs.onSurface.withValues(alpha: 0.5);
  Color get weakText => _cs.onSurface.withValues(alpha: 0.45);
  Color get supportLink => _cs.primary;
}

class AppChatColorRoles {
  final BuildContext _context;
  const AppChatColorRoles(this._context);

  ThemeData get _theme => Theme.of(_context);
  ColorScheme get _cs => _theme.colorScheme;
  AppSemanticColors get _semantic =>
      _theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  Color get incomingBubble => _semantic.chatIncomingBubble;
  Color get incomingText => _semantic.chatIncomingText;
  Color get incomingMeta => _semantic.chatIncomingMeta;
  Color get outgoingBubble => _cs.primary;
  Color get outgoingText => _cs.onPrimary;
  Color get outgoingMeta => _cs.onPrimary.withValues(alpha: 0.72);
  Color get readReceipt => _semantic.chatReadReceipt;

  Color get attachmentGallery => _semantic.chartSecondary;
  Color get attachmentCamera => _semantic.info;
  Color get imageOverlay => _semantic.scrim;

  Color get online => _semantic.success;
  Color get offline => _semantic.neutralMuted;

  Color get viewerBackground => AppPalette.black;
  Color get viewerAppBarBackground => AppPalette.transparent;
  Color get viewerCloseIcon => AppPalette.white;
  Color get viewerTitle => _semantic.tooltipForeground;
}

class AppGoalColorRoles {
  final BuildContext _context;
  const AppGoalColorRoles(this._context);

  ThemeData get _theme => Theme.of(_context);
  ColorScheme get _cs => _theme.colorScheme;
  AppSemanticColors get _semantic =>
      _theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  Color get active => _semantic.success;
  Color get paused => _semantic.warning;
  Color get progressing => _semantic.chartPrimary;
  Color get lowProgress => _cs.error;

  Color get aiBadgeBackground => _cs.primary.withValues(alpha: 0.12);
  Color get aiBadgeText => _cs.primary;

  Color get iconWalking => _semantic.chartPrimary;
  Color get iconYoga => _semantic.chartTertiary;
  Color get iconPosture => _semantic.success;

  Color get consentBackground => paused.withValues(alpha: 0.08);
  Color get consentBorder => paused.withValues(alpha: 0.4);
}

class AppDashboardColorRoles {
  final BuildContext _context;
  const AppDashboardColorRoles(this._context);

  ThemeData get _theme => Theme.of(_context);
  ColorScheme get _cs => _theme.colorScheme;
  AppSemanticColors get _semantic =>
      _theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  Color get riskHigh => _cs.error;
  Color get riskMedium => _semantic.warning;
  Color get riskLow => _semantic.success;

  Color get chartPrimary => _semantic.chartPrimary;
  Color get chartSecondary => _semantic.chartSecondary;
  Color get chartTertiary => _semantic.chartTertiary;
  Color get chartTooltipAccent => chartPrimary.withValues(alpha: 0.6);

  Color get tooltipBackground => _semantic.tooltipBackground;
  Color get tooltipForeground => _semantic.tooltipForeground;
  Color get chartStroke => _cs.onPrimary;
  Color get scrim => _semantic.scrim;
}

class AppNavigationColorRoles {
  final BuildContext _context;
  const AppNavigationColorRoles(this._context);

  ThemeData get _theme => Theme.of(_context);
  ColorScheme get _cs => _theme.colorScheme;
  AppSemanticColors get _semantic =>
      _theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  Color get shadow => _semantic.navShadow;
  Color get selectedBackground => _cs.primary;
  Color get selectedContent => _cs.onPrimary;
  Color get unselectedBackground => AppPalette.transparent;
  Color get unselectedContent => _semantic.neutralMuted;
}

class AppCommonColorRoles {
  const AppCommonColorRoles();

  Color get transparent => AppPalette.transparent;
}

class AppDiaryColorRoles {
  final BuildContext _context;
  const AppDiaryColorRoles(this._context);

  ThemeData get _theme => Theme.of(_context);
  ColorScheme get _cs => _theme.colorScheme;
  AppSemanticColors get _semantic =>
      _theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  Color get progressHigh => _semantic.success;
  Color get progressMedium => _semantic.warning;
  Color get progressLow => _cs.error;

  Color get voiceGradientStart => _semantic.voiceGradientStart;
  Color get voiceGradientEnd => _semantic.voiceGradientEnd;
  Color get voiceOverlay => _semantic.voiceOverlay;

  Color get reliefWalking => _semantic.chartPrimary;
  Color get reliefPosture => _semantic.chartSecondary;
  Color get reliefYoga => _semantic.chartTertiary;

  Color get accentWalking => _semantic.chartPrimary;
  Color get accentActivityTime => _semantic.chartSecondary;
  Color get accentMindfulness => _semantic.chartTertiary;
  Color get accentPain => _cs.error;
  Color get accentRun => _semantic.success;
  Color get accentGeneral => _cs.primary;

  Color accentForType(String type) {
    final value = type.trim().toLowerCase();
    if (value.contains('activity_walk') || value.contains('activity')) {
      return accentActivityTime;
    }
    if (value.contains('yoga') || value.contains('meditation')) {
      return accentMindfulness;
    }
    if (value.contains('walk') || value.contains('step')) return accentWalking;
    if (value.contains('pain')) return accentPain;
    if (value.contains('run')) return accentRun;
    return accentGeneral;
  }

  Color get headerSurface => _cs.primary.withValues(alpha: 0.12);
  Color get headerIconBackground => _cs.primary.withValues(alpha: 0.18);
  Color get headerIcon => _cs.primary;
  Color get headerBorder => _cs.primary.withValues(alpha: 0.22);
}

extension AppDomainColorRoleX on BuildContext {
  AppCommonColorRoles get commonColors => const AppCommonColorRoles();
  AppAuthColorRoles get authColors => AppAuthColorRoles(this);
  AppChatColorRoles get chatColors => AppChatColorRoles(this);
  AppGoalColorRoles get goalColors => AppGoalColorRoles(this);
  AppDashboardColorRoles get dashboardColors => AppDashboardColorRoles(this);
  AppNavigationColorRoles get navigationColors => AppNavigationColorRoles(this);
  AppDiaryColorRoles get diaryColors => AppDiaryColorRoles(this);
}
