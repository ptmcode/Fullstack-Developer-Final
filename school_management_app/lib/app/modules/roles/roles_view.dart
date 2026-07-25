import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/role_model.dart';
import 'roles_controller.dart';

class RolesView extends GetView<RolesController> {
  const RolesView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return Obx(() {
      if (controller.loading.value && controller.roles.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null && controller.roles.isEmpty) {
        return ErrorState(
            message: controller.error.value!, onRetry: controller.load);
      }
      return RefreshIndicator(
        onRefresh: controller.load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Roles & Permissions',
                subtitle:
                    '${controller.roles.length} roles • ${controller.allPermissions.length} permission codes',
              ),
              const SizedBox(height: 16),
              for (final role in controller.roles) ...[
                _RoleCard(
                  role: role,
                  canEdit: session.hasPermission(AppPermissions.roleUpdate),
                  onEdit: () => RolePermissionsDialog.show(controller, role),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.canEdit, required this.onEdit});

  final RoleModel role;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: .12),
                  child: Icon(Icons.verified_user_rounded,
                      color: scheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Formatters.roleName(role.name),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      if (role.description != null)
                        Text(role.description!,
                            style: TextStyle(
                                color: scheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                if (canEdit)
                  FilledButton.tonalIcon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Edit permissions'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in role.permissions)
                  StatusChip(label: p, color: scheme.primary),
                if (role.permissions.isEmpty)
                  Text('No permissions',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkbox matrix editor for one role (`PUT /roles/{id}/permissions`).
class RolePermissionsDialog extends StatefulWidget {
  const RolePermissionsDialog(
      {super.key, required this.controller, required this.role});

  final RolesController controller;
  final RoleModel role;

  static Future<void> show(RolesController controller, RoleModel role) =>
      Get.dialog(
        RolePermissionsDialog(controller: controller, role: role),
        barrierDismissible: false,
      );

  @override
  State<RolePermissionsDialog> createState() => _RolePermissionsDialogState();
}

class _RolePermissionsDialogState extends State<RolePermissionsDialog> {
  late final Set<String> _selected = {...widget.role.permissions};

  @override
  Widget build(BuildContext context) {
    final groups = widget.controller.groupedPermissions;
    return AlertDialog(
      title: Text('Permissions — ${Formatters.roleName(widget.role.name)}'),
      content: SizedBox(
        width: 560,
        height: 440,
        child: ListView(
          children: [
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          letterSpacing: .6,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        final all = entry.value.every(_selected.contains);
                        all
                            ? _selected.removeAll(entry.value)
                            : _selected.addAll(entry.value);
                      }),
                      child: Text(
                        entry.value.every(_selected.contains)
                            ? 'Clear all'
                            : 'Select all',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children: [
                  for (final code in entry.value)
                    SizedBox(
                      width: 250,
                      child: CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(code, style: const TextStyle(fontSize: 13.5)),
                        value: _selected.contains(code),
                        onChanged: (checked) => setState(() {
                          checked == true
                              ? _selected.add(code)
                              : _selected.remove(code);
                        }),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        Text('${_selected.length} selected',
            style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(width: 12),
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: widget.controller.actionBusy.value
                ? null
                : () async {
                    final ok = await widget.controller
                        .savePermissions(widget.role, _selected.toList());
                    if (ok && context.mounted) Navigator.of(context).pop();
                  },
            child: widget.controller.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Text('Save'),
          ),
        ),
      ],
    );
  }
}
