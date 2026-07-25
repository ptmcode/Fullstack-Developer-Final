import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/enrollment_model.dart';
import 'enrollments_controller.dart';

class EnrollmentsView extends GetView<EnrollmentsController> {
  const EnrollmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<EnrollmentModel>(
      controller: controller,
      title: 'Enrollments',
      subtitle: 'Which student is in which class',
      emptyMessage: 'No enrollments found',
      emptyIcon: Icons.how_to_reg_outlined,
      headerActions: [
        if (session.hasPermission(AppPermissions.enrollmentCreate))
          FilledButton.icon(
            onPressed: () => EnrollDialog.show(controller),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Enroll student'),
          ),
      ],
      filterRow: _FilterRow(controller: controller),
      itemBuilder: (context, enrollment) {
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            onTap: session.hasPermission(AppPermissions.gradeRead)
                ? () => EnrollmentGradesDialog.show(controller, enrollment)
                : null,
            leading: InitialsAvatar(
              text: (enrollment.studentName ?? '?')
                  .split(' ')
                  .where((p) => p.isNotEmpty)
                  .take(2)
                  .map((p) => p[0].toUpperCase())
                  .join(),
            ),
            title: Text(
              '${enrollment.studentName ?? '—'} → ${enrollment.className ?? '—'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${enrollment.studentCode ?? ''} • ${enrollment.classCode ?? ''} • '
              'Enrolled ${Formatters.dateTime(enrollment.enrolledAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip.status(enrollment.status),
                if (session.hasPermission(AppPermissions.gradeRead))
                  IconButton(
                    tooltip: 'View grades',
                    onPressed: () =>
                        EnrollmentGradesDialog.show(controller, enrollment),
                    icon: const Icon(Icons.grade_outlined, size: 20),
                  ),
                if (session.hasPermission(AppPermissions.enrollmentDelete))
                  IconButton(
                    tooltip: 'Remove enrollment',
                    onPressed: () => controller.removeEnrollment(enrollment),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final EnrollmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final studentFilter = DropdownButtonFormField<int?>(
        isExpanded: true,
        initialValue: controller.filterStudentId.value,
        decoration: const InputDecoration(
          labelText: 'Filter by student',
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All students')),
          for (final s in controller.studentOptions)
            DropdownMenuItem<int?>(
              value: s.id,
              child: Text('${s.fullName} (${s.studentCode})',
                  overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: controller.setStudentFilter,
      );
      final classFilter = DropdownButtonFormField<int?>(
        isExpanded: true,
        initialValue: controller.filterClassId.value,
        decoration: const InputDecoration(
          labelText: 'Filter by class',
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All classes')),
          for (final k in controller.classOptions)
            DropdownMenuItem<int?>(
              value: k.id,
              child: Text('${k.name} • ${k.academicYear}',
                  overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: controller.setClassFilter,
      );

      // Side by side on wide screens, stacked on phones.
      final compact = MediaQuery.sizeOf(context).width < 640;
      if (compact) {
        return Column(
          children: [studentFilter, const SizedBox(height: 10), classFilter],
        );
      }
      return Row(
        children: [
          Expanded(child: studentFilter),
          const SizedBox(width: 12),
          Expanded(child: classFilter),
        ],
      );
    });
  }
}

/// Enroll dialog with both student and class dropdowns.
class EnrollDialog extends StatefulWidget {
  const EnrollDialog({super.key, required this.controller});

  final EnrollmentsController controller;

  static Future<void> show(EnrollmentsController controller) => Get.dialog(
        EnrollDialog(controller: controller),
        barrierDismissible: false,
      );

  @override
  State<EnrollDialog> createState() => _EnrollDialogState();
}

class _EnrollDialogState extends State<EnrollDialog> {
  int? _studentId;
  int? _classId;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AlertDialog(
      title: const Text('Enroll student into class'),
      content: SizedBox(
        width: 420,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _studentId,
                decoration: const InputDecoration(labelText: 'Student *'),
                items: [
                  for (final s in c.studentOptions)
                    DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.fullName} (${s.studentCode})'),
                    ),
                ],
                onChanged: (v) => setState(() => _studentId = v),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _classId,
                decoration: const InputDecoration(labelText: 'Class *'),
                items: [
                  for (final k in c.classOptions)
                    DropdownMenuItem(
                      value: k.id,
                      child: Text('${k.name} • ${k.academicYear}'),
                    ),
                ],
                onChanged: (v) => setState(() => _classId = v),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Duplicates are rejected and class capacity is enforced '
                  'by the server.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: c.actionBusy.value || _studentId == null || _classId == null
                ? null
                : () async {
                    final ok = await c.enroll(
                        studentId: _studentId!, classId: _classId!);
                    if (ok && context.mounted) Navigator.of(context).pop();
                  },
            child: c.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Text('Enroll'),
          ),
        ),
      ],
    );
  }
}

/// Read-only grades of one enrollment (`GET /enrollments/{id}/grades`).
class EnrollmentGradesDialog extends StatelessWidget {
  const EnrollmentGradesDialog({super.key, required this.controller});

  final EnrollmentsController controller;

  static Future<void> show(
      EnrollmentsController controller, EnrollmentModel enrollment) {
    controller.loadGrades(enrollment);
    return Get.dialog(EnrollmentGradesDialog(controller: controller));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Obx(() => Text(
          'Grades — ${controller.gradesFor.value?.studentName ?? ''} '
          '(${controller.gradesFor.value?.className ?? ''})')),
      content: SizedBox(
        width: 460,
        height: 320,
        child: Obx(() {
          if (controller.gradesLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.grades.isEmpty) {
            return const EmptyState(
              icon: Icons.grade_outlined,
              message: 'No grades recorded for this enrollment yet',
            );
          }
          return ListView.builder(
            itemCount: controller.grades.length,
            itemBuilder: (context, i) {
              final g = controller.grades[i];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: scheme.primary.withValues(alpha: .1),
                  child: Text(g.letter,
                      style: TextStyle(
                          color: scheme.primary, fontWeight: FontWeight.w800)),
                ),
                title: Text('${g.subjectName ?? ''} (${g.subjectCode ?? ''})'),
                subtitle: Text(
                    '${Formatters.term(g.term)} • graded by ${g.gradedBy ?? '—'}'),
                trailing: Text(
                  g.score.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Close')),
      ],
    );
  }
}
