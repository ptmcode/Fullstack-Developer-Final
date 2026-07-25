import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/shared_widgets.dart';
import '../audit/audit_view.dart';
import '../classes/classes_view.dart';
import '../dashboard/dashboard_view.dart';
import '../enrollments/enrollments_view.dart';
import '../profile/profile_view.dart';
import '../roles/roles_view.dart';
import '../students/students_view.dart';
import '../subjects/subjects_view.dart';
import '../teachers/teachers_view.dart';
import '../users/users_view.dart';
import 'shell_controller.dart';

/// Root layout after sign-in.
///
/// Phones: bottom navigation bar (5 core sections, selected icon in a
/// rounded indigo square — like the design reference); other sections are
/// reached from the dashboard quick links.
/// Wide screens: extended NavigationRail with every permitted section.
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  static final _pages = <Widget Function()>[
    () => const DashboardView(),
    () => const StudentsView(),
    () => const TeachersView(),
    () => const SubjectsView(),
    () => const ClassesView(),
    () => const EnrollmentsView(),
    () => const UsersView(),
    () => const RolesView(),
    () => const AuditView(),
    () => const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;
        return Scaffold(
          appBar: AppBar(
            centerTitle: !isWide,
            title: Obx(() => Text(controller.current.label)),
            actions: [
              Obx(
                () => IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: controller.toggleTheme,
                  icon: Icon(
                    controller.themeMode.value == ThemeMode.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _UserMenu(controller: controller),
              const SizedBox(width: 16),
            ],
          ),
          bottomNavigationBar: isWide ? null : _buildBottomBar(context),
          body: Row(
            children: [
              if (isWide) _buildRail(context),
              if (isWide) const VerticalDivider(width: 1),
              Expanded(
                child: Obx(
                  () => IndexedStack(
                    index: controller.selectedIndex.value,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        controller.visited.contains(i)
                            ? _pages[i]()
                            : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      final bottom = controller.bottomIndexes;
      if (bottom.length < 2) return const SizedBox.shrink();
      final position = bottom.indexOf(controller.selectedIndex.value);
      return NavigationBar(
        // Sections opened via quick links aren't in the bar — keep Home lit.
        selectedIndex: position < 0 ? 0 : position,
        onDestinationSelected: (i) => controller.select(bottom[i]),
        destinations: [
          for (final i in bottom)
            NavigationDestination(
              icon: Icon(ShellController.destinations[i].icon),
              selectedIcon: Icon(ShellController.destinations[i].selectedIcon),
              label: ShellController.destinations[i].label,
            ),
        ],
      );
    });
  }

  Widget _buildRail(BuildContext context) {
    return Obx(() {
      final visible = controller.visibleIndexes;
      final selectedMaster = controller.selectedIndex.value;
      final railIndex = visible.indexOf(selectedMaster);
      return NavigationRail(
        extended: true,
        minExtendedWidth: 220,
        selectedIndex: railIndex < 0 ? 0 : railIndex,
        onDestinationSelected: (i) => controller.select(visible[i]),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school_rounded,
                    color: Theme.of(context).colorScheme.onPrimary, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('School MS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ),
        destinations: [
          for (final i in visible)
            NavigationRailDestination(
              icon: Icon(ShellController.destinations[i].icon),
              selectedIcon: Icon(ShellController.destinations[i].selectedIcon),
              label: Text(ShellController.destinations[i].label),
            ),
        ],
      );
    });
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.controller});

  final ShellController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.session.user;
      return PopupMenuButton<String>(
        tooltip: 'Account',
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (value) {
          if (value == 'profile') {
            controller.select(ShellController.destinations.length - 1);
          } else if (value == 'logout') {
            controller.logout();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(user?.email ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'profile',
            child: ListTile(
              leading: Icon(Icons.person_outline_rounded),
              title: Text('My profile'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'logout',
            child: ListTile(
              leading: Icon(Icons.logout_rounded),
              title: Text('Sign out'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        child: InitialsAvatar(text: user?.initials ?? '?', radius: 17),
      );
    });
  }
}
