import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/shared_widgets.dart';
import '../shell/shell_controller.dart';
import 'dashboard_controller.dart';

/// Home screen styled after the mobile design reference: greeting header,
/// gradient hero banner, colorful tappable stat tiles, quick links and
/// recent activity.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value && controller.summary.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null && controller.summary.value == null) {
        return ErrorState(
          message: controller.error.value!,
          onRetry: controller.load,
        );
      }
      final data = controller.summary.value;
      if (data == null) return const SizedBox.shrink();

      final session = Get.find<SessionService>();
      final shell = Get.find<ShellController>();

      final tiles = <_TileSpec>[
        _TileSpec('Students', Icons.school_rounded, AppTheme.tileViolet,
            data.students, 1, AppPermissions.studentRead),
        _TileSpec('Teachers', Icons.co_present_rounded, AppTheme.tileBlue,
            data.teachers, 2, AppPermissions.teacherRead),
        _TileSpec('Subjects', Icons.menu_book_rounded, AppTheme.tileAmber,
            data.subjects, 3, AppPermissions.subjectRead),
        _TileSpec('Classes', Icons.meeting_room_rounded, AppTheme.tileGreen,
            data.classes, 4, AppPermissions.classRead),
        _TileSpec('Enrollments', Icons.how_to_reg_rounded, AppTheme.tileOrange,
            data.enrollments, 5, AppPermissions.enrollmentRead),
        _TileSpec('Users', Icons.group_rounded, AppTheme.tilePink, data.users,
            6, AppPermissions.userRead),
      ];

      return RefreshIndicator(
        onRefresh: controller.load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingHeader(session: session),
              const SizedBox(height: 18),
              const _HeroBanner(),
              const SizedBox(height: 22),
              _SectionTitle('Overview'),
              const SizedBox(height: 12),
              _StatGrid(
                tiles: tiles,
                onOpen: (tile) {
                  if (session.hasPermission(tile.permission)) {
                    shell.select(tile.masterIndex);
                  } else {
                    AppSnackbar.info(
                        '${tile.label} is not available for your role.');
                  }
                },
              ),
              const SizedBox(height: 10),
              _QuickLinks(session: session, shell: shell),
              const SizedBox(height: 22),
              _SectionTitle('Recent enrollments'),
              const SizedBox(height: 12),
              _RecentEnrollmentsStrip(controller: controller),
              const SizedBox(height: 22),
              _SectionTitle('Recent activity'),
              const SizedBox(height: 12),
              _RecentActivities(controller: controller),
            ],
          ),
        ),
      );
    });
  }
}

class _TileSpec {
  const _TileSpec(this.label, this.icon, this.color, this.count,
      this.masterIndex, this.permission);

  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final int masterIndex;
  final String permission;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

/// "Good Morning!" + user name + avatar, like the reference home header.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.session});

  final SessionService session;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final user = session.user;
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(
                  user?.fullName ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          InitialsAvatar(text: user?.initials ?? '?', radius: 24),
        ],
      );
    });
  }
}

/// Indigo gradient banner, echoing the reference hero card.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B7CF6), Color(0xFFA99BFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B7CF6).withValues(alpha: .3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'School Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Students, classes, enrollments & grades — all in one place.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

/// Colorful filled tiles (2-up on phones), like the "Assignment Status" grid.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.tiles, required this.onOpen});

  final List<_TileSpec> tiles;
  final void Function(_TileSpec) onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 6
            : constraints.maxWidth >= 700
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 2 ? 1.55 : 1.35,
          children: [for (final tile in tiles) _StatTile(tile: tile, onOpen: onOpen)],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.tile, required this.onOpen});

  final _TileSpec tile;
  final void Function(_TileSpec) onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tile.color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onOpen(tile),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .22),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(tile.icon, color: Colors.white, size: 19),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: .7), size: 18),
                ],
              ),
              const Spacer(),
              Text(
                '${tile.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                tile.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chips leading to the sections that are not in the phone bottom bar.
class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.session, required this.shell});

  final SessionService session;
  final ShellController shell;

  static const _links = <(String, IconData, int, String)>[
    ('Teachers', Icons.co_present_outlined, 2, AppPermissions.teacherRead),
    ('Subjects', Icons.menu_book_outlined, 3, AppPermissions.subjectRead),
    ('Users', Icons.group_outlined, 6, AppPermissions.userRead),
    ('Roles', Icons.verified_user_outlined, 7, AppPermissions.roleRead),
    ('Audit Logs', Icons.receipt_long_outlined, 8, AppPermissions.auditRead),
  ];

  @override
  Widget build(BuildContext context) {
    final visible =
        _links.where((l) => session.hasPermission(l.$4)).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final link in visible)
            ActionChip(
              avatar: Icon(link.$2, size: 18),
              label: Text(link.$1),
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              onPressed: () => shell.select(link.$3),
            ),
        ],
      ),
    );
  }
}

/// Horizontal card strip, echoing the "Pickup where you left!" carousel.
class _RecentEnrollmentsStrip extends StatelessWidget {
  const _RecentEnrollmentsStrip({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.summary.value?.recentEnrollments ?? [];
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No enrollments yet')),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final e = items[index];
          return Card(
            child: Container(
              width: 210,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InitialsAvatar(
                        text: (e.studentName ?? '?')
                            .split(' ')
                            .where((p) => p.isNotEmpty)
                            .take(2)
                            .map((p) => p[0].toUpperCase())
                            .join(),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.studentName ?? '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    e.className ?? '—',
                    style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.dateTime(e.enrolledAt),
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentActivities extends StatelessWidget {
  const _RecentActivities({required this.controller});

  final DashboardController controller;

  static const _actionIcons = <String, IconData>{
    'LOGIN': Icons.login_rounded,
    'LOGOUT': Icons.logout_rounded,
    'CREATE': Icons.add_circle_outline_rounded,
    'UPDATE': Icons.edit_outlined,
    'DELETE': Icons.delete_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final items = controller.summary.value?.recentActivities ?? [];
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No activity yet')),
              )
            : Column(
                children: [
                  for (final a in items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: scheme.primary.withValues(alpha: .1),
                        child: Icon(
                          _actionIcons[a.action] ?? Icons.bolt_rounded,
                          size: 18,
                          color: scheme.primary,
                        ),
                      ),
                      title: Text('${a.username ?? 'system'} • ${a.action ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${a.detail ?? a.entityType ?? ''} • ${Formatters.dateTime(a.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
