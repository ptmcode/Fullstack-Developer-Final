import 'package:simple_state_management_app/models/user.dart';

class Session {
  static String? accessToken;
  static String? refreshToken;
  static User? currentUser;

  static void clear() {
    accessToken = null;
    refreshToken = null;
    currentUser = null;
  }
}
