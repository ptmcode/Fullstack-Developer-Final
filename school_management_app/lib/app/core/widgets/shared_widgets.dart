import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Small reusable widgets shared by every module.

/// Colored pill for entity status (ACT / DEL) and other short labels,
/// with an optional leading icon — like the "Promoted ✓" pills in the
/// design reference.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  factory StatusChip.status(String? status) {
    final normalized = (status ?? '').toUpperCase();
    switch (normalized) {
      case 'ACT':
        return const StatusChip(
            label: 'Active',
            color: Color(0xFF16A34A),
            icon: Icons.check_circle_rounded);
      case 'DEL':
        return const StatusChip(
            label: 'Deleted',
            color: Color(0xFFDC2626),
            icon: Icons.cancel_rounded);
      case 'INA':
        return const StatusChip(
            label: 'Inactive',
            color: Color(0xFFD97706),
            icon: Icons.pause_circle_rounded);
      default:
        return StatusChip(label: normalized.isEmpty ? '—' : normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Centered friendly empty state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered error state with retry.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Previous / next pagination bar showing "Page X of Y • N records".
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final int totalElements;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (totalElements == 0) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$totalElements record${totalElements == 1 ? '' : 's'}',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous page',
                onPressed: page > 0 ? onPrevious : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                'Page ${totalPages == 0 ? 0 : page + 1} of $totalPages',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: page < totalPages - 1 ? onNext : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Debounce-friendly search input used on top of list screens.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        isDense: true,
      ),
    );
  }
}

/// Screen title row with optional action buttons.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );

    // Actions drop below the title when horizontal space is tight (phones).
    return LayoutBuilder(
      builder: (context, constraints) {
        if (actions.isNotEmpty && constraints.maxWidth < 460) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              Row(children: actions),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: titleBlock), ...actions],
        );
      },
    );
  }
}

/// Label/value line used in detail panes.
class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13.5)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

/// Circle avatar with user initials.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.text, this.radius = 20});

  final String text;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary.withValues(alpha: .14),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: radius * .8,
        ),
      ),
    );
  }
}

/// Two form fields side by side on wide screens, stacked on phones —
/// dialogs are too narrow there for paired fields.
class ResponsivePair extends StatelessWidget {
  const ResponsivePair({
    super.key,
    required this.first,
    required this.second,
    this.breakpoint = 480,
  });

  final Widget first;
  final Widget second;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < breakpoint) {
      return Column(
        children: [first, const SizedBox(height: 14), second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}

/// Confirmation dialog; resolves to `true` when confirmed.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final context = Get.context;
  if (context == null) return false;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
