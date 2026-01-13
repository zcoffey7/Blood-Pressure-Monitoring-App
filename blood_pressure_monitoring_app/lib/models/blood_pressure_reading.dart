/// Model representing a single blood pressure reading
/// Follows SRP - Only responsible for data structure
class BloodPressureReading {
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime timestamp;
  final BloodPressureStatus status;

  const BloodPressureReading({
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.timestamp,
    required this.status,
  });

  /// Factory constructor for creating from JSON (Firebase/API ready)
  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      heartRate: json['heartRate'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: BloodPressureStatus.values.byName(json['status'] as String),
    );
  }

  /// Convert to JSON (Firebase/API ready)
  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
    };
  }

  /// Copy with method for immutability
  BloodPressureReading copyWith({
    int? systolic,
    int? diastolic,
    int? heartRate,
    DateTime? timestamp,
    BloodPressureStatus? status,
  }) {
    return BloodPressureReading(
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'BloodPressureReading(systolic: $systolic, diastolic: $diastolic, heartRate: $heartRate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodPressureReading &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.heartRate == heartRate &&
        other.timestamp == timestamp &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(systolic, diastolic, heartRate, timestamp, status);
  }
}

/// Blood pressure status classification
/// Based on American Heart Association guidelines
enum BloodPressureStatus {
  low, // Hypotension
  normal, // Normal range
  elevated, // Elevated
  high, // Hypertension Stage 1 or 2
  critical, // Hypertensive Crisis
}
