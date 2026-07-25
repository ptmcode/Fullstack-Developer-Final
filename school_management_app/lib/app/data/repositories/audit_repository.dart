import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/audit_log_model.dart';
import '../models/paged_data.dart';

class AuditRepository {
  AuditRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<PagedData<AuditLogModel>> search({
    String username = '',
    String action = '',
    String entityType = '',
    String from = '',
    String to = '',
    int page = 0,
    int size = 15,
    String sort = 'id,desc',
  }) async {
    final envelope = await _api.get(ApiConstants.auditLogs, query: {
      'username': username,
      'action': action,
      'entityType': entityType,
      if (from.isNotEmpty) 'from': from,
      if (to.isNotEmpty) 'to': to,
      'page': '$page',
      'size': '$size',
      'sort': sort,
    });
    return PagedData.fromJson(envelope.dataAsMap, AuditLogModel.fromJson);
  }
}
