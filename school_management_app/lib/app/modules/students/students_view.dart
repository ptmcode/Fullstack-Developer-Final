import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/student_model.dart';
import '../../routes/app_routes.dart';
import 'student_form_dialog.dart';
import 'students_controller.dart';

class StudentsView extends GetView<StudentsController> {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<StudentModel>(
      controller: controller,
      title: 'Students',
      subtitle: 'Manage student records',
      searchHint: 'Search by code or name…',
      emptyMessage: 'No students found',
      emptyIcon: Icons.school_outlined,
      headerActions: [
        Obx(
          () => IconButton(
            tooltip: 'Export PDF',
            onPressed: controller.exporting.value ? null : controller.exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ),
        Obx(
          () => IconButton(
            tooltip: 'Export Excel',
            onPressed:
                controller.exporting.value ? null : controller.exportExcel,
            icon: const Icon(Icons.table_view_outlined),
          ),
        ),
        const SizedBox(width: 4),
        if (session.hasPermission(AppPermissions.studentCreate))
          FilledButton.icon(
            onPressed: () => StudentFormDialog.show(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New student'),
          ),
      ],
      itemBuilder: (context, student) => _StudentTile(
        student: student,
        canUpdate: session.hasPermission(AppPermissions.studentUpdate),
        canDelete: session.hasPermission(AppPermissions.studentDelete),
        onEdit: () => StudentFormDialog.show(student: student),
        onDelete: () => controller.deleteStudent(student),
        onOpen: () => Get.toNamed(AppRoutes.studentDetail, arguments: student),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.student,
    required this.canUpdate,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  });

  final StudentModel student;
  final bool canUpdate;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: InitialsAvatar(
          text: '${student.firstName.isNotEmpty ? student.firstName[0] : '?'}'
              '${student.lastName.isNotEmpty ? student.lastName[0] : ''}',
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(student.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(student.studentCode,
                style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5)),
          ],
        ),
        subtitle: Text(
          '${Formatters.gender(student.gender)} • '
          'DOB ${Formatters.date(student.dateOfBirth)}'
          '${student.email == null || student.email!.isEmpty ? '' : ' • ${student.email}'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusChip.status(student.status),
            PopupMenuButton<String>(
              tooltip: 'Actions',
              onSelected: (v) {
                switch (v) {
                  case 'open':
                    onOpen();
                  case 'edit':
                    onEdit();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'open', child: Text('View details')),
                if (canUpdate) const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canDelete)
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
