import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'shared_widgets.dart';

/// ID-badge style dialog with a QR code, used for student cards and the
/// signed-in user's own badge. The payload is a small JSON document so a
/// future scanner (or any generic QR app) can read it.
class QrBadgeDialog extends StatelessWidget {
  const QrBadgeDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.payload,
  });

  final String title;
  final String subtitle;
  final String payload;

  /// Builds the JSON payload and opens the badge.
  static Future<void> show({
    required String title,
    required String subtitle,
    required Map<String, dynamic> data,
  }) =>
      Get.dialog(QrBadgeDialog(
        title: title,
        subtitle: subtitle,
        payload: jsonEncode(data),
      ));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InitialsAvatar(
              text: title
                  .split(' ')
                  .where((p) => p.isNotEmpty)
                  .take(2)
                  .map((p) => p[0].toUpperCase())
                  .join(),
              radius: 26,
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: scheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            // QR codes need a light background to scan reliably in dark mode.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 200,
                gapless: true,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Scan with any QR reader',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: Get.back, child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
