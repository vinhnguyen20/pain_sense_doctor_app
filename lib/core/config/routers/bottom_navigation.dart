import 'package:app_doctor/common/widgets/sidebar_navigation.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationScaffold({super.key, required this.navigationShell});

  @override
  State<BottomNavigationScaffold> createState() =>
      _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppPalette.white,
        body: Row(
          children: [
            SidebarNavigation(navigationShell: widget.navigationShell),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        final isDoubleBack =
            _lastBackPressed != null &&
            now.difference(_lastBackPressed!) < const Duration(seconds: 2);

        if (isDoubleBack) {
          SystemNavigator.pop();
          return;
        }

        _lastBackPressed = now;
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    const items = [
      _MobileNavItem(icon: Icons.home, label: 'Home', branchIndex: 0),
      _MobileNavItem(
        icon: Icons.calendar_month_outlined,
        label: 'Schedule',
        branchIndex: 4,
      ),
      _MobileNavItem(icon: Icons.settings, label: 'Settings', branchIndex: 5),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            children: items.map((item) {
              final isSelected =
                  item.branchIndex == widget.navigationShell.currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    widget.navigationShell.goBranch(
                      item.branchIndex,
                      initialLocation:
                          item.branchIndex ==
                          widget.navigationShell.currentIndex,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isSelected
                            ? context.colors.primary
                            : AppPalette.medGray,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTypography.captionBody2.copyWith(
                          color: isSelected
                              ? context.colors.primary
                              : AppPalette.medGray,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem {
  final IconData icon;
  final String label;
  final int branchIndex;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.branchIndex,
  });
}
