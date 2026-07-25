import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../base/paged_list_controller.dart';
import 'shared_widgets.dart';

/// Standard layout for a paginated list screen:
/// header (+ actions) → search / filter row → list → pagination bar.
///
/// Works with any [PagedListController]; keeps every module's list screen
/// visually and behaviorally identical.
class ListPageScaffold<T> extends StatelessWidget {
  const ListPageScaffold({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.itemBuilder,
    this.searchHint,
    this.headerActions = const [],
    this.filterRow,
    this.emptyMessage = 'Nothing here yet',
    this.emptyIcon = Icons.inbox_rounded,
  });

  final PagedListController<T> controller;
  final String title;
  final String subtitle;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String? searchHint;
  final List<Widget> headerActions;

  /// Optional extra filters rendered under the search field.
  final Widget? filterRow;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 20, compact ? 12 : 20,
          compact ? 16 : 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // On phones the app bar already shows the section title; repeat it
          // here only on wide screens and keep just the action button compact.
          if (!compact)
            PageHeader(title: title, subtitle: subtitle, actions: headerActions)
          else if (headerActions.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                ...headerActions,
              ],
            )
          else
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          SizedBox(height: compact ? 12 : 16),
          if (searchHint != null)
            SearchField(hint: searchHint!, onChanged: controller.onSearchChanged),
          if (filterRow != null) ...[
            const SizedBox(height: 12),
            filterRow!,
          ],
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value != null && controller.items.isEmpty) {
                return ErrorState(
                  message: controller.error.value!,
                  onRetry: controller.reload,
                );
              }
              if (controller.items.isEmpty) {
                return EmptyState(icon: emptyIcon, message: emptyMessage);
              }
              return RefreshIndicator(
                onRefresh: controller.reload,
                child: Stack(
                  children: [
                    ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          itemBuilder(context, controller.items[index]),
                    ),
                    if (controller.loading.value)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                ),
              );
            }),
          ),
          Obx(
            () => PaginationBar(
              page: controller.page.value,
              totalPages: controller.totalPages.value,
              totalElements: controller.totalElements.value,
              onPrevious: controller.previousPage,
              onNext: controller.nextPage,
            ),
          ),
        ],
      ),
    );
  }
}
