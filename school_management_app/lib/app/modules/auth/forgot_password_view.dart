import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.forgotFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_reset_rounded,
                          size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('Reset your password',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the email linked to your account. A single-use '
                        'reset token (valid 30 minutes) will be generated — in '
                        'this demo it is written to the server log.',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: controller.forgotEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: Validators.email,
                        onFieldSubmitted: (_) => controller.requestPasswordReset(),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: controller.sendingReset.value
                                ? null
                                : controller.requestPasswordReset,
                            child: controller.sendingReset.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : const Text('Request reset token'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.resetPassword),
                          child: const Text('I already have a token'),
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
