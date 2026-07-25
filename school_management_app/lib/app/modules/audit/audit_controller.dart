import 'package:get/get.dart';

import '../../core/base/paged_list_controller.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/models/paged_data.dart';
import '../../data/repositories/audit_repository.dart';

class AuditController extends PagedListController<AuditLogModel> {
  AuditController({required AuditRepository audit}) : _audit = audit;

  final AuditRepository _audit;

  static const actions = [
    'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE',
    'UPDATE_ROLES', 'CHANGE_PASSWORD', 'FORGOT_PASSWORD', 'RESET_PASSWORD',
  ];

  static const entityTypes = [
    'AUTH', 'USER', 'ROLE', 'STUDENT', 'TEACHER',
    'SUBJECT', 'CLASS', 'ENROLLMENT', 'GRADE',
  ];

  final filterAction = RxnString();
  final filterEntityType = RxnString();
  final filterFrom = RxnString(); // YYYY-MM-DD
  final filterTo = RxnString();

  @override
  int get pageSize => 15;

  @override
  Future<PagedData<AuditLogModel>> fetchPage(int page, String search) =>
      _audit.search(
        username: search,
        action: filterAction.value ?? '',
        entityType: filterEntityType.value ?? '',
        from: filterFrom.value ?? '',
        to: filterTo.value ?? '',
        page: page,
        size: pageSize,
      );

  void applyFilters({String? action, String? entityType, String? from, String? to}) {
    filterAction.value = action;
    filterEntityType.value = entityType;
    filterFrom.value = from;
    filterTo.value = to;
    loadPage(0);
  }

  void clearFilters() {
    filterAction.value = null;
    filterEntityType.value = null;
    filterFrom.value = null;
    filterTo.value = null;
    loadPage(0);
  }
}
