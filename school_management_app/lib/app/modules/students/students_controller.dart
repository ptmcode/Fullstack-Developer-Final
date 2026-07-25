
import '../../core/base/paged_list_controller.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentsController extends PagedListController<StudentModel> {
  StudentsController({required StudentRepository students}) : _students = students;

  final StudentRepository _students;

  @override
  Future<PagedData<StudentModel>> fetchPage(int page, String search) =>
      _students.list(page: page, size: pageSize, search: search);

  /// Create (`id == null`) or update a student. Returns true when the dialog
  /// may close.
  Future<bool> save({int? id, required Map<String, dynamic> body}) => runAction(
        () => id == null ? _students.create(body) : _students.update(id, body),
        successMessage: id == null ? 'Student created' : 'Student updated',
      );

  Future<void> deleteStudent(StudentModel student) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete student',
      message: 'Delete ${student.fullName} (${student.studentCode})? '
          'The record is soft-deleted; enrollment and grade history stays.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await runAction(() => _students.deleteStudent(student.id));
  }
}
