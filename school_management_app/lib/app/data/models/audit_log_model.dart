/// The backend serializes `entityId` sometimes as a number and sometimes as
/// a string (e.g. "15"), so numeric fields here are parsed leniently.
int? _asInt(Object? value) => switch (value) {
      null => null,
      num n => n.toInt(),
      String s => int.tryParse(s),
      _ => null,
    };

class AuditLogModel {
  AuditLogModel({
    required this.id,
    this.userId,
    this.username,
    this.action,
    this.entityType,
    this.entityId,
    this.detail,
    this.ipAddress,
    this.createdAt,
  });

  final int id;
  final int? userId;
  final String? username;
  final String? action;
  final String? entityType;
  final int? entityId;
  final String? detail;
  final String? ipAddress;
  final DateTime? createdAt;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel(
        id: _asInt(json['id']) ?? 0,
        userId: _asInt(json['userId']),
        username: json['username'] as String?,
        action: json['action'] as String?,
        entityType: json['entityType'] as String?,
        entityId: _asInt(json['entityId']),
        detail: json['detail'] as String?,
        ipAddress: json['ipAddress'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}
