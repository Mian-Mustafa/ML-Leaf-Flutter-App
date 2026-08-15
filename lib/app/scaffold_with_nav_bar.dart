import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Responsive navigation shell hosting the five primary study destinations.
/// Uses an indexed stack (via [StatefulNavigationShell]) so each tab keeps its
/// own navigation state and scroll position.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _desktopBreakpoint = 840.0;
  static const _extendedRailBreakpoint = 1200.0;

  static const _destinations = <_AppDestination>[
    _AppDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _AppDestination(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Modules',
    ),
    _AppDestination(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search_rounded,
      label: 'Search',
    ),
    _AppDestination(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
      label: 'Progress',
    ),
    _AppDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Return to the branch's initial location when tapping the active tab.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final usesDesktopNavigation = width >= _desktopBreakpoint;

    if (usesDesktopNavigation) {
      return _DesktopNavigationScaffold(
        navigationShell: navigationShell,
        destinations: _destinations,
        onDestinationSelected: _onTap,
        extended: width >= _extendedRailBreakpoint,
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: _destinations
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DesktopNavigationScaffold extends StatelessWidget {
  const _DesktopNavigationScaffold({
    required this.navigationShell,
    required this.destinations,
    required this.onDestinationSelected,
    required this.extended,
  });

  final StatefulNavigationShell navigationShell;
  final List<_AppDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: extended,
              minExtendedWidth: 224,
              backgroundColor: theme.colorScheme.surface,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                child: extended
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text('ML Leaf', style: theme.textTheme.titleMedium),
                        ],
                      )
                    : Tooltip(
                        message: 'ML Leaf',
                        child: Icon(
                          Icons.eco_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              destinations: destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                  )
                  .toList(),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _AppDestination {
  const _AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
