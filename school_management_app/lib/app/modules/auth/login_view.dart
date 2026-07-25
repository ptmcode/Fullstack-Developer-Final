import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (isWide) const Expanded(flex: 5, child: _BrandPanel()),
              Expanded(
                flex: 4,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _LoginForm(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B7CF6), Color(0xFFA99BFF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 32),
            const Text(
              'School Management\nSystem',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Students • Teachers • Subjects • Classes\nEnrollments • Grades • Users & Roles • Audit',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .85),
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'GetX • http • Secure Storage • GetStorage • JWT',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: controller.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_rounded, size: 42, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Welcome back',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Sign in to manage your school',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 32),
          TextFormField(
            controller: controller.usernameController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Username or email',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) => Validators.required(v, 'Username'),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => controller.login(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: controller.obscurePassword.toggle,
                  icon: Icon(controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: Validators.password,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: (v) => controller.rememberMe.value = v ?? false,
                ),
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.loggingIn.value ? null : controller.login,
                child: controller.loggingIn.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Sign in'),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demo accounts',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: theme.colorScheme.primary)),
                const SizedBox(height: 6),
                const Text(
                  'admin / admin@123 — full access\n'
                  'teacher1 / teacher@123 — enrollments & grades\n'
                  'student1 / student@123 — read-only',
                  style: TextStyle(fontSize: 12.5, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
