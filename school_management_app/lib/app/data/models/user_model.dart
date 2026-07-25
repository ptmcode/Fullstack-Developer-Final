/// A system user (admin / teacher / student account) with roles and the
/// flattened permission codes derived from those roles.
class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.status,
    this.roles = const [],
    this.permissions = const [],
    this.createdAt,
  });

  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? status;
  final List<String> roles;
  final List<String> permissions;
  final DateTime? createdAt;

  String get fullName {
    final name = [firstName, lastName].where((p) => p != null && p.isNotEmpty).join(' ');
    return name.isEmpty ? username : name;
  }

  String get initials {
    final source = fullName.trim();
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  bool hasPermission(String code) => permissions.contains(code);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        status: json['status'] as String?,
        roles: ((json['roles'] as List?) ?? const []).map((e) => '$e').toList(),
        permissions:
            ((json['permissions'] as List?) ?? const []).map((e) => '$e').toList(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'status': status,
        'roles': roles,
        'permissions': permissions,
        'createdAt': createdAt?.toIso8601String(),
      };
}

/// Result of a successful login: the token pair plus the signed-in profile.
class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
        user: UserModel.fromJson((json['user'] as Map).cast<String, dynamic>()),
      );
}
