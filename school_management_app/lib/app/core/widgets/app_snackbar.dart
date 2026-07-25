import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Consistent feedback toasts across the app.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message) => _show(
        title: 'Success',
        message: message,
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF16A34A),
      );

  static void error(String message) => _show(
        title: 'Error',
        message: message,
        icon: Icons.error_rounded,
        color: const Color(0xFFDC2626),
      );

  static void info(String message) => _show(
        title: 'Info',
        message: message,
        icon: Icons.info_rounded,
        color: const Color(0xFF2563EB),
      );

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: color.withValues(alpha: .95),
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }
}
