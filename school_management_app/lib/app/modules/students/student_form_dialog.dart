import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/student_model.dart';
import 'students_controller.dart';

/// Create / edit student dialog. Keeps itself open when the backend rejects
/// the submission (e.g. duplicate student code) so nothing typed is lost.
class StudentFormDialog extends StatefulWidget {
  const StudentFormDialog({super.key, this.student});

  final StudentModel? student;

  static Future<void> show({StudentModel? student}) => Get.dialog(
    StudentFormDialog(student: student),
    barrierDismissible: false,
  );

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.student?.studentCode);
  late final _firstName = TextEditingController(
    text: widget.student?.firstName,
  );
  late final _lastName = TextEditingController(text: widget.student?.lastName);
  late final _email = TextEditingController(text: widget.student?.email);
  late final _phone = TextEditingController(text: widget.student?.phone);
  late final _address = TextEditingController(text: widget.student?.address);
  late String _gender = widget.student?.gender ?? 'M';
  late DateTime? _dateOfBirth = widget.student?.dateOfBirth;

  bool get isEdit => widget.student != null;

  @override
  void dispose() {
    for (final c in [_code, _firstName, _lastName, _email, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 15, 1, 1),
      firstDate: DateTime(1950),
      lastDate: now.subtract(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dateOfBirth == null) {
      setState(() {}); // shows the inline error below the field
      return;
    }
    final controller = Get.find<StudentsController>();
    final ok = await controller.save(
      id: widget.student?.id,
      body: {
        'studentCode': _code.text.trim(),
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'gender': _gender,
        'dateOfBirth': Formatters.isoDate(_dateOfBirth),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
      },
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentsController>();
    return AlertDialog(
      title: Text(isEdit ? 'Edit student' : 'New student'),
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
                      labelText: 'Student code *',
                    ),
                    validator: (v) => Validators.required(v, 'Student code'),
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
                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of birth *',
                      errorText:
                          _dateOfBirth == null &&
                              (_formKey.currentState?.validate() ?? false)
                          ? 'Date of birth is required'
                          : null,
                      suffixIcon: const Icon(Icons.calendar_month_rounded),
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? 'Tap to select'
                          : Formatters.date(_dateOfBirth),
                    ),
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
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address'),
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
