import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final http.Client client = http.Client();

  Future<DashboardModel> getDashboard() async {
    final responses = await Future.wait([
      client.get(Uri.parse('$baseUrl/employee/me')),
      client.get(Uri.parse('$baseUrl/attendance')),
      client.get(Uri.parse('$baseUrl/leave/balance')),
      client.get(Uri.parse('$baseUrl/leave/requests')),
    ]).timeout(const Duration(seconds: 15));

    for (final response in responses) {
      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }
    }

    final employeeJson = jsonDecode(responses[0].body) as Map<String, dynamic>;

    final attendanceJson =
        jsonDecode(responses[1].body) as Map<String, dynamic>;

    final balanceJson = jsonDecode(responses[2].body) as Map<String, dynamic>;

    final leaveJson = jsonDecode(responses[3].body) as Map<String, dynamic>;

    return DashboardModel(
      employee: EmployeeModel.fromJson(employeeJson),

      attendance: (attendanceJson['data'] as List)
          .map((e) => AttendanceModel.fromJson(e))
          .toList(),

      leaveBalance: (balanceJson['availableDays'] as num).toDouble(),

      leaveRequests: (leaveJson['data'] as List)
          .map((e) => LeaveModel.fromJson(e))
          .toList(),
    );
  }

  Future<void> sendAttendance(Map<String, dynamic> event) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/attendance/events'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(event),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 409) {
      throw Exception('CONFLICT: Attendance already exists.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Attendance rejected: ${response.body}');
    }
  }

  Future<void> sendLeave(Map<String, dynamic> leave) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/leave/requests'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(leave),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 422) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Leave validation failed.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Leave submission failed.');
    }
  }
}
