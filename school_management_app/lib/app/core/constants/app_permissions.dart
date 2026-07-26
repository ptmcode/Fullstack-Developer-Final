/// Permission codes used by the backend (`resource.action`).
///
/// The UI hides or disables every action the signed-in user is not allowed
/// to perform; the backend enforces the same rules with HTTP 403.
class AppPermissions {
  AppPermissions._();

  static const dashboardRead = 'dashboard.read';

  static const studentCreate = 'student.create';
  static const studentRead = 'student.read';
  static const studentUpdate = 'student.update';
  static const studentDelete = 'student.delete';

  static const teacherCreate = 'teacher.create';
  static const teacherRead = 'teacher.read';
  static const teacherUpdate = 'teacher.update';
  static const teacherDelete = 'teacher.delete';

  static const subjectCreate = 'subject.create';
  static const subjectRead = 'subject.read';
  static const subjectUpdate = 'subject.update';
  static const subjectDelete = 'subject.delete';

  static const classCreate = 'class.create';
  static const classRead = 'class.read';
  static const classUpdate = 'class.update';
  static const classDelete = 'class.delete';

  static const enrollmentCreate = 'enrollment.create';
  static const enrollmentRead = 'enrollment.read';
  static const enrollmentUpdate = 'enrollment.update';
  static const enrollmentDelete = 'enrollment.delete';

  static const gradeCreate = 'grade.create';
  static const gradeRead = 'grade.read';
  static const gradeUpdate = 'grade.update';
  static const gradeDelete = 'grade.delete';

  static const userCreate = 'user.create';
  static const userRead = 'user.read';
  static const userUpdate = 'user.update';
  static const userDelete = 'user.delete';

  static const roleCreate = 'role.create';
  static const roleRead = 'role.read';
  static const roleUpdate = 'role.update';
  static const roleDelete = 'role.delete';

  static const auditRead = 'audit.read';

  static const notificationRead = 'notification.read';
  static const notificationSend = 'notification.send';
}
