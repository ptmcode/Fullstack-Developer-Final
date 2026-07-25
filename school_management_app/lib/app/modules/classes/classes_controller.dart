import 'package:get/get.dart';

import '../../core/base/paged_list_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/school_class_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/teacher_repository.dart';

class ClassesController extends PagedListController<SchoolClassModel> {
  ClassesController({
    required ClassRepository classes,
    required TeacherRepository teachers,
    required StudentRepository students,
    required EnrollmentRepository enrollments,
  })  : _classes = classes,
        _teachers = teachers,
        _students = students,
        _enrollments = enrollments;

  final ClassRepository _classes;
  final TeacherRepository _teachers;
  final StudentRepository _students;
  final EnrollmentRepository _enrollments;

  /// Dropdown options for the form / enroll dialogs.
  final teacherOptions = <TeacherModel>[].obs;
  final studentOptions = <StudentModel>[].obs;

  /// Enrollments of the class currently opened in the roster dialog.
  final rosterClassId = RxnInt();
  final roster = <EnrollmentModel>[].obs;
  final rosterLoading = false.obs;

  @override
  Future<PagedData<SchoolClassModel>> fetchPage(int page, String search) =>
      _classes.list(page: page, size: pageSize, search: search);

  Future<void> ensureTeacherOptions() async {
    if (teacherOptions.isNotEmpty) return;
    final page = await _teachers.list(page: 0, size: 100, sort: 'firstName,asc');
    teacherOptions.assignAll(page.content);
  }

  Future<void> ensureStudentOptions() async {
    if (studentOptions.isNotEmpty) return;
    final page = await _students.list(page: 0, size: 100, sort: 'firstName,asc');
    studentOptions.assignAll(page.content);
  }

  Future<bool> save({int? id, required Map<String, dynamic> body}) => runAction(
        () => id == null ? _classes.create(body) : _classes.update(id, body),
        successMessage: id == null ? 'Class created' : 'Class updated',
      );

  Future<void> deleteClass(SchoolClassModel schoolClass) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete class',
      message: 'Delete ${schoolClass.name} (${schoolClass.classCode})?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await runAction(() => _classes.deleteClass(schoolClass.id));
  }

  // --- Roster dialog -----------------------------------------------------

  Future<void> loadRoster(int classId) async {
    rosterClassId.value = classId;
    rosterLoading.value = true;
    try {
      roster.assignAll(await _classes.enrollments(classId));
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      rosterLoading.value = false;
    }
  }

  Future<bool> enrollStudent(int studentId) async {
    final classId = rosterClassId.value;
    if (classId == null) return false;
    final ok = await runAction(
      () => _enrollments.enroll(studentId: studentId, classId: classId),
      successMessage: 'Student enrolled',
      reloadAfter: false,
    );
    if (ok) await loadRoster(classId);
    return ok;
  }

  Future<void> removeFromRoster(EnrollmentModel enrollment) async {
    final confirmed = await showConfirmDialog(
      title: 'Remove enrollment',
      message: 'Remove ${enrollment.studentName ?? 'this student'} from the class?',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    final ok = await runAction(
      () => _enrollments.remove(enrollment.id),
      reloadAfter: false,
    );
    if (ok && rosterClassId.value != null) await loadRoster(rosterClassId.value!);
  }
}
