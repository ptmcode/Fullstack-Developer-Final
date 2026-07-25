
import 'package:get/get.dart';

import '../../core/base/paged_list_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/export_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentsController extends PagedListController<StudentModel> {
  StudentsController({required StudentRepository students}) : _students = students;

  final StudentRepository _students;

  final exporting = false.obs;

  @override
  Future<PagedData<StudentModel>> fetchPage(int page, String search) =>
      _students.list(page: page, size: pageSize, search: search);

  /// Fetches the full student list (up to 500) for exports, honoring the
  /// current search filter.
  Future<List<StudentModel>> _allStudents() async {
    final page = await _students.list(
        page: 0, size: 500, search: searchQuery.value.trim());
    return page.content;
  }

  Future<void> exportPdf() => _export(() async {
        final bytes = await ExportService.buildStudentsPdf(await _allStudents());
        await ExportService.saveAndOpenPdf(bytes, 'students.pdf');
      });

  Future<void> exportExcel() => _export(() async {
        final bytes = ExportService.buildStudentsExcel(await _allStudents());
        await ExportService.saveAndOpenExcel(bytes, 'students.xlsx');
      });

  Future<void> _export(Future<void> Function() run) async {
    if (exporting.value) return;
    exporting.value = true;
    try {
      await run();
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } catch (e) {
      AppSnackbar.error('Export failed: $e');
    } finally {
      exporting.value = false;
    }
  }

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
