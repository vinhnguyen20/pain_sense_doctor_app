import 'package:app_doctor/core/config/theme/design_tokens.dart';
import 'package:flutter/material.dart';

extension ResponsiveX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;

  /// Phone portrait — width < 600.
  bool get isMobile => screenWidth < AppBreakpoints.compact;

  /// Phone landscape / tablet — width ≥ 600.
  bool get isTablet => screenWidth >= AppBreakpoints.compact;

  /// Large tablet / desktop — width ≥ 840.
  bool get isExpanded => screenWidth >= AppBreakpoints.expanded;

  /// Returns [tablet] on tablet/desktop, [mobile] otherwise.
  T responsive<T>({required T mobile, required T tablet}) =>
      isMobile ? mobile : tablet;

  /// Horizontal screen padding — tighter on mobile, wider on tablet.
  EdgeInsets get screenPadding => responsive(
    mobile: AppInsets.screenAll,
    tablet: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s32,
      vertical: AppSpacing.s24,
    ),
  );
}
