class EmployeeModel {
  final String id;
  final String name;
  final String department;
  final String companyTimezone;
  final double officeLatitude;
  final double officeLongitude;
  final double allowedRadius;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.department,
    required this.companyTimezone,
    required this.officeLatitude,
    required this.officeLongitude,
    required this.allowedRadius,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final office = json['office'];

    return EmployeeModel(
      id: json['id'].toString(),
      name: json['name'],
      department: json['department'],
      companyTimezone: json['companyTimezone'] ?? 'Asia/Kolkata',
      officeLatitude: (office['latitude'] as num).toDouble(),
      officeLongitude: (office['longitude'] as num).toDouble(),
      allowedRadius: (office['allowedRadiusMeters'] as num).toDouble(),
    );
  }
}
