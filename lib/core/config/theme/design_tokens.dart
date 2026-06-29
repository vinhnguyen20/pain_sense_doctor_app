import 'package:flutter/material.dart';
/// Material Design 3 adaptive breakpoints.
/// - compact  : < 600  → phone portrait
/// - medium   : 600–839 → phone landscape / small tablet
/// - expanded : ≥ 840  → tablet / desktop
abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double expanded = 840;
}
abstract final class AppSpacing {
  static const double s0 = 0;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
}

abstract final class AppRadius {
  static const double r3 = 3;
  static const double r4 = 4;
  static const double r8 = 8;
  static const double r10 = 10;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double full = 999;
}

abstract final class AppSize {
  static const double appBarHeight = 80;
  static const double appBarBottomDivider = 2;
  static const double buttonHeight = 54;
  static const double inputIcon = 20;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double progressIndicator = 20;
  static const double bottomSheetHandleWidth = 36;
  static const double bottomSheetHandleHeight = 4;
}

abstract final class AppButtonSize {
  static const double sm = 40;
  static const double md = 48;
  static const double lg = 54;
}

abstract final class AppButtonRadius {
  static const double sm = AppRadius.r10;
  static const double md = AppRadius.r12;
  static const double lg = AppRadius.r14;
}

abstract final class AppButtonInset {
  static const EdgeInsets sm = EdgeInsets.symmetric(
    horizontal: AppSpacing.s12,
    vertical: AppSpacing.s8,
  );
  static const EdgeInsets md = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
    vertical: AppSpacing.s10,
  );
  static const EdgeInsets lg = EdgeInsets.symmetric(
    horizontal: AppSpacing.s20,
    vertical: AppSpacing.s12,
  );
}

abstract final class AppBorder {
  static const double thin = 0.8;
  static const double regular = 1;
  static const double strong = 1.5;
}

abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 250);
}

abstract final class AppInsets {
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
  );
  static const EdgeInsets screenAll = EdgeInsets.all(AppSpacing.s16);
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.s16);
  static const EdgeInsets inputContent = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
    vertical: AppSpacing.s16,
  );
  static const EdgeInsets buttonContent = EdgeInsets.symmetric(
    horizontal: AppSpacing.s24,
    vertical: AppSpacing.s12,
  );
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.s12,
    vertical: AppSpacing.s6,
  );
}

abstract final class AppCorners {
  static const BorderRadius r8 = BorderRadius.all(
    Radius.circular(AppRadius.r8),
  );
  static const BorderRadius r10 = BorderRadius.all(
    Radius.circular(AppRadius.r10),
  );
  static const BorderRadius r12 = BorderRadius.all(
    Radius.circular(AppRadius.r12),
  );
  static const BorderRadius r14 = BorderRadius.all(
    Radius.circular(AppRadius.r14),
  );
  static const BorderRadius r16 = BorderRadius.all(
    Radius.circular(AppRadius.r16),
  );
  static const BorderRadius r20 = BorderRadius.all(
    Radius.circular(AppRadius.r20),
  );
}
