import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/school_class_model.dart';
import 'classes_controller.dart';

class ClassesView extends GetView<ClassesController> {
  const ClassesView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<SchoolClassModel>(
      controller: controller,
      title: 'Classes',
      subtitle: 'Class groups per academic year',
      searchHint: 'Search by code, name or academic year…',
      emptyMessage: 'No classes found',
      emptyIcon: Icons.meeting_room_outlined,
      headerActions: [
        if (session.hasPermission(AppPermissions.classCreate))
          FilledButton.icon(
            onPressed: () => ClassFormDialog.show(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New class'),
          ),
      ],
      itemBuilder: (context, schoolClass) {
        final scheme = Theme.of(context).colorScheme;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            onTap: session.hasPermission(AppPermissions.enrollmentRead)
                ? () => ClassRosterDialog.show(controller, schoolClass)
                : null,
            leading: CircleAvatar(
              backgroundColor: scheme.primary.withValues(alpha: .12),
              child: Icon(
                Icons.meeting_room_rounded,
                color: scheme.primary,
                size: 22,
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    schoolClass.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  schoolClass.classCode,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${schoolClass.academicYear} • Homeroom: ${schoolClass.teacherName ?? '—'}'
              ' • Capacity ${schoolClass.capacity ?? '—'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip.status(schoolClass.status),
                if (session.hasPermission(AppPermissions.classUpdate))
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () =>
                        ClassFormDialog.show(schoolClass: schoolClass),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                if (session.hasPermission(AppPermissions.classDelete))
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => controller.deleteClass(schoolClass),
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

/// Create / edit class dialog with the homeroom teacher dropdown.
class ClassFormDialog extends StatefulWidget {
  const ClassFormDialog({super.key, this.schoolClass});

  final SchoolClassModel? schoolClass;

  static Future<void> show({SchoolClassModel? schoolClass}) async {
    await Get.find<ClassesController>().ensureTeacherOptions();
    Get.dialog(
      ClassFormDialog(schoolClass: schoolClass),
      barrierDismissible: false,
    );
  }

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.schoolClass?.classCode);
  late final _name = TextEditingController(text: widget.schoolClass?.name);
  late final _year = TextEditingController(
    text: widget.schoolClass?.academicYear ?? '2025-2026',
  );
  late final _capacity = TextEditingController(
    text: widget.schoolClass?.capacity?.toString(),
  );
  late int? _teacherId = widget.schoolClass?.teacherId;

  bool get isEdit => widget.schoolClass != null;

  @override
  void dispose() {
    for (final c in [_code, _name, _year, _capacity]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = Get.find<ClassesController>();
    final ok = await controller.save(
      id: widget.schoolClass?.id,
      body: {
        'classCode': _code.text.trim(),
        'name': _name.text.trim(),
        'academicYear': _year.text.trim(),
        if (_teacherId != null) 'teacherId': _teacherId,
        if (_capacity.text.trim().isNotEmpty)
          'capacity': int.parse(_capacity.text.trim()),
      },
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClassesController>();
    return AlertDialog(
      title: Text(isEdit ? 'Edit class' : 'New class'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsivePair(
                  first: TextFormField(
                    controller: _code,
                    decoration: const InputDecoration(
                      labelText: 'Class code *',
                    ),
                    validator: (v) => Validators.required(v, 'Class code'),
                  ),
                  second: TextFormField(
                    controller: _year,
                    decoration: const InputDecoration(
                      labelText: 'Academic year *',
                    ),
                    validator: Validators.academicYear,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => DropdownButtonFormField<int?>(
                    isExpanded: true,
                    initialValue: _teacherId,
                    decoration: const InputDecoration(
                      labelText: 'Homeroom teacher',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('— None —'),
                      ),
                      for (final t in controller.teacherOptions)
                        DropdownMenuItem<int?>(
                          value: t.id,
                          child: Text('${t.fullName} (${t.teacherCode})'),
                        ),
                    ],
                    onChanged: (v) => _teacherId = v,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _capacity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  validator: (v) => Validators.intRange(
                    v,
                    field: 'Capacity',
                    min: 1,
                    max: 500,
                    allowEmpty: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: controller.actionBusy.value ? null : _submit,
            child: controller.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(isEdit ? 'Save changes' : 'Create'),
          ),
        ),
      ],
    );
  }
}

/// Shows who is enrolled in a class; teachers/admins can enroll or remove
/// students right here.
class ClassRosterDialog extends StatelessWidget {
  const ClassRosterDialog({
    super.key,
    required this.controller,
    required this.schoolClass,
  });

  final ClassesController controller;
  final SchoolClassModel schoolClass;

  static Future<void> show(
    ClassesController controller,
    SchoolClassModel schoolClass,
  ) {
    controller.loadRoster(schoolClass.id);
    return Get.dialog(
      ClassRosterDialog(controller: controller, schoolClass: schoolClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return AlertDialog(
      title: Text('${schoolClass.name} — enrollments'),
      content: SizedBox(
        width: 480,
        height: 380,
        child: Obx(() {
          if (controller.rosterLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.roster.isEmpty) {
            return const EmptyState(
              icon: Icons.how_to_reg_outlined,
              message: 'No students enrolled in this class yet',
            );
          }
          return ListView.builder(
            itemCount: controller.roster.length,
            itemBuilder: (context, i) {
              final e = controller.roster[i];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: InitialsAvatar(
                  text: (e.studentName ?? '?')
                      .split(' ')
                      .where((p) => p.isNotEmpty)
                      .take(2)
                      .map((p) => p[0].toUpperCase())
                      .join(),
                  radius: 17,
                ),
                title: Text('${e.studentName ?? '—'} (${e.studentCode ?? ''})'),
                subtitle: Text('Enrolled ${Formatters.dateTime(e.enrolledAt)}'),
                trailing: session.hasPermission(AppPermissions.enrollmentDelete)
                    ? IconButton(
                        tooltip: 'Remove',
                        onPressed: () => controller.removeFromRoster(e),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      )
                    : null,
              );
            },
          );
        }),
      ),
      actions: [
        if (session.hasPermission(AppPermissions.enrollmentCreate))
          FilledButton.tonalIcon(
            onPressed: () => _EnrollStudentDialog.show(controller),
            icon: const Icon(Icons.person_add_alt_rounded, size: 18),
            label: const Text('Enroll student'),
          ),
        TextButton(onPressed: Get.back, child: const Text('Close')),
      ],
    );
  }
}

class _EnrollStudentDialog extends StatefulWidget {
  const _EnrollStudentDialog({required this.controller});

  final ClassesController controller;

  static Future<void> show(ClassesController controller) async {
    await controller.ensureStudentOptions();
    Get.dialog(
      _EnrollStudentDialog(controller: controller),
      barrierDismissible: false,
    );
  }

  @override
  State<_EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<_EnrollStudentDialog> {
  int? _studentId;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AlertDialog(
      title: const Text('Enroll a student'),
      content: SizedBox(
        width: 400,
        child: Obx(
          () => DropdownButtonFormField<int>(
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
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: c.actionBusy.value || _studentId == null
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    final ok = await c.enrollStudent(_studentId!);
                    if (ok) navigator.pop();
                  },
            child: c.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Enroll'),
          ),
        ),
      ],
    );
  }
}
