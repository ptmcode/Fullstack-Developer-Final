import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/role_model.dart';
import '../../data/repositories/role_repository.dart';

class RolesController extends GetxController {
  RolesController({required RoleRepository roles}) : _roles = roles;

  final RoleRepository _roles;

  final roles = <RoleModel>[].obs;
  final allPermissions = <String>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final actionBusy = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _roles.listRoles(),
        _roles.listPermissions(),
      ]);
      roles.assignAll(results[0] as List<RoleModel>);
      allPermissions.assignAll((results[1] as List<String>)..sort());
    } on ApiException catch (e) {
      error.value = e.displayMessage;
    } catch (_) {
      error.value = 'Unable to load roles and permissions.';
    } finally {
      loading.value = false;
    }
  }

  /// Groups `resource.action` permission codes by resource for the editor.
  Map<String, List<String>> get groupedPermissions {
    final groups = <String, List<String>>{};
    for (final code in allPermissions) {
      final resource = code.split('.').first;
      groups.putIfAbsent(resource, () => []).add(code);
    }
    return groups;
  }

  Future<bool> savePermissions(RoleModel role, List<String> permissions) async {
    if (actionBusy.value) return false;
    actionBusy.value = true;
    try {
      await _roles.replacePermissions(role.id, permissions);
      AppSnackbar.success('Permissions of ${role.name} updated');
      await load();
      return true;
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
      return false;
    } finally {
      actionBusy.value = false;
    }
  }
}
