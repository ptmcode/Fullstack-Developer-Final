import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/qr_badge_dialog.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/grade_model.dart';
import 'student_detail_controller.dart';

class StudentDetailView extends GetView<StudentDetailController> {
  const StudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.student.value.fullName)),
        actions: [
          IconButton(
            tooltip: 'Student QR badge',
            onPressed: () {
              final s = controller.student.value;
              QrBadgeDialog.show(
                title: s.fullName,
                subtitle: s.studentCode,
                data: {
                  'type': 'student',
                  'code': s.studentCode,
                  'name': s.fullName,
                  'email': s.email,
                },
              );
            },
            icon: const Icon(Icons.qr_code_rounded),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Export report card (PDF)',
              onPressed: controller.exporting.value
                  ? null
                  : controller.exportTranscript,
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value && controller.enrollmentList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return ErrorState(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileCard(controller: controller),
                const SizedBox(height: 16),
                _EnrollmentsCard(controller: controller, session: session),
                const SizedBox(height: 16),
                _GradesCard(controller: controller, session: session),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final StudentDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final s = controller.student.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(
                    text:
                        '${s.firstName.isNotEmpty ? s.firstName[0] : '?'}'
                        '${s.lastName.isNotEmpty ? s.lastName[0] : ''}',
                    radius: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.fullName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          s.studentCode,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip.status(s.status),
                ],
              ),
              const Divider(height: 28),
              InfoTile(
                label: 'Gender',
                value: Formatters.gender(s.gender),
                icon: Icons.wc_rounded,
              ),
              InfoTile(
                label: 'Date of birth',
                value: Formatters.date(s.dateOfBirth),
                icon: Icons.cake_outlined,
              ),
              InfoTile(
                label: 'Email',
                value: s.email ?? '',
                icon: Icons.alternate_email,
              ),
              InfoTile(
                label: 'Phone',
                value: s.phone ?? '',
                icon: Icons.call_outlined,
              ),
              InfoTile(
                label: 'Address',
                value: s.address ?? '',
                icon: Icons.location_on_outlined,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _EnrollmentsCard extends StatelessWidget {
  const _EnrollmentsCard({required this.controller, required this.session});

  final StudentDetailController controller;
  final SessionService session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enrollments (${controller.enrollmentList.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (session.hasPermission(AppPermissions.enrollmentCreate))
                    FilledButton.tonalIcon(
                      onPressed: () => _EnrollDialog.show(controller),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Enroll'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (controller.enrollmentList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Not enrolled in any class yet')),
                ),
              for (final e in controller.enrollmentList)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.meeting_room_outlined),
                  title: Text(
                    '${e.className ?? '—'} (${e.classCode ?? ''})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Enrolled ${Formatters.dateTime(e.enrolledAt)}',
                  ),
                  trailing:
                      session.hasPermission(AppPermissions.enrollmentDelete)
                      ? IconButton(
                          tooltip: 'Remove enrollment',
                          onPressed: () => controller.removeEnrollment(e),
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradesCard extends StatelessWidget {
  const _GradesCard({required this.controller, required this.session});

  final StudentDetailController controller;
  final SessionService session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Grades (${controller.gradeList.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (session.hasPermission(AppPermissions.gradeCreate))
                    FilledButton.tonalIcon(
                      onPressed: () => GradeFormDialog.show(controller),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Record grade'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (controller.gradeList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No grades recorded yet')),
                ),
              for (final g in controller.gradeList)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primary.withValues(alpha: .1),
                    child: Text(
                      g.letter,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    '${g.subjectName ?? 'Subject #${g.subjectId}'} '
                    '(${g.subjectCode ?? ''})',
                  ),
                  subtitle: Text(
                    '${Formatters.term(g.term)} • graded by ${g.gradedBy ?? '—'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        g.score.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (session.hasPermission(AppPermissions.gradeUpdate))
                        IconButton(
                          tooltip: 'Edit grade',
                          onPressed: () =>
                              GradeFormDialog.show(controller, grade: g),
                          icon: const Icon(Icons.edit_outlined, size: 19),
                        ),
                      if (session.hasPermission(AppPermissions.gradeDelete))
                        IconButton(
                          tooltip: 'Delete grade',
                          onPressed: () => controller.deleteGrade(g),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog to enroll the student into a class.
class _EnrollDialog extends StatefulWidget {
  const _EnrollDialog({required this.controller});

  final StudentDetailController controller;

  static Future<void> show(StudentDetailController controller) async {
    await controller.ensureClassOptions();
    Get.dialog(
      _EnrollDialog(controller: controller),
      barrierDismissible: false,
    );
  }

  @override
  State<_EnrollDialog> createState() => _EnrollDialogState();
}

class _EnrollDialogState extends State<_EnrollDialog> {
  int? _classId;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AlertDialog(
      title: const Text('Enroll into class'),
      content: SizedBox(
        width: 400,
        child: Obx(
          () => DropdownButtonFormField<int>(
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
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: c.actionBusy.value || _classId == null
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    final ok = await c.enroll(_classId!);
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

/// Record / edit a grade for one of the student's enrollments.
class GradeFormDialog extends StatefulWidget {
  const GradeFormDialog({super.key, required this.controller, this.grade});

  final StudentDetailController controller;
  final GradeModel? grade;

  static Future<void> show(
    StudentDetailController controller, {
    GradeModel? grade,
  }) async {
    await controller.ensureSubjectOptions();
    Get.dialog(
      GradeFormDialog(controller: controller, grade: grade),
      barrierDismissible: false,
    );
  }

  @override
  State<GradeFormDialog> createState() => _GradeFormDialogState();
}

class _GradeFormDialogState extends State<GradeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late int? _enrollmentId = widget.grade?.enrollmentId;
  late int? _subjectId = widget.grade?.subjectId;
  late String _term = widget.grade?.term ?? 'S1';
  late final _score = TextEditingController(
    text: widget.grade?.score.toStringAsFixed(1),
  );

  bool get isEdit => widget.grade != null;

  @override
  void dispose() {
    _score.dispose();
    super.dispose();
  }

  String _enrollmentLabel(EnrollmentModel e) =>
      '${e.className ?? 'Class #${e.classId}'} (${e.classCode ?? ''})';

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_enrollmentId == null || _subjectId == null) return;
    final ok = await widget.controller.saveGrade(
      gradeId: widget.grade?.id,
      enrollmentId: _enrollmentId!,
      subjectId: _subjectId!,
      score: double.parse(_score.text.trim()),
      term: _term,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AlertDialog(
      title: Text(isEdit ? 'Edit grade' : 'Record grade'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enrollment and subject are fixed after creation.
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _enrollmentId,
                decoration: const InputDecoration(
                  labelText: 'Enrollment (class) *',
                ),
                items: [
                  for (final e in c.enrollmentList)
                    DropdownMenuItem(
                      value: e.id,
                      child: Text(_enrollmentLabel(e)),
                    ),
                ],
                onChanged: isEdit
                    ? null
                    : (v) => setState(() => _enrollmentId = v),
                validator: (v) => v == null ? 'Select an enrollment' : null,
              ),
              const SizedBox(height: 14),
              Obx(
                () => DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject *'),
                  items: [
                    for (final s in c.subjectOptions)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} (${s.subjectCode})'),
                      ),
                  ],
                  onChanged: isEdit
                      ? null
                      : (v) => setState(() => _subjectId = v),
                  validator: (v) => v == null ? 'Select a subject' : null,
                ),
              ),
              const SizedBox(height: 14),
              // Dialogs are narrow on phones: score + term side by side would
              // overflow, so they stack below 480px of screen width.
              Builder(
                builder: (context) {
                  final scoreField = TextFormField(
                    controller: _score,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Score (0–100) *',
                    ),
                    validator: Validators.score,
                  );
                  final termField = DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _term,
                    decoration: const InputDecoration(labelText: 'Term *'),
                    items: const [
                      DropdownMenuItem(value: 'S1', child: Text('Semester 1')),
                      DropdownMenuItem(value: 'S2', child: Text('Semester 2')),
                    ],
                    onChanged: (v) => _term = v ?? 'S1',
                  );
                  if (MediaQuery.sizeOf(context).width < 480) {
                    return Column(
                      children: [
                        scoreField,
                        const SizedBox(height: 14),
                        termField,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: scoreField),
                      const SizedBox(width: 12),
                      Expanded(child: termField),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: c.actionBusy.value ? null : _submit,
            child: c.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(isEdit ? 'Save changes' : 'Record'),
          ),
        ),
      ],
    );
  }
}
