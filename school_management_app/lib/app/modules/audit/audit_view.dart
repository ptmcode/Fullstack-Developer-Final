import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/list_page_scaffold.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/audit_log_model.dart';
import 'audit_controller.dart';

class AuditView extends GetView<AuditController> {
  const AuditView({super.key});

  static const _actionColors = <String, Color>{
    'LOGIN': Color(0xFF16A34A),
    'LOGOUT': Color(0xFF64748B),
    'CREATE': Color(0xFF2563EB),
    'UPDATE': Color(0xFFD97706),
    'DELETE': Color(0xFFDC2626),
    'UPDATE_ROLES': Color(0xFF9333EA),
    'CHANGE_PASSWORD': Color(0xFF0891B2),
    'FORGOT_PASSWORD': Color(0xFF0891B2),
    'RESET_PASSWORD': Color(0xFF0891B2),
  };

  @override
  Widget build(BuildContext context) {
    return ListPageScaffold<AuditLogModel>(
      controller: controller,
      title: 'Audit Logs',
      subtitle: 'Every sensitive action, traced',
      searchHint: 'Filter by username…',
      emptyMessage: 'No audit entries match the filters',
      emptyIcon: Icons.receipt_long_outlined,
      filterRow: _AuditFilterRow(controller: controller),
      itemBuilder: (context, log) {
        final color = _actionColors[log.action] ??
            Theme.of(context).colorScheme.primary;
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(Icons.bolt_rounded, color: color, size: 20),
            ),
            title: Row(
              children: [
                Text(log.username ?? 'system',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                StatusChip(label: log.action ?? '—', color: color),
                const SizedBox(width: 6),
                if (log.entityType != null) StatusChip(label: log.entityType!),
              ],
            ),
            subtitle: Text(
              '${log.detail ?? ''}'
              '${log.entityId != null ? ' (#${log.entityId})' : ''}'
              ' • ${log.ipAddress ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              Formatters.dateTime(log.createdAt),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }
}

class _AuditFilterRow extends StatelessWidget {
  const _AuditFilterRow({required this.controller});

  final AuditController controller;

  Future<void> _pickDate(BuildContext context, RxnString target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      target.value = Formatters.isoDate(picked);
      controller.loadPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 190,
            child: DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: controller.filterAction.value,
              decoration:
                  const InputDecoration(labelText: 'Action', isDense: true),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('All actions')),
                for (final a in AuditController.actions)
                  DropdownMenuItem<String?>(value: a, child: Text(a)),
              ],
              onChanged: (v) {
                controller.filterAction.value = v;
                controller.loadPage(0);
              },
            ),
          ),
          SizedBox(
            width: 190,
            child: DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: controller.filterEntityType.value,
              decoration:
                  const InputDecoration(labelText: 'Entity', isDense: true),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('All entities')),
                for (final e in AuditController.entityTypes)
                  DropdownMenuItem<String?>(value: e, child: Text(e)),
              ],
              onChanged: (v) {
                controller.filterEntityType.value = v;
                controller.loadPage(0);
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickDate(context, controller.filterFrom),
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(controller.filterFrom.value ?? 'From date'),
          ),
          OutlinedButton.icon(
            onPressed: () => _pickDate(context, controller.filterTo),
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(controller.filterTo.value ?? 'To date'),
          ),
          if (controller.filterAction.value != null ||
              controller.filterEntityType.value != null ||
              controller.filterFrom.value != null ||
              controller.filterTo.value != null)
            TextButton.icon(
              onPressed: controller.clearFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}
