class AttendanceModel {
  final String id;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final String syncStatus;

  AttendanceModel({
    required this.id,
    required this.checkInAt,
    this.checkOutAt,
    this.syncStatus = 'Synced',
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'].toString(),
      checkInAt: DateTime.parse(json['checkInAt']),
      checkOutAt: json['checkOutAt'] == null
          ? null
          : DateTime.parse(json['checkOutAt']),
      syncStatus: json['syncStatus'] ?? 'Synced',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'checkInAt': checkInAt.toIso8601String(),
    'checkOutAt': checkOutAt?.toIso8601String(),
    'syncStatus': syncStatus,
  };
}
