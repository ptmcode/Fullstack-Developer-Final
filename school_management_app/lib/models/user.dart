class Role {
  int? id;
  String? name;

  Role({this.id, this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json["id"], name: json["name"]);
  }
}

class User {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? status;
  String? profile;
  List<Role> roles;

  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.status,
    this.profile,
    this.roles = const [],
  });

  String get fullName => "${firstName ?? ""} ${lastName ?? ""}".trim();

  bool get isAdmin => roles.any((role) => role.name == "ROLE_ADMIN");

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json["username"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      status: json["status"],
      profile: json["profile"],
      roles: (json["roles"] as List? ?? [])
          .map((data) => Role.fromJson(data))
          .toList(),
    );
  }

  static List<User> listFromJson(dynamic data) {
    return (data as List? ?? []).map((item) => User.fromJson(item)).toList();
  }
}
