import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/school_class_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../../data/repositories/grade_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/subject_repository.dart';

/// Backs the student detail screen: profile, enrollments and grades,
/// plus every grade / enrollment mutation launched from there.
class StudentDetailController extends GetxController {
  StudentDetailController({
    required StudentRepository students,
    required EnrollmentRepository enrollments,
    required GradeRepository grades,
    required ClassRepository classes,
    required SubjectRepository subjects,
  })  : _students = students,
        _enrollments = enrollments,
        _grades = grades,
        _classes = classes,
        _subjects = subjects;

  final StudentRepository _students;
  final EnrollmentRepository _enrollments;
  final GradeRepository _grades;
  final ClassRepository _classes;
  final SubjectRepository _subjects;

  late final Rx<StudentModel> student;

  final enrollmentList = <EnrollmentModel>[].obs;
  final gradeList = <GradeModel>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final actionBusy = false.obs;

  /// Dropdown data, loaded lazily for the dialogs.
  final classOptions = <SchoolClassModel>[].obs;
  final subjectOptions = <SubjectModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    student = Rx<StudentModel>(Get.arguments as StudentModel);
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _students.getById(student.value.id),
        _students.enrollments(student.value.id),
        _students.grades(student.value.id),
      ]);
      student.value = results[0] as StudentModel;
      enrollmentList.assignAll(results[1] as List<EnrollmentModel>);
      gradeList.assignAll(results[2] as List<GradeModel>);
    } on ApiException catch (e) {
      error.value = e.displayMessage;
    } catch (_) {
      error.value = 'Unable to load student details.';
    } finally {
      loading.value = false;
    }
  }

  /// Class options for the enroll dialog (first 100 classes).
  Future<void> ensureClassOptions() async {
    if (classOptions.isNotEmpty) return;
    final page = await _classes.list(page: 0, size: 100, sort: 'name,asc');
    classOptions.assignAll(page.content);
  }

  /// Subject options for the grade dialog (first 100 subjects).
  Future<void> ensureSubjectOptions() async {
    if (subjectOptions.isNotEmpty) return;
    final page = await _subjects.list(page: 0, size: 100, sort: 'name,asc');
    subjectOptions.assignAll(page.content);
  }

  Future<bool> _run(Future<Object?> Function() action, [String? success]) async {
    if (actionBusy.value) return false;
    actionBusy.value = true;
    try {
      final result = await action();
      AppSnackbar.success(
        success ?? (result is String && result.isNotEmpty ? result : 'Saved'),
      );
      await load();
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

  Future<bool> enroll(int classId) => _run(
        () => _enrollments.enroll(studentId: student.value.id, classId: classId),
        'Student enrolled',
      );

  Future<void> removeEnrollment(EnrollmentModel enrollment) async {
    final confirmed = await showConfirmDialog(
      title: 'Remove enrollment',
      message: 'Remove ${student.value.fullName} from '
          '${enrollment.className ?? 'this class'}? Grades are preserved.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    await _run(() => _enrollments.remove(enrollment.id), 'Enrollment removed');
  }

  Future<bool> saveGrade({
    int? gradeId,
    required int enrollmentId,
    required int subjectId,
    required double score,
    required String term,
  }) =>
      _run(
        () => gradeId == null
            ? _grades.record(
                enrollmentId: enrollmentId,
                subjectId: subjectId,
                score: score,
                term: term,
              )
            : _grades.update(
                gradeId,
                enrollmentId: enrollmentId,
                subjectId: subjectId,
                score: score,
                term: term,
              ),
        gradeId == null ? 'Grade recorded' : 'Grade updated',
      );

  Future<void> deleteGrade(GradeModel grade) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete grade',
      message: 'Delete the ${grade.subjectName ?? ''} '
          '(${Formatters.term(grade.term)}) grade?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await _run(() => _grades.deleteGrade(grade.id), 'Grade deleted');
  }
}
