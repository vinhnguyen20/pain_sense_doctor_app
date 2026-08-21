import 'package:app_doctor/common/widgets/compact_navigation_bar.dart';
import 'package:app_doctor/core/config/theme/color_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects primary and More destinations on a phone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    int? selectedBranch;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: CompactNavigationBar(
            currentIndex: 0,
            destinations: const [
              CompactNavDestination(
                icon: Icons.home_outlined,
                label: 'Home',
                branchIndex: 0,
              ),
              CompactNavDestination(
                icon: Icons.chat_outlined,
                label: 'Connect',
                branchIndex: 1,
              ),
              CompactNavDestination(
                icon: Icons.flag_outlined,
                label: 'Goals',
                branchIndex: 3,
              ),
              CompactNavDestination(
                icon: Icons.calendar_month_outlined,
                label: 'Schedule',
                branchIndex: 4,
              ),
            ],
            overflowDestinations: const [
              CompactNavDestination(
                icon: Icons.accessibility_new_rounded,
                label: 'Exercises',
                branchIndex: 2,
              ),
              CompactNavDestination(
                icon: Icons.settings_outlined,
                label: 'Settings',
                branchIndex: 5,
              ),
            ],
            onSelectBranch: (value) => selectedBranch = value,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final selectedHomeIcon = tester.widget<Icon>(
      find.byIcon(Icons.home_outlined),
    );
    expect(selectedHomeIcon.color, AppPalette.secondaryBlue);
    await tester.tap(find.text('Goals'));
    expect(selectedBranch, 3);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(selectedBranch, 5);
    expect(tester.takeException(), isNull);
  });
}
