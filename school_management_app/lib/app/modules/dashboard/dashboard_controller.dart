import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController({required DashboardRepository dashboard})
      : _dashboard = dashboard;

  final DashboardRepository _dashboard;

  final summary = Rxn<DashboardSummaryModel>();
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      summary.value = await _dashboard.summary();
    } on ApiException catch (e) {
      error.value = e.displayMessage;
    } catch (e, s) {
      assert(() {
        // Surface unexpected errors during development.
        // ignore: avoid_print
        print('Dashboard load failed: $e\n$s');
        return true;
      }());
      error.value = 'Unable to load the dashboard.';
    } finally {
      loading.value = false;
    }
  }
}
