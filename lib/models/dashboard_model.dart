import 'employee_model.dart';
import 'attendance_model.dart';
import 'leave_model.dart';

class DashboardModel {
  final EmployeeModel employee;
  final List<AttendanceModel> attendance;
  final double leaveBalance;
  final List<LeaveModel> leaveRequests;

  DashboardModel({
    required this.employee,
    required this.attendance,
    required this.leaveBalance,
    required this.leaveRequests,
  });

  Map<String, dynamic> toJson() => {
    'employee': {
      'id': employee.id,
      'name': employee.name,
      'department': employee.department,
      'companyTimezone': employee.companyTimezone,
      'office': {
        'latitude': employee.officeLatitude,
        'longitude': employee.officeLongitude,
        'allowedRadiusMeters': employee.allowedRadius,
      },
    },
    'attendance': attendance.map((e) => e.toJson()).toList(),
    'leaveBalance': leaveBalance,
    'leaveRequests': leaveRequests.map((e) => e.toJson()).toList(),
  };

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      employee: EmployeeModel.fromJson(json['employee']),
      attendance: (json['attendance'] as List)
          .map((e) => AttendanceModel.fromJson(e))
          .toList(),
      leaveBalance: (json['leaveBalance'] as num).toDouble(),
      leaveRequests: (json['leaveRequests'] as List)
          .map((e) => LeaveModel.fromJson(e))
          .toList(),
    );
  }
}
