import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class CompactNavDestination {
  final IconData icon;
  final String label;
  final int? branchIndex;
  final int? badgeCount;
  final VoidCallback? onTap;

  const CompactNavDestination({
    required this.icon,
    required this.label,
    this.branchIndex,
    this.badgeCount,
    this.onTap,
  });
}

/// Four primary destinations plus an overflow sheet for compact shells.
class CompactNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<CompactNavDestination> destinations;
  final List<CompactNavDestination> overflowDestinations;
  final ValueChanged<int> onSelectBranch;

  const CompactNavigationBar({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.overflowDestinations,
    required this.onSelectBranch,
  }) : assert(destinations.length == 4);

  bool get _isOverflowSelected => overflowDestinations.any(
    (destination) => destination.branchIndex == currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final destination in destinations)
        _NavigationButton(
          icon: destination.icon,
          label: destination.label,
          badgeCount: destination.badgeCount,
          isSelected: destination.branchIndex == currentIndex,
          onTap: () => _activate(destination),
        ),
      _NavigationButton(
        icon: Icons.more_horiz_rounded,
        label: 'More',
        isSelected: _isOverflowSelected,
        onTap: () => _showMore(context),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: items
                .map((item) => Expanded(child: item))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  void _activate(CompactNavDestination destination) {
    final branchIndex = destination.branchIndex;
    if (branchIndex != null) {
      onSelectBranch(branchIndex);
    } else {
      destination.onTap?.call();
    }
  }

  Future<void> _showMore(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s4,
          AppSpacing.s16,
          AppSpacing.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final destination in overflowDestinations)
              ListTile(
                leading: Icon(
                  destination.icon,
                  color: destination.branchIndex == currentIndex
                      ? AppPalette.secondaryBlue
                      : AppPalette.medGray,
                ),
                title: Text(destination.label),
                trailing:
                    (destination.badgeCount != null &&
                        destination.badgeCount! > 0)
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          destination.badgeCount! > 99
                              ? '99+'
                              : destination.badgeCount.toString(),
                          style: const TextStyle(
                            color: AppPalette.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                selected: destination.branchIndex == currentIndex,
                selectedColor: AppPalette.secondaryBlue,
                selectedTileColor: AppPalette.secondaryBlue.withValues(
                  alpha: 0.08,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppCorners.r12,
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _activate(destination);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppPalette.secondaryBlue : AppPalette.medGray;
    final hasBadge = badgeCount != null && badgeCount! > 0;

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasBadge)
              Badge(
                label: Text(
                  badgeCount! > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: AppPalette.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red,
                child: Icon(icon, size: AppSize.iconLg, color: color),
              )
            else
              Icon(icon, size: AppSize.iconLg, color: color),
            const SizedBox(height: AppSpacing.s4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
