import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/subject_model.dart';
import 'subjects_controller.dart';

class SubjectsView extends GetView<SubjectsController> {
  const SubjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<SubjectModel>(
      controller: controller,
      title: 'Subjects',
      subtitle: 'Curriculum subjects and credits',
      searchHint: 'Search by code or name…',
      emptyMessage: 'No subjects found',
      emptyIcon: Icons.menu_book_outlined,
      headerActions: [
        if (session.hasPermission(AppPermissions.subjectCreate))
          FilledButton.icon(
            onPressed: () => SubjectFormDialog.show(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New subject'),
          ),
      ],
      itemBuilder: (context, subject) {
        final scheme = Theme.of(context).colorScheme;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: CircleAvatar(
              backgroundColor: scheme.primary.withValues(alpha: .12),
              child: Icon(
                Icons.menu_book_rounded,
                color: scheme.primary,
                size: 22,
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subject.subjectCode,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${subject.credit} credit${subject.credit == 1 ? '' : 's'}'
              '${subject.description == null || subject.description!.isEmpty ? '' : ' • ${subject.description}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip.status(subject.status),
                if (session.hasPermission(AppPermissions.subjectUpdate))
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => SubjectFormDialog.show(subject: subject),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                if (session.hasPermission(AppPermissions.subjectDelete))
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => controller.deleteSubject(subject),
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

class SubjectFormDialog extends StatefulWidget {
  const SubjectFormDialog({super.key, this.subject});

  final SubjectModel? subject;

  static Future<void> show({SubjectModel? subject}) => Get.dialog(
    SubjectFormDialog(subject: subject),
    barrierDismissible: false,
  );

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.subject?.subjectCode);
  late final _name = TextEditingController(text: widget.subject?.name);
  late final _credit = TextEditingController(
    text: widget.subject?.credit.toString(),
  );
  late final _description = TextEditingController(
    text: widget.subject?.description,
  );

  bool get isEdit => widget.subject != null;

  @override
  void dispose() {
    for (final c in [_code, _name, _credit, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = Get.find<SubjectsController>();
    final ok = await controller.save(
      id: widget.subject?.id,
      body: {
        'subjectCode': _code.text.trim(),
        'name': _name.text.trim(),
        'credit': int.parse(_credit.text.trim()),
        'description': _description.text.trim(),
      },
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubjectsController>();
    return AlertDialog(
      title: Text(isEdit ? 'Edit subject' : 'New subject'),
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
                      labelText: 'Subject code *',
                    ),
                    validator: (v) => Validators.required(v, 'Subject code'),
                  ),
                  second: TextFormField(
                    controller: _credit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Credits (1–20) *',
                    ),
                    validator: (v) => Validators.intRange(
                      v,
                      field: 'Credits',
                      min: 1,
                      max: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
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
