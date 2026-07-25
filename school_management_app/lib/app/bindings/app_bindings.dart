import 'package:get/get.dart';

import '../core/network/api_client.dart';
import '../core/services/preferences_service.dart';
import '../core/services/session_service.dart';
import '../core/services/token_storage_service.dart';
import '../data/repositories/audit_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/class_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/enrollment_repository.dart';
import '../data/repositories/grade_repository.dart';
import '../data/repositories/role_repository.dart';
import '../data/repositories/student_repository.dart';
import '../data/repositories/subject_repository.dart';
import '../data/repositories/teacher_repository.dart';
import '../data/repositories/user_repository.dart';
import '../modules/audit/audit_controller.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/classes/classes_controller.dart';
import '../modules/dashboard/dashboard_controller.dart';
import '../modules/enrollments/enrollments_controller.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/roles/roles_controller.dart';
import '../modules/shell/shell_controller.dart';
import '../modules/splash/splash_controller.dart';
import '../modules/students/student_detail_controller.dart';
import '../modules/students/students_controller.dart';
import '../modules/subjects/subjects_controller.dart';
import '../modules/teachers/teachers_controller.dart';
import '../modules/users/users_controller.dart';

/// Repositories are registered once and shared. `fenix: true` recreates a
/// repository if it was ever disposed (e.g. after a full sign-out cycle).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.find<ApiClient>();

    Get.lazyPut(() => AuthRepository(api: api, tokens: Get.find<TokenStorageService>()),
        fenix: true);
    Get.lazyPut(() => UserRepository(api: api), fenix: true);
    Get.lazyPut(() => RoleRepository(api: api), fenix: true);
    Get.lazyPut(() => StudentRepository(api: api), fenix: true);
    Get.lazyPut(() => TeacherRepository(api: api), fenix: true);
    Get.lazyPut(() => SubjectRepository(api: api), fenix: true);
    Get.lazyPut(() => ClassRepository(api: api), fenix: true);
    Get.lazyPut(() => EnrollmentRepository(api: api), fenix: true);
    Get.lazyPut(() => GradeRepository(api: api), fenix: true);
    Get.lazyPut(() => DashboardRepository(api: api), fenix: true);
    Get.lazyPut(() => AuditRepository(api: api), fenix: true);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // put (not lazyPut): the splash view never *reads* the controller, so it
    // must be created eagerly for its bootstrap logic in onReady() to run.
    Get.put(SplashController(
      tokens: Get.find<TokenStorageService>(),
      session: Get.find<SessionService>(),
      users: Get.find<UserRepository>(),
    ));
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(
          auth: Get.find<AuthRepository>(),
          session: Get.find<SessionService>(),
          preferences: Get.find<PreferencesService>(),
        ));
  }
}

/// Registers the shell plus every feature controller lazily — a controller
/// is only created the first time its page becomes visible.
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShellController(
          session: Get.find<SessionService>(),
          preferences: Get.find<PreferencesService>(),
          auth: Get.find<AuthRepository>(),
        ));
    Get.lazyPut(() => DashboardController(dashboard: Get.find<DashboardRepository>()));
    Get.lazyPut(() => StudentsController(students: Get.find<StudentRepository>()));
    Get.lazyPut(() => TeachersController(teachers: Get.find<TeacherRepository>()));
    Get.lazyPut(() => SubjectsController(subjects: Get.find<SubjectRepository>()));
    Get.lazyPut(() => ClassesController(
          classes: Get.find<ClassRepository>(),
          teachers: Get.find<TeacherRepository>(),
          students: Get.find<StudentRepository>(),
          enrollments: Get.find<EnrollmentRepository>(),
        ));
    Get.lazyPut(() => EnrollmentsController(
          enrollments: Get.find<EnrollmentRepository>(),
          students: Get.find<StudentRepository>(),
          classes: Get.find<ClassRepository>(),
        ));
    Get.lazyPut(() => UsersController(
          users: Get.find<UserRepository>(),
          roles: Get.find<RoleRepository>(),
        ));
    Get.lazyPut(() => RolesController(roles: Get.find<RoleRepository>()));
    Get.lazyPut(() => AuditController(audit: Get.find<AuditRepository>()));
    Get.lazyPut(() => ProfileController(
          users: Get.find<UserRepository>(),
          session: Get.find<SessionService>(),
        ));
  }
}

class StudentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentDetailController(
          students: Get.find<StudentRepository>(),
          enrollments: Get.find<EnrollmentRepository>(),
          grades: Get.find<GradeRepository>(),
          classes: Get.find<ClassRepository>(),
          subjects: Get.find<SubjectRepository>(),
        ));
  }
}
