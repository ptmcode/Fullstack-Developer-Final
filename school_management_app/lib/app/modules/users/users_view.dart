import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_permissions.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/user_model.dart';
import 'users_controller.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    return ListPageScaffold<UserModel>(
      controller: controller,
      title: 'Users',
      subtitle: 'System accounts, roles and access',
      searchHint: 'Search by username, email or name…',
      emptyMessage: 'No users found',
      emptyIcon: Icons.group_outlined,
      headerActions: [
        if (session.hasPermission(AppPermissions.userCreate))
          FilledButton.icon(
            onPressed: () => UserFormDialog.show(),
            icon: const Icon(Icons.person_add_alt_rounded),
            label: const Text('New user'),
          ),
      ],
      itemBuilder: (context, user) {
        final isSelf = session.user?.id == user.id;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: InitialsAvatar(text: user.initials),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(user.email, style: const TextStyle(fontSize: 12.5)),
                  for (final role in user.roles)
                    StatusChip(
                      label: Formatters.roleName(role),
                      color: role == 'ROLE_ADMIN'
                          ? const Color(0xFFDC2626)
                          : role == 'ROLE_TEACHER'
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF16A34A),
                    ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusChip.status(user.status),
                PopupMenuButton<String>(
                  tooltip: 'Actions',
                  onSelected: (v) {
                    switch (v) {
                      case 'edit':
                        UserFormDialog.show(user: user);
                      case 'roles':
                        AssignRolesDialog.show(user);
                      case 'delete':
                        controller.deleteUser(user);
                    }
                  },
                  itemBuilder: (context) => [
                    if (session.hasPermission(AppPermissions.userUpdate))
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (session.hasPermission(AppPermissions.userUpdate))
                      const PopupMenuItem(
                        value: 'roles',
                        child: Text('Assign roles'),
                      ),
                    if (session.hasPermission(AppPermissions.userDelete) &&
                        !isSelf)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Create / edit user with role checkboxes. Password is required on create
/// and optional on edit (blank = keep current).
class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.user});

  final UserModel? user;

  static Future<void> show({UserModel? user}) async {
    await Get.find<UsersController>().ensureRoleOptions();
    Get.dialog(UserFormDialog(user: user), barrierDismissible: false);
  }

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _username = TextEditingController(text: widget.user?.username);
  late final _email = TextEditingController(text: widget.user?.email);
  late final _firstName = TextEditingController(text: widget.user?.firstName);
  late final _lastName = TextEditingController(text: widget.user?.lastName);
  late final _phone = TextEditingController(text: widget.user?.phoneNumber);
  final _password = TextEditingController();
  late final Set<String> _selectedRoles = {...?widget.user?.roles};
  bool _obscure = true;

  bool get isEdit => widget.user != null;

  @override
  void dispose() {
    for (final c in [
      _username,
      _email,
      _firstName,
      _lastName,
      _phone,
      _password,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = Get.find<UsersController>();
    final ok = await controller.save(
      id: widget.user?.id,
      body: {
        'username': _username.text.trim(),
        'email': _email.text.trim(),
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phoneNumber': _phone.text.trim(),
        if (_password.text.isNotEmpty) 'password': _password.text,
        'roles': _selectedRoles.toList(),
      },
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    return AlertDialog(
      title: Text(isEdit ? 'Edit user' : 'New user'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsivePair(
                  first: TextFormField(
                    controller: _username,
                    decoration: const InputDecoration(labelText: 'Username *'),
                    validator: (v) => Validators.required(v, 'Username'),
                  ),
                  second: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: Validators.email,
                  ),
                ),
                const SizedBox(height: 14),
                ResponsivePair(
                  first: TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'First name'),
                  ),
                  second: TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Last name'),
                  ),
                ),
                const SizedBox(height: 14),
                ResponsivePair(
                  first: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  second: TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: isEdit
                          ? 'New password (optional)'
                          : 'Password *',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        Validators.password(v, allowEmpty: isEdit),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Roles',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final role in controller.roleOptions)
                        FilterChip(
                          label: Text(Formatters.roleName(role.name)),
                          selected: _selectedRoles.contains(role.name),
                          onSelected: (selected) => setState(() {
                            selected
                                ? _selectedRoles.add(role.name)
                                : _selectedRoles.remove(role.name);
                          }),
                        ),
                    ],
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

/// Quick "replace role set" dialog (`PUT /users/{id}/roles`).
class AssignRolesDialog extends StatefulWidget {
  const AssignRolesDialog({super.key, required this.user});

  final UserModel user;

  static Future<void> show(UserModel user) async {
    await Get.find<UsersController>().ensureRoleOptions();
    Get.dialog(AssignRolesDialog(user: user), barrierDismissible: false);
  }

  @override
  State<AssignRolesDialog> createState() => _AssignRolesDialogState();
}

class _AssignRolesDialogState extends State<AssignRolesDialog> {
  late final Set<String> _selected = {...widget.user.roles};

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    return AlertDialog(
      title: Text('Roles — ${widget.user.username}'),
      content: SizedBox(
        width: 380,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final role in controller.roleOptions)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(Formatters.roleName(role.name)),
                  subtitle: role.description == null
                      ? null
                      : Text(role.description!),
                  value: _selected.contains(role.name),
                  onChanged: (checked) => setState(() {
                    checked == true
                        ? _selected.add(role.name)
                        : _selected.remove(role.name);
                  }),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        Obx(
          () => FilledButton(
            onPressed: controller.actionBusy.value || _selected.isEmpty
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    final ok = await controller.assignRoles(
                      widget.user.id,
                      _selected.toList(),
                    );
                    if (ok) navigator.pop();
                  },
            child: controller.actionBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Save roles'),
          ),
        ),
      ],
    );
  }
}
