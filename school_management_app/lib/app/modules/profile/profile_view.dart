import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
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
          ],
        ),
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
            ],
          );
        }),
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.passwordFormKey,
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
                      controller: controller.currentPasswordController,
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
                      controller: controller.newPasswordController,
                      obscureText: controller.obscure.value,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.obscure.value,
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                        prefixIcon: Icon(Icons.lock_person_outlined),
                      ),
                      validator: (v) =>
                          v != controller.newPasswordController.text
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
                    onPressed: controller.changingPassword.value
                        ? null
                        : controller.changePassword,
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
