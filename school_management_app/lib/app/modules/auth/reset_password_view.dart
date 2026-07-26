import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/validators.dart';
import 'auth_controller.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _token = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  late final AuthController controller = Get.find<AuthController>();

  @override
  void dispose() {
    _token.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.resetPassword(
      token: _token.text.trim(),
      newPassword: _newPassword.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.password_rounded,
                          size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('Choose a new password',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Paste the reset token you received, then set the new '
                        'password. The token can only be used once.',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _token,
                        decoration: const InputDecoration(
                          labelText: 'Reset token',
                          prefixIcon: Icon(Icons.key_rounded),
                        ),
                        validator: (v) => Validators.required(v, 'Reset token'),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => TextFormField(
                          controller: _newPassword,
                          obscureText: controller.obscureNewPassword.value,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: controller.obscureNewPassword.toggle,
                              icon: Icon(controller.obscureNewPassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: Validators.password,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => TextFormField(
                          controller: _confirmPassword,
                          obscureText: controller.obscureNewPassword.value,
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
                            prefixIcon: Icon(Icons.lock_person_outlined),
                          ),
                          validator: (v) => v != _newPassword.text
                              ? 'Passwords do not match'
                              : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                controller.resetting.value ? null : _submit,
                            child: controller.resetting.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : const Text('Reset password'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
