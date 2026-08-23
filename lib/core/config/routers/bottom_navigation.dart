import 'package:app_doctor/common/widgets/compact_navigation_bar.dart';
import 'package:app_doctor/common/widgets/sidebar_navigation.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<BottomNavigationScaffold> createState() =>
      _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState
    extends ConsumerState<BottomNavigationScaffold> {
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(conversationsProvider);
      if (state.conversations.isEmpty && !state.isLoading) {
        ref.read(conversationsProvider.notifier).fetchConversations(
          showLoading: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopCanvas;
    final unreadCount = ref.watch(unreadMessagesCountProvider);

    if (isDesktop) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppPalette.white,
          body: Row(
            children: [
              SidebarNavigation(navigationShell: widget.navigationShell),
              Expanded(child: widget.navigationShell),
            ],
          ),
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
        bottomNavigationBar: CompactNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          destinations: [
            const CompactNavDestination(
              icon: Icons.home_outlined,
              label: 'Home',
              branchIndex: 0,
            ),
            CompactNavDestination(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Connect',
              branchIndex: 1,
              badgeCount: unreadCount,
            ),
            const CompactNavDestination(
              icon: Icons.flag_outlined,
              label: 'Goals',
              branchIndex: 3,
            ),
            const CompactNavDestination(
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
          onSelectBranch: _openBranch,
        ),
      ),
    );
  }

  void _openBranch(int branchIndex) {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }
}
