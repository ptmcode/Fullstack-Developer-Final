import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRepository {
  DashboardRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<DashboardSummaryModel> summary() async {
    final envelope = await _api.get(ApiConstants.dashboardSummary);
    return DashboardSummaryModel.fromJson(envelope.dataAsMap);
  }
}
