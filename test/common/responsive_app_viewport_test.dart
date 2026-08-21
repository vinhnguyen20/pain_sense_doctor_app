import 'package:app_doctor/common/widgets/responsive_app_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setViewport(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  for (final width in [1024.0, 1280.0, 1366.0]) {
    testWidgets('scales the 1440 desktop canvas at ${width.toInt()}px', (
      tester,
    ) async {
      await setViewport(tester, Size(width, 800));
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveAppViewport(
            enabled: true,
            child: Builder(
              builder: (context) {
                final size = MediaQuery.sizeOf(context);
                return GestureDetector(
                  key: const ValueKey('scaled-hit-target'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                  child: Text(
                    '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(1)}',
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('responsive-scaled-viewport')),
        findsOneWidget,
      );
      expect(find.textContaining('1440x'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('scaled-hit-target')));
      expect(taps, 1);
    });
  }

  for (final width in [1440.0, 1920.0]) {
    testWidgets('keeps a native canvas at ${width.toInt()}px', (tester) async {
      await setViewport(tester, Size(width, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveAppViewport(
            enabled: true,
            child: Builder(
              builder: (context) =>
                  Text(MediaQuery.sizeOf(context).width.toStringAsFixed(0)),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('responsive-scaled-viewport')),
        findsNothing,
      );
      expect(find.text(width.toStringAsFixed(0)), findsOneWidget);
    });
  }

  testWidgets('does not scale compact layouts', (tester) async {
    await setViewport(tester, const Size(390, 844));

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAppViewport(enabled: true, child: Text('compact')),
      ),
    );

    expect(
      find.byKey(const ValueKey('responsive-scaled-viewport')),
      findsNothing,
    );
  });
}
