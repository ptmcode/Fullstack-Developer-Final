
import '../../core/base/paged_list_controller.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeachersController extends PagedListController<TeacherModel> {
  TeachersController({required TeacherRepository teachers}) : _teachers = teachers;

  final TeacherRepository _teachers;

  @override
  Future<PagedData<TeacherModel>> fetchPage(int page, String search) =>
      _teachers.list(page: page, size: pageSize, search: search);

  Future<bool> save({int? id, required Map<String, dynamic> body}) => runAction(
        () => id == null ? _teachers.create(body) : _teachers.update(id, body),
        successMessage: id == null ? 'Teacher created' : 'Teacher updated',
      );

  Future<void> deleteTeacher(TeacherModel teacher) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete teacher',
      message: 'Delete ${teacher.fullName} (${teacher.teacherCode})?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await runAction(() => _teachers.deleteTeacher(teacher.id));
  }
}
