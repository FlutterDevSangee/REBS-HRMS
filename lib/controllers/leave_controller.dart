import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rebshrms/controllers/employee_dashboard_controller.dart';
import 'package:rebshrms/services/employee_api_service.dart';

class LeaveController extends GetxController {
  final api = Get.find<ApiService>();
  final employee = Get.find<EmployeeController>();

  final isSubmitting = false.obs;

  String validateLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    final today = DateTime.now();

    final todayDate = DateTime(today.year, today.month, today.day);

    final start = DateTime(startDate.year, startDate.month, startDate.day);

    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (start.isBefore(todayDate)) {
      return 'Start date cannot be before today.';
    }

    if (end.isBefore(start)) {
      return 'End date cannot be before start date.';
    }

    if (reason.trim().length < 10) {
      return 'Reason must contain at least 10 characters.';
    }

    final days = end.difference(start).inDays + 1;

    final balance = employee.dashboard.value?.leaveBalance ?? 0;

    if (days > balance) {
      return 'Requested days exceed available leave balance.';
    }

    final requests = employee.dashboard.value?.leaveRequests ?? [];

    for (final request in requests) {
      if (request.status != 'Pending' && request.status != 'Approved') {
        continue;
      }

      final existingStart = DateTime(
        request.startDate.year,
        request.startDate.month,
        request.startDate.day,
      );

      final existingEnd = DateTime(
        request.endDate.year,
        request.endDate.month,
        request.endDate.day,
      );

      final overlaps =
          !end.isBefore(existingStart) && !start.isAfter(existingEnd);

      if (overlaps) {
        return 'These dates overlap an existing leave request.';
      }
    }

    return '';
  }

  Future<void> submitLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    if (isSubmitting.value) return;

    final error = validateLeave(
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );

    if (error.isNotEmpty) {
      Get.snackbar('Validation Error', error);
      return;
    }

    isSubmitting.value = true;

    try {
      final connectivity = await Connectivity().checkConnectivity();

      if (connectivity.contains(ConnectivityResult.none)) {
        throw Exception('Internet connection is required to submit leave.');
      }

      await api.sendLeave({
        'type': type,
        'startDate': DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        ).toIso8601String(),
        'endDate': DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        ).toIso8601String(),
        'reason': reason.trim(),
      });

      Get.snackbar('Success', 'Leave application submitted successfully.');

      await employee.loadDashboard();
    } catch (e) {
      Get.snackbar('Submission Failed', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}
