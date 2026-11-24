class AttendanceEventModel {
  final String eventId;
  final String type;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String status;
  final String? rejectionReason;

  AttendanceEventModel({
    required this.eventId,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.status = 'Pending Sync',
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'type': type,
    'occurredAt': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'rejectionReason': rejectionReason,
  };

  factory AttendanceEventModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEventModel(
      eventId: json['eventId'],
      type: json['type'],
      timestamp: DateTime.parse(json['occurredAt']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] ?? 'Pending Sync',
      rejectionReason: json['rejectionReason'],
    );
  }

  AttendanceEventModel copyWith({String? status, String? rejectionReason}) {
    return AttendanceEventModel(
      eventId: eventId,
      type: type,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
