/// An in-app notification from the backend inbox (`/notifications`).
///
/// `entityId` arrives as a string for entity-linked rows (same backend
/// quirk as audit logs), so it is parsed leniently.
class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    this.type,
    this.entityType,
    this.entityId,
    this.sentStatus,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final bool read;

  /// GRADE, ENROLLMENT, ANNOUNCEMENT…
  final String? type;
  final String? entityType;
  final int? entityId;

  /// SENT / SKIPPED / FAILED — whether the push itself reached a device.
  final String? sentStatus;
  final DateTime? createdAt;

  static int? _asInt(Object? value) => switch (value) {
        null => null,
        num n => n.toInt(),
        String s => int.tryParse(s),
        _ => null,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: _asInt(json['id']) ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        read: json['read'] as bool? ?? false,
        type: json['type'] as String?,
        entityType: json['entityType'] as String?,
        entityId: _asInt(json['entityId']),
        sentStatus: json['sentStatus'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  NotificationModel copyWith({bool? read}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        read: read ?? this.read,
        type: type,
        entityType: entityType,
        entityId: entityId,
        sentStatus: sentStatus,
        createdAt: createdAt,
      );
}

/// A device registered for push delivery (`/devices`).
class DeviceModel {
  DeviceModel({
    required this.id,
    required this.token,
    this.deviceType,
    this.deviceName,
    this.status,
  });

  final int id;
  final String token;
  final String? deviceType;
  final String? deviceName;
  final String? status;

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        token: json['token'] as String? ?? '',
        deviceType: json['deviceType'] as String?,
        deviceName: json['deviceName'] as String?,
        status: json['status'] as String?,
      );
}

/// Result of `POST /notifications/send`.
class SendResultModel {
  SendResultModel({
    required this.recipients,
    required this.devicesReached,
    required this.pushEnabled,
  });

  final int recipients;
  final int devicesReached;
  final bool pushEnabled;

  factory SendResultModel.fromJson(Map<String, dynamic> json) =>
      SendResultModel(
        recipients: (json['recipients'] as num?)?.toInt() ?? 0,
        devicesReached: (json['devicesReached'] as num?)?.toInt() ?? 0,
        pushEnabled: json['pushEnabled'] as bool? ?? false,
      );

  /// Message for the confirmation snackbar, explaining dry-run mode when the
  /// backend has no Firebase service account configured.
  String get summary {
    final people = '$recipients recipient${recipients == 1 ? '' : 's'}';
    if (!pushEnabled) {
      return 'Saved to $people (push delivery is in dry-run mode)';
    }
    if (devicesReached == 0) {
      return 'Saved to $people — no registered devices to push to';
    }
    return 'Sent to $people on $devicesReached device'
        '${devicesReached == 1 ? '' : 's'}';
  }
}
