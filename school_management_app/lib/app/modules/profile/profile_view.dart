import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/services/push_notification_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/qr_badge_dialog.dart';
import '../../core/widgets/shared_widgets.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // The app bar already shows "My Profile" on phones — skip the big header.
    final compact = MediaQuery.sizeOf(context).width < 640;
    return RefreshIndicator(
      onRefresh: controller.refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!compact) ...[
              const PageHeader(
                title: 'My Profile',
                subtitle: 'Account details, roles and password',
              ),
              const SizedBox(height: 16),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 820;
                final info = _InfoCard(controller: controller);
                final password = _PasswordCard(controller: controller);
                if (!wide) {
                  return Column(
                    children: [info, const SizedBox(height: 16), password],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    Expanded(child: password),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const _NotificationsCard(),
          ],
        ),
      ),
    );
  }
}

/// Push notification status + the device FCM token (copyable, so a test
/// message can be sent from the Firebase console).
class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final push = Get.find<PushNotificationService>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final token = push.fcmToken.value;
          final reason = push.unavailableReason.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Push notifications',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  token != null
                      ? const StatusChip(
                          label: 'Connected',
                          color: Color(0xFF16A34A),
                          icon: Icons.notifications_active_rounded)
                      : const StatusChip(
                          label: 'Unavailable',
                          color: Color(0xFFD97706),
                          icon: Icons.notifications_off_rounded),
                ],
              ),
              const SizedBox(height: 8),
              if (token != null) ...[
                Text(
                  'Subscribed to the "${PushNotificationService.topic}" topic. '
                  'Send a test from Firebase console → Messaging, targeting the '
                  'topic or this device token:',
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          token,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy token',
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: token));
                          AppSnackbar.success('FCM token copied');
                        },
                      ),
                    ],
                  ),
                ),
                if (push.lastMessage.value != null) ...[
                  const SizedBox(height: 8),
                  Text('Last message: ${push.lastMessage.value}',
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ] else
                Text(
                  reason ?? 'Waiting for permission…',
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 13, height: 1.4),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final user = controller.session.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(text: user.initials, radius: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text('@${user.username}',
                            style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  StatusChip.status(user.status),
                ],
              ),
              const Divider(height: 28),
              InfoTile(
                  label: 'Email', value: user.email, icon: Icons.alternate_email),
              InfoTile(
                  label: 'Phone',
                  value: user.phoneNumber ?? '',
                  icon: Icons.call_outlined),
              InfoTile(
                  label: 'Member since',
                  value: Formatters.date(user.createdAt),
                  icon: Icons.event_rounded),
              const SizedBox(height: 10),
              Text('Roles',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final role in user.roles)
                    StatusChip(
                        label: Formatters.roleName(role), color: scheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text('Permissions (${user.permissions.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in user.permissions) StatusChip(label: p),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => QrBadgeDialog.show(
                    title: user.fullName,
                    subtitle: '@${user.username}',
                    data: {
                      'type': 'user',
                      'username': user.username,
                      'name': user.fullName,
                      'email': user.email,
                      'roles': user.roles,
                    },
                  ),
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('My QR badge'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Owns its text controllers so they can never outlive—or be outlived by—
/// the GetX controller (see ProfileController).
class _PasswordCard extends StatefulWidget {
  const _PasswordCard({required this.controller});

  final ProfileController controller;

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();

  ProfileController get controller => widget.controller;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.changePassword(
      currentPassword: _current.text,
      newPassword: _newPassword.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change password',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'After a successful change every session is signed out '
                'and you must log in with the new password.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  children: [
                    TextFormField(
                      controller: _current,
                      obscureText: controller.obscure.value,
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: controller.obscure.toggle,
                          icon: Icon(controller.obscure.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _newPassword,
                      obscureText: controller.obscure.value,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirm,
                      obscureText: controller.obscure.value,
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                        prefixIcon: Icon(Icons.lock_person_outlined),
                      ),
                      validator: (v) => v != _newPassword.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        controller.changingPassword.value ? null : _submit,
                    icon: controller.changingPassword.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5))
                        : const Icon(Icons.check_rounded),
                    label: const Text('Update password'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
