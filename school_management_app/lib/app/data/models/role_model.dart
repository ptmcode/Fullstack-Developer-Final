class RoleModel {
  RoleModel({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  final int id;
  final String name;
  final String? description;
  final List<String> permissions;

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        permissions:
            ((json['permissions'] as List?) ?? const []).map((e) => '$e').toList(),
      );
}
