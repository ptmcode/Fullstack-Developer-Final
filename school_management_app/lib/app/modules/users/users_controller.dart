import 'package:get/get.dart';

import '../../core/base/paged_list_controller.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/role_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/role_repository.dart';
import '../../data/repositories/user_repository.dart';

class UsersController extends PagedListController<UserModel> {
  UsersController({required UserRepository users, required RoleRepository roles})
      : _users = users,
        _roles = roles;

  final UserRepository _users;
  final RoleRepository _roles;

  final roleOptions = <RoleModel>[].obs;

  @override
  Future<PagedData<UserModel>> fetchPage(int page, String search) =>
      _users.list(page: page, size: pageSize, search: search);

  Future<void> ensureRoleOptions() async {
    if (roleOptions.isNotEmpty) return;
    roleOptions.assignAll(await _roles.listRoles());
  }

  Future<bool> save({int? id, required Map<String, dynamic> body}) => runAction(
        () => id == null ? _users.create(body) : _users.update(id, body),
        successMessage: id == null ? 'User created' : 'User updated',
      );

  Future<bool> assignRoles(int id, List<String> roles) => runAction(
        () => _users.assignRoles(id, roles),
        successMessage: 'Roles updated',
      );

  Future<void> deleteUser(UserModel user) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete user',
      message: 'Delete ${user.username}? The account is soft-deleted and can '
          'no longer sign in; refresh tokens are revoked.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await runAction(() => _users.deleteUser(user.id));
  }
}
