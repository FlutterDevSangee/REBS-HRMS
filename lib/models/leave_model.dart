class LeaveModel {
  final String id;
  final String type;
  final String reason;
  final String status;
  final DateTime startDate;
  final DateTime endDate;

  LeaveModel({
    required this.id,
    required this.type,
    required this.reason,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'].toString(),
      type: json['type'],
      reason: json['reason'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'reason': reason,
    'status': status,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };
}
