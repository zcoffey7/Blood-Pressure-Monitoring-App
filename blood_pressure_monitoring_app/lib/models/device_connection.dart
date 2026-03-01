/// Model representing the connection status with the wearable device
/// Follows SRP - Only responsible for connection data structure
class DeviceConnection {
  final bool isConnected;
  final int batteryLevel; // 0-100
  final int? heartRate; // BPM from BLE notify, null when unavailable
  final DateTime? lastSyncTime;
  final String deviceName;
  final ConnectionType connectionType;

  const DeviceConnection({
    required this.isConnected,
    required this.batteryLevel,
    this.heartRate,
    this.lastSyncTime,
    required this.deviceName,
    required this.connectionType,
  });

  /// Factory constructor for creating from JSON (Firebase/API ready)
  factory DeviceConnection.fromJson(Map<String, dynamic> json) {
    return DeviceConnection(
      isConnected: json['isConnected'] as bool,
      batteryLevel: json['batteryLevel'] as int,
      heartRate: json['heartRate'] as int?,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
      deviceName: json['deviceName'] as String,
      connectionType: ConnectionType.values.byName(
        json['connectionType'] as String,
      ),
    );
  }

  /// Convert to JSON (Firebase/API ready)
  Map<String, dynamic> toJson() {
    return {
      'isConnected': isConnected,
      'batteryLevel': batteryLevel,
      'heartRate': heartRate,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'deviceName': deviceName,
      'connectionType': connectionType.name,
    };
  }

  /// Copy with method for immutability
  DeviceConnection copyWith({
    bool? isConnected,
    int? batteryLevel,
    int? heartRate,
    DateTime? lastSyncTime,
    String? deviceName,
    ConnectionType? connectionType,
  }) {
    return DeviceConnection(
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      heartRate: heartRate ?? this.heartRate,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      deviceName: deviceName ?? this.deviceName,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  /// Get battery status based on level
  BatteryStatus get batteryStatus {
    if (batteryLevel >= 60) return BatteryStatus.high;
    if (batteryLevel >= 30) return BatteryStatus.medium;
    return BatteryStatus.low;
  }

  @override
  String toString() {
    return 'DeviceConnection(isConnected: $isConnected, batteryLevel: $batteryLevel%, device: $deviceName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceConnection &&
        other.isConnected == isConnected &&
        other.batteryLevel == batteryLevel &&
        other.heartRate == heartRate &&
        other.lastSyncTime == lastSyncTime &&
        other.deviceName == deviceName &&
        other.connectionType == connectionType;
  }

  @override
  int get hashCode {
    return Object.hash(
      isConnected,
      batteryLevel,
      heartRate,
      lastSyncTime,
      deviceName,
      connectionType,
    );
  }
}

/// Connection type with the device
enum ConnectionType { bluetooth, wifi, offline }

/// Battery status levels
enum BatteryStatus { high, medium, low }
