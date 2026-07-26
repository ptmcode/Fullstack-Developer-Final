import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import 'notifications_controller.dart';

/// Compose an announcement: broadcast to a whole role, or send to one
/// specific user picked from the user list.
class SendNotificationDialog extends StatefulWidget {
  const SendNotificationDialog({super.key, required this.controller});

  final NotificationsController controller;

  static Future<void> show(NotificationsController controller) => Get.dialog(
        SendNotificationDialog(controller: controller),
        barrierDismissible: false,
      );

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

enum _Audience { role, users }

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _userIds = TextEditingController();

  _Audience _audience = _Audience.role;
  String _role = 'ROLE_STUDENT';

  static const _roles = ['ROLE_STUDENT', 'ROLE_TEACHER', 'ROLE_ADMIN'];

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _userIds.dispose();
    super.dispose();
  }

  List<int> get _parsedUserIds => _userIds.text
      .split(RegExp(r'[,\s]+'))
      .where((s) => s.trim().isNotEmpty)
      .map((s) => int.tryParse(s.trim()))
      .whereType<int>()
      .toList();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.controller.send(
      title: _title.text.trim(),
      body: _body.text.trim(),
      role: _audience == _Audience.role ? _role : null,
      userIds: _audience == _Audience.users ? _parsedUserIds : null,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Send announcement'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  validator: (v) => Validators.required(v, 'Title'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _body,
                  decoration: const InputDecoration(labelText: 'Message *'),
                  maxLines: 3,
                  validator: (v) => Validators.required(v, 'Message'),
                ),
                const SizedBox(height: 18),
                Text('Audience',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SegmentedButton<_Audience>(
                  segments: const [
                    ButtonSegment(
                      value: _Audience.role,
                      label: Text('By role'),
                      icon: Icon(Icons.groups_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: _Audience.users,
                      label: Text('Specific'),
                      icon: Icon(Icons.person_rounded, size: 18),
                    ),
                  ],
                  selected: {_audience},
                  onSelectionChanged: (s) =>
                      setState(() => _audience = s.first),
                ),
                const SizedBox(height: 14),
                if (_audience == _Audience.role)
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _role,
                    decoration: const InputDecoration(labelText: 'Role *'),
                    items: [
                      for (final r in _roles)
                        DropdownMenuItem(
                            value: r, child: Text(Formatters.roleName(r))),
                    ],
                    onChanged: (v) => _role = v ?? 'ROLE_STUDENT',
                  )
                else ...[
                  TextFormField(
                    controller: _userIds,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'User IDs *',
                      hintText: 'e.g. 3, 4',
                    ),
                    validator: (v) => _parsedUserIds.isEmpty
                        ? 'Enter at least one user id'
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find ids on the Users screen. Separate several with commas.',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed:
                widget.controller.actionBusy.value ? null : _submit,
            child: widget.controller.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Text('Send'),
          ),
        ),
      ],
    );
  }
}
