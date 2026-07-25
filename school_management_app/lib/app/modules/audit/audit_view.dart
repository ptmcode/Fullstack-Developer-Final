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
        final scheme = Theme.of(context).colorScheme;
        // Chips + date don't fit one phone row: let the header wrap and show
        // the timestamp in the body instead of `trailing` on compact widths.
        final compact = MediaQuery.sizeOf(context).width < 640;
        final when = Formatters.dateTime(log.createdAt);
        final detail = '${log.detail ?? ''}'
            '${log.entityId != null ? ' (#${log.entityId})' : ''}'
            ' • ${log.ipAddress ?? ''}';
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(Icons.bolt_rounded, color: color, size: 20),
            ),
            title: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(log.username ?? 'system',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                StatusChip(label: log.action ?? '—', color: color),
                if (log.entityType != null) StatusChip(label: log.entityType!),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (compact)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      when,
                      style: TextStyle(
                          fontSize: 11.5, color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
            trailing: compact
                ? null
                : Text(
                    when,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
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
    return Obx(() {
      final actionFilter = DropdownButtonFormField<String?>(
        isExpanded: true,
        initialValue: controller.filterAction.value,
        decoration: const InputDecoration(labelText: 'Action', isDense: true),
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
      );
      final entityFilter = DropdownButtonFormField<String?>(
        isExpanded: true,
        initialValue: controller.filterEntityType.value,
        decoration: const InputDecoration(labelText: 'Entity', isDense: true),
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
      );
      final fromButton = OutlinedButton.icon(
        onPressed: () => _pickDate(context, controller.filterFrom),
        icon: const Icon(Icons.event_rounded, size: 18),
        label: Text(controller.filterFrom.value ?? 'From date',
            overflow: TextOverflow.ellipsis),
      );
      final toButton = OutlinedButton.icon(
        onPressed: () => _pickDate(context, controller.filterTo),
        icon: const Icon(Icons.event_rounded, size: 18),
        label: Text(controller.filterTo.value ?? 'To date',
            overflow: TextOverflow.ellipsis),
      );
      final hasFilters = controller.filterAction.value != null ||
          controller.filterEntityType.value != null ||
          controller.filterFrom.value != null ||
          controller.filterTo.value != null;
      final clearButton = TextButton.icon(
        onPressed: controller.clearFilters,
        icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
        label: const Text('Clear'),
      );

      final compact = MediaQuery.sizeOf(context).width < 640;
      if (compact) {
        // Aligned two-column grid: dropdowns row, then date buttons row.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: actionFilter),
                const SizedBox(width: 10),
                Expanded(child: entityFilter),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: fromButton),
                const SizedBox(width: 10),
                Expanded(child: toButton),
              ],
            ),
            if (hasFilters)
              Align(alignment: Alignment.centerRight, child: clearButton),
          ],
        );
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(width: 190, child: actionFilter),
          SizedBox(width: 190, child: entityFilter),
          fromButton,
          toButton,
          if (hasFilters) clearButton,
        ],
      );
    });
  }
}
