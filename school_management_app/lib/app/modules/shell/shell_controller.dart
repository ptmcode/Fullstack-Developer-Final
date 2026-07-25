import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/repositories/auth_repository.dart';

/// One entry in the side navigation.
class ShellDestination {
  const ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.permission,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Permission required to see this entry; `null` = always visible.
  final String? permission;
}

/// Controls the main shell: which destinations the signed-in user may see,
/// which one is selected, the theme toggle and signing out.
class ShellController extends GetxController {
  ShellController({
    required SessionService session,
    required PreferencesService preferences,
    required AuthRepository auth,
  })  : _session = session,
        _preferences = preferences,
        _auth = auth;

  final SessionService _session;
  final PreferencesService _preferences;
  final AuthRepository _auth;

  SessionService get session => _session;

  /// Master list — indexes here are stable and used by the IndexedStack.
  static const destinations = <ShellDestination>[
    ShellDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      permission: AppPermissions.dashboardRead,
    ),
    ShellDestination(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
      label: 'Students',
      permission: AppPermissions.studentRead,
    ),
    ShellDestination(
      icon: Icons.co_present_outlined,
      selectedIcon: Icons.co_present_rounded,
      label: 'Teachers',
      permission: AppPermissions.teacherRead,
    ),
    ShellDestination(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Subjects',
      permission: AppPermissions.subjectRead,
    ),
    ShellDestination(
      icon: Icons.meeting_room_outlined,
      selectedIcon: Icons.meeting_room_rounded,
      label: 'Classes',
      permission: AppPermissions.classRead,
    ),
    ShellDestination(
      icon: Icons.how_to_reg_outlined,
      selectedIcon: Icons.how_to_reg_rounded,
      label: 'Enrollments',
      permission: AppPermissions.enrollmentRead,
    ),
    ShellDestination(
      icon: Icons.group_outlined,
      selectedIcon: Icons.group_rounded,
      label: 'Users',
      permission: AppPermissions.userRead,
    ),
    ShellDestination(
      icon: Icons.verified_user_outlined,
      selectedIcon: Icons.verified_user_rounded,
      label: 'Roles',
      permission: AppPermissions.roleRead,
    ),
    ShellDestination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Audit Logs',
      permission: AppPermissions.auditRead,
    ),
    ShellDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'My Profile',
    ),
  ];

  final selectedIndex = 0.obs;

  /// Pages already opened once — they stay alive inside the IndexedStack.
  final visited = <int>{0}.obs;

  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _preferences.themeMode;
    // Land on the first destination the user is actually allowed to see.
    final first = visibleIndexes.isEmpty ? destinations.length - 1 : visibleIndexes.first;
    selectedIndex.value = first;
    visited
      ..clear()
      ..add(first);
  }

  /// Master indexes the current user may access.
  List<int> get visibleIndexes => [
        for (var i = 0; i < destinations.length; i++)
          if (destinations[i].permission == null ||
              _session.hasPermission(destinations[i].permission!))
            i,
      ];

  /// Core sections shown in the phone bottom navigation bar (max 5, like the
  /// design reference): Dashboard, Students, Classes, Enrollments, Profile.
  /// Everything else stays reachable through the dashboard quick links.
  static const _bottomMaster = [0, 1, 4, 5, 9];

  /// Master indexes for the bottom bar, permission-filtered.
  List<int> get bottomIndexes =>
      _bottomMaster.where(visibleIndexes.contains).toList();

  ShellDestination get current => destinations[selectedIndex.value];

  void select(int masterIndex) {
    selectedIndex.value = masterIndex;
    visited.add(masterIndex);
  }

  void toggleTheme() {
    final isDark = themeMode.value == ThemeMode.dark ||
        (themeMode.value == ThemeMode.system &&
            Get.mediaQuery.platformBrightness == Brightness.dark);
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    _preferences.setThemeMode(themeMode.value);
    Get.changeThemeMode(themeMode.value);
  }

  Future<void> logout() async {
    final confirmed = await showConfirmDialog(
      title: 'Sign out',
      message: 'This revokes your refresh tokens on the server. Continue?',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (!confirmed) return;
    await _auth.logout();
    await _session.endSession();
  }
}
