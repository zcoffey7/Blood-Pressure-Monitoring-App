/// Model representing a health alert
/// Follows SRP - Only responsible for alert data structure
///
/// Stored in Firestore at: users/{userId}/alerts/{alertId}
class HealthAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime createdAt;
  final bool isRead;
  final bool isDismissed;

  /// Optional: associated data (e.g., BP reading that triggered the alert)
  final Map<String, dynamic>? metadata;

  const HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.createdAt,
    this.isRead = false,
    this.isDismissed = false,
    this.metadata,
  });

  /// Factory constructor for JSON serialization
  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: AlertType.values.byName(json['type'] as String),
      severity: AlertSeverity.values.byName(json['severity'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isDismissed: json['isDismissed'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'severity': severity.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isDismissed': isDismissed,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Copy with method for immutability
  HealthAlert copyWith({
    String? id,
    String? title,
    String? message,
    AlertType? type,
    AlertSeverity? severity,
    DateTime? createdAt,
    bool? isRead,
    bool? isDismissed,
    Map<String, dynamic>? metadata,
  }) {
    return HealthAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'HealthAlert(id: $id, type: $type, severity: $severity, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthAlert &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.severity == severity;
  }

  @override
  int get hashCode => Object.hash(id, title, type, severity);
}

/// Types of health alerts
enum AlertType {
  highBloodPressure, // BP reading above threshold
  lowBloodPressure, // BP reading below threshold
  criticalBloodPressure, // Hypertensive crisis level
  missedCheckIn, // No symptom check-in for the day
  irregularHeartRate, // Heart rate outside normal range
  deviceDisconnected, // Monitoring device lost connection
  general, // General health reminder
}

/// Alert severity levels
enum AlertSeverity {
  info, // Informational
  warning, // Needs attention
  urgent, // Requires prompt action
  critical, // Requires immediate action
}
