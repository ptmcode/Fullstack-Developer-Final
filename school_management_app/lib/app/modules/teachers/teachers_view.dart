import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/teacher_model.dart';
import 'teachers_controller.dart';

class TeachersView extends GetView<TeachersController> {
  const TeachersView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<TeacherModel>(
      controller: controller,
      title: 'Teachers',
      subtitle: 'Manage teaching staff',
      searchHint: 'Search by code, name or specialization…',
      emptyMessage: 'No teachers found',
      emptyIcon: Icons.co_present_outlined,
      headerActions: [
        if (session.hasPermission(AppPermissions.teacherCreate))
          FilledButton.icon(
            onPressed: () => TeacherFormDialog.show(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New teacher'),
          ),
      ],
      itemBuilder: (context, teacher) {
        final scheme = Theme.of(context).colorScheme;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: InitialsAvatar(
              text:
                  '${teacher.firstName.isNotEmpty ? teacher.firstName[0] : '?'}'
                  '${teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''}',
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    teacher.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  teacher.teacherCode,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${teacher.specialization ?? '—'} • ${Formatters.gender(teacher.gender)}'
              '${teacher.email == null ? '' : ' • ${teacher.email}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip.status(teacher.status),
                if (session.hasPermission(AppPermissions.teacherUpdate))
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => TeacherFormDialog.show(teacher: teacher),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                if (session.hasPermission(AppPermissions.teacherDelete))
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => controller.deleteTeacher(teacher),
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

class TeacherFormDialog extends StatefulWidget {
  const TeacherFormDialog({super.key, this.teacher});

  final TeacherModel? teacher;

  static Future<void> show({TeacherModel? teacher}) => Get.dialog(
    TeacherFormDialog(teacher: teacher),
    barrierDismissible: false,
  );

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.teacher?.teacherCode);
  late final _firstName = TextEditingController(
    text: widget.teacher?.firstName,
  );
  late final _lastName = TextEditingController(text: widget.teacher?.lastName);
  late final _email = TextEditingController(text: widget.teacher?.email);
  late final _phone = TextEditingController(text: widget.teacher?.phone);
  late final _specialization = TextEditingController(
    text: widget.teacher?.specialization,
  );
  late String _gender = widget.teacher?.gender ?? 'M';

  bool get isEdit => widget.teacher != null;

  @override
  void dispose() {
    for (final c in [
      _code,
      _firstName,
      _lastName,
      _email,
      _phone,
      _specialization,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = Get.find<TeachersController>();
    final ok = await controller.save(
      id: widget.teacher?.id,
      body: {
        'teacherCode': _code.text.trim(),
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'gender': _gender,
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'specialization': _specialization.text.trim(),
      },
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeachersController>();
    return AlertDialog(
      title: Text(isEdit ? 'Edit teacher' : 'New teacher'),
      content: SizedBox(
        width: 460,
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
                      labelText: 'Teacher code *',
                    ),
                    validator: (v) => Validators.required(v, 'Teacher code'),
                  ),
                  second: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender *'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Male')),
                      DropdownMenuItem(value: 'F', child: Text('Female')),
                    ],
                    onChanged: (v) => _gender = v ?? 'M',
                  ),
                ),
                const SizedBox(height: 14),
                ResponsivePair(
                  first: TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(
                      labelText: 'First name *',
                    ),
                    validator: (v) => Validators.required(v, 'First name'),
                  ),
                  second: TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Last name *'),
                    validator: (v) => Validators.required(v, 'Last name'),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _specialization,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
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
