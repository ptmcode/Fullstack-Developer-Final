
import '../../core/base/paged_list_controller.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/paged_data.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';

class SubjectsController extends PagedListController<SubjectModel> {
  SubjectsController({required SubjectRepository subjects}) : _subjects = subjects;

  final SubjectRepository _subjects;

  @override
  Future<PagedData<SubjectModel>> fetchPage(int page, String search) =>
      _subjects.list(page: page, size: pageSize, search: search);

  Future<bool> save({int? id, required Map<String, dynamic> body}) => runAction(
        () => id == null ? _subjects.create(body) : _subjects.update(id, body),
        successMessage: id == null ? 'Subject created' : 'Subject updated',
      );

  Future<void> deleteSubject(SubjectModel subject) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete subject',
      message: 'Delete ${subject.name} (${subject.subjectCode})?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await runAction(() => _subjects.deleteSubject(subject.id));
  }
}
