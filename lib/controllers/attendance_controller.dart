import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rebshrms/controllers/employee_dashboard_controller.dart';
import 'package:rebshrms/services/employee_api_service.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_event_model.dart';
import '../services/local_database_service.dart';
import '../services/location_service.dart';

class AttendanceController extends GetxController {
  final api = Get.find<ApiService>();
  final database = Get.find<LocalDatabaseService>();
  final location = Get.find<LocationService>();
  final employee = Get.find<EmployeeController>();

  final events = <AttendanceEventModel>[].obs;
  final isProcessing = false.obs;
  final isSyncing = false.obs;
  final isConnected = false.obs;

  final uuid = const Uuid();

  final Connectivity connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void onInit() {
    super.onInit();

    loadEvents();
    checkConnectivity();
    listenToConnectivity();
  }

  // Load locally stored attendance events
  Future<void> loadEvents() async {
    events.assignAll(await database.getEvents());
  }

  // Check current connectivity
  Future<void> checkConnectivity() async {
    final results = await connectivity.checkConnectivity();

    isConnected.value = !results.contains(ConnectivityResult.none);

    if (isConnected.value) {
      syncNow();
    }
  }

  // Listen for internet connectivity changes
  void listenToConnectivity() {
    connectivitySubscription = connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final connected = !results.contains(ConnectivityResult.none);

      isConnected.value = connected;

      if (connected) {
        syncNow();
      }
    });
  }

  Future<void> checkIn() async {
    await _recordAttendance('CHECK_IN');
  }

  Future<void> checkOut() async {
    await _recordAttendance('CHECK_OUT');
  }

  Future<void> _recordAttendance(String type) async {
    if (isProcessing.value) return;

    isProcessing.value = true;

    try {
      await loadEvents();

      final status = await _effectiveStatus();

      if (type == 'CHECK_IN' && status != 'Not Checked In') {
        throw Exception('You have already checked in today.');
      }

      if (type == 'CHECK_OUT' && status != 'Checked In') {
        throw Exception('You must check in before checking out.');
      }

      final config = employee.dashboard.value?.employee;

      if (config == null) {
        throw Exception('Employee or office configuration unavailable.');
      }

      final position = await location.getCurrentLocation();

      // Use current GPS position as the temporary office location
      final officeLatitude = position.latitude;
      final officeLongitude = position.longitude;

      final distance = location.calculateDistance(
        position.latitude,
        position.longitude,
        officeLatitude,
        officeLongitude,
      );

      if (distance > config.allowedRadius) {
        throw Exception(
          'You are ${distance.round()} metres from the office. '
          'You must be within '
          '${config.allowedRadius.round()} metres.',
        );
      }

      final event = AttendanceEventModel(
        eventId: uuid.v4(),
        type: type,
        timestamp: DateTime.now().toUtc(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Save locally first, even when offline
      await database.saveEvent(event);

      await loadEvents();

      Get.snackbar(
        'Attendance saved',
        '$type saved locally. Waiting for synchronization.',
      );

      // Attempt immediate sync.
      // If offline, event remains Pending Sync.
      if (isConnected.value) {
        await syncNow();
      }
    } catch (e) {
      Get.snackbar('Attendance', e.toString());
    } finally {
      isProcessing.value = false;
      update();
    }
  }

  Future<String> _effectiveStatus() async {
    final serverStatus = employee.attendanceStatus;

    final today = DateTime.now();

    final localToday = events.where((e) {
      final date = e.timestamp.toLocal();

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day &&
          e.status != 'Rejected';
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    var status = serverStatus;

    for (final event in localToday) {
      if (event.type == 'CHECK_IN') {
        status = 'Checked In';
      } else if (event.type == 'CHECK_OUT' && status == 'Checked In') {
        status = 'Checked Out';
      }
    }

    return status;
  }

  // Synchronize pending events in chronological order
  Future<void> syncNow() async {
    if (isSyncing.value || !isConnected.value) return;

    isSyncing.value = true;

    try {
      final pending = await database.getPendingEvents();

      for (final event in pending) {
        try {
          await api.sendAttendance(event.toJson());

          await database.updateEvent(event.copyWith(status: 'Synced'));
        } catch (e) {
          final message = e.toString();

          if (message.contains('CONFLICT')) {
            await database.updateEvent(
              event.copyWith(status: 'Rejected', rejectionReason: message),
            );
          } else {
            // Keep Pending Sync for retry.
            // Retry using the same eventId.
            break;
          }
        }
      }

      await loadEvents();
      await employee.loadDashboard();

      Get.snackbar('Synchronization', 'Synchronization process completed.');
    } finally {
      isSyncing.value = false;
      update();
    }
  }

  @override
  void onClose() {
    connectivitySubscription?.cancel();
    super.onClose();
  }
}
