import 'package:app_doctor/core/config/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Scales the complete authenticated navigator (including its overlays) to the
/// width of the window while preserving the 1440 px desktop design canvas.
///
/// Compact layouts are not scaled. They receive the real viewport so text,
/// controls and system insets remain comfortably sized on phones and tablets.
class ResponsiveAppViewport extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ResponsiveAppViewport({
    super.key,
    required this.child,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;

        if (viewportWidth < AppBreakpoints.desktopShell ||
            viewportWidth >= AppLayout.desktopCanvasWidth ||
            !viewportWidth.isFinite ||
            !viewportHeight.isFinite ||
            viewportWidth <= 0 ||
            viewportHeight <= 0) {
          return child;
        }

        final scale = viewportWidth / AppLayout.desktopCanvasWidth;
        final logicalHeight = viewportHeight / scale;
        final mediaQuery = MediaQuery.of(context);
        final logicalMediaQuery = mediaQuery.copyWith(
          size: Size(AppLayout.desktopCanvasWidth, logicalHeight),
          padding: _unscale(mediaQuery.padding, scale),
          viewPadding: _unscale(mediaQuery.viewPadding, scale),
          viewInsets: _unscale(mediaQuery.viewInsets, scale),
          systemGestureInsets: _unscale(mediaQuery.systemGestureInsets, scale),
        );

        return ClipRect(
          child: FittedBox(
            key: const ValueKey('responsive-scaled-viewport'),
            alignment: Alignment.topLeft,
            fit: BoxFit.fill,
            child: SizedBox(
              width: AppLayout.desktopCanvasWidth,
              height: logicalHeight,
              child: MediaQuery(data: logicalMediaQuery, child: child),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _unscale(EdgeInsets value, double scale) => EdgeInsets.fromLTRB(
    value.left / scale,
    value.top / scale,
    value.right / scale,
    value.bottom / scale,
  );
}
