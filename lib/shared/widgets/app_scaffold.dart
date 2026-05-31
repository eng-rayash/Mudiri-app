import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../core/theme/neu_decorations.dart';

/// App Shell Scaffold — bottom navigation wrapper.
///
/// Wraps all main screens with a Neumorphic bottom navigation bar.
/// Uses ShellRoute from GoRouter for tab persistence.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'الرئيسية', path: RouteNames.dashboardFull),
    _NavItem(icon: Icons.groups_rounded, label: 'الاجتماعات', path: RouteNames.meetingsListFull),
    _NavItem(icon: Icons.task_alt_rounded, label: 'المهام', path: RouteNames.tasksListFull),
    _NavItem(icon: Icons.replay_rounded, label: 'المتابعات', path: RouteNames.followupsListFull),
    _NavItem(icon: Icons.archive_rounded, label: 'أرشيف المذكرات', path: RouteNames.archiveListFull),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;

    return PopScope(
      canPop: currentPath == RouteNames.dashboardFull,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentPath != RouteNames.dashboardFull) {
          context.go(RouteNames.dashboardFull);
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: NeuDecorations.neuFlat(
            radius: 0,
            isDark: isDark,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.map((item) {
                  final isSelected = currentPath == item.path;
                  return _buildNavItem(
                    context,
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required _NavItem item,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => context.go(item.path),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: NeuDecorations.pressDuration,
        curve: NeuDecorations.pressCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? NeuDecorations.neuPressed(radius: 12, isDark: isDark)
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: isSelected
                  ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                  : NeuColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: AppTypography.navLabel.copyWith(
                color: isSelected
                    ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                    : NeuColors.textHint,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}
