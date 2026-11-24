import 'package:get/get.dart';
import 'package:rebshrms/services/employee_api_service.dart';
import '../models/dashboard_model.dart';
import '../services/cache_service.dart';

class EmployeeController extends GetxController {
  final ApiService api = Get.find<ApiService>();
  final CacheService cache = Get.find<CacheService>();

  final Rxn<DashboardModel> dashboard = Rxn<DashboardModel>();

  final isLoading = false.obs;
  final isOffline = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final cached = await cache.get();

      if (cached != null) {
        dashboard.value = cached;
        isOffline.value = true;
      }

      final result = await api.getDashboard();

      dashboard.value = result;

      await cache.save(result);

      isOffline.value = false;
    } catch (e) {
      isOffline.value = true;

      if (dashboard.value == null) {
        errorMessage.value = e.toString();
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  String get attendanceStatus {
    final now = DateTime.now();

    final records = dashboard.value?.attendance ?? [];

    final today = records.where((record) {
      final date = record.checkInAt.toLocal();

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    if (today.isEmpty) return 'Not Checked In';

    return today.first.checkOutAt == null ? 'Checked In' : 'Checked Out';
  }

  String get checkInTime {
    final record = todayRecord;

    if (record == null) return '--';

    return _formatTime(record.checkInAt);
  }

  String get checkOutTime {
    final record = todayRecord;

    if (record?.checkOutAt == null) return '--';

    return _formatTime(record!.checkOutAt!);
  }

  dynamic get todayRecord {
    final now = DateTime.now();

    for (final record in dashboard.value?.attendance ?? []) {
      final date = record.checkInAt.toLocal();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return record;
      }
    }

    return null;
  }

  String _formatTime(DateTime date) {
    final hour = date.toLocal().hour;
    final minute = date.toLocal().minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get workingDuration {
    final record = todayRecord;

    if (record == null) return '0h 0m';

    final end = record.checkOutAt ?? DateTime.now();

    final duration = end.difference(record.checkInAt);

    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  List get latestAttendance {
    final list = [...?dashboard.value?.attendance];

    list.sort((a, b) => b.checkInAt.compareTo(a.checkInAt));

    return list.take(5).toList();
  }
}
