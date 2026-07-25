import 'package:get/get.dart';

import '../../core/base/paged_list_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/enrollment_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/school_class_model.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/enrollment_repository.dart';
import '../../data/repositories/student_repository.dart';

class EnrollmentsController extends PagedListController<EnrollmentModel> {
  EnrollmentsController({
    required EnrollmentRepository enrollments,
    required StudentRepository students,
    required ClassRepository classes,
  })  : _enrollments = enrollments,
        _students = students,
        _classes = classes;

  final EnrollmentRepository _enrollments;
  final StudentRepository _students;
  final ClassRepository _classes;

  /// Filters (null = all).
  final filterStudentId = RxnInt();
  final filterClassId = RxnInt();

  /// Dropdown options shared by the filter row and the enroll dialog.
  final studentOptions = <StudentModel>[].obs;
  final classOptions = <SchoolClassModel>[].obs;

  /// Grades shown in the per-enrollment grades dialog.
  final gradesFor = Rxn<EnrollmentModel>();
  final grades = <GradeModel>[].obs;
  final gradesLoading = false.obs;

  @override
  Future<PagedData<EnrollmentModel>> fetchPage(int page, String search) =>
      _enrollments.list(
        page: page,
        size: pageSize,
        studentId: filterStudentId.value,
        classId: filterClassId.value,
      );

  @override
  void onInit() {
    super.onInit();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        _students.list(page: 0, size: 100, sort: 'firstName,asc'),
        _classes.list(page: 0, size: 100, sort: 'name,asc'),
      ]);
      studentOptions
          .assignAll((results[0] as PagedData<StudentModel>).content);
      classOptions.assignAll((results[1] as PagedData<SchoolClassModel>).content);
    } catch (_) {
      // Filters simply stay empty when options cannot be loaded.
    }
  }

  void setStudentFilter(int? id) {
    filterStudentId.value = id;
    loadPage(0);
  }

  void setClassFilter(int? id) {
    filterClassId.value = id;
    loadPage(0);
  }

  Future<bool> enroll({required int studentId, required int classId}) =>
      runAction(
        () => _enrollments.enroll(studentId: studentId, classId: classId),
        successMessage: 'Student enrolled',
      );

  Future<void> removeEnrollment(EnrollmentModel enrollment) async {
    final confirmed = await showConfirmDialog(
      title: 'Remove enrollment',
      message: 'Remove ${enrollment.studentName ?? 'student'} from '
          '${enrollment.className ?? 'class'}? Grades are preserved.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    await runAction(() => _enrollments.remove(enrollment.id));
  }

  Future<void> loadGrades(EnrollmentModel enrollment) async {
    gradesFor.value = enrollment;
    gradesLoading.value = true;
    try {
      grades.assignAll(await _enrollments.grades(enrollment.id));
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      gradesLoading.value = false;
    }
  }
}
