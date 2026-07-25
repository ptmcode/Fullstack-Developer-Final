import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/paged_data.dart';
import '../network/api_exception.dart';
import '../widgets/app_snackbar.dart';

/// Base controller for every paginated + searchable list screen
/// (students, teachers, subjects, classes, users, enrollments, audit logs).
///
/// Subclasses implement [fetchPage]; everything else — loading flags,
/// debounced search, page navigation, pull-to-refresh and error handling —
/// is shared here.
abstract class PagedListController<T> extends GetxController {
  final items = <T>[].obs;
  final loading = false.obs;
  final error = RxnString();

  final page = 0.obs;
  final totalPages = 0.obs;
  final totalElements = 0.obs;

  final searchQuery = ''.obs;
  Timer? _debounce;

  int get pageSize => 10;

  Future<PagedData<T>> fetchPage(int page, String search);

  @override
  void onInit() {
    super.onInit();
    loadPage(0);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadPage(int target) async {
    loading.value = true;
    error.value = null;
    try {
      final result = await fetchPage(target, searchQuery.value.trim());
      items.assignAll(result.content);
      page.value = result.page;
      totalPages.value = result.totalPages;
      totalElements.value = result.totalElements;
    } on ApiException catch (e) {
      error.value = e.displayMessage;
    } catch (_) {
      error.value = 'Something went wrong while loading data.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> reload() => loadPage(page.value);

  void nextPage() {
    if (page.value < totalPages.value - 1) loadPage(page.value + 1);
  }

  void previousPage() {
    if (page.value > 0) loadPage(page.value - 1);
  }

  /// Debounced full-text search; resets to the first page.
  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => loadPage(0));
  }

  /// Runs a mutating action (create / update / delete), surfaces the outcome
  /// in a snackbar and reloads the current page on success.
  final actionBusy = false.obs;

  Future<bool> runAction(
    Future<Object?> Function() action, {
    String? successMessage,
    bool reloadAfter = true,
  }) async {
    if (actionBusy.value) return false;
    actionBusy.value = true;
    try {
      final result = await action();
      final message = successMessage ??
          (result is String && result.isNotEmpty ? result : 'Saved successfully');
      AppSnackbar.success(message);
      if (reloadAfter) await reload();
      return true;
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
      return false;
    } catch (_) {
      AppSnackbar.error('Something went wrong. Please try again.');
      return false;
    } finally {
      actionBusy.value = false;
    }
  }
}
