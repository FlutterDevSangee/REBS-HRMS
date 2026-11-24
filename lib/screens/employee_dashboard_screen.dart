import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rebshrms/controllers/employee_dashboard_controller.dart';
import '../controllers/attendance_controller.dart';

class DashboardScreen extends GetView<EmployeeController> {
  const DashboardScreen({super.key});

  static const Color primary = Color(0xFF6254E7);
  static const Color background = Color(0xFFF7F8FC);
  static const Color textDark = Color(0xFF20243A);
  static const Color textMuted = Color(0xFF8A90A4);
  static const Color green = Color(0xFF16A37B);

  @override
  Widget build(BuildContext context) {
    final attendance = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Obx(() {
          final data = controller.dashboard.value;

          if (controller.isLoading.value && data == null) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (data == null) {
            return _errorView();
          }

          return RefreshIndicator(
            color: primary,
            onRefresh: controller.loadDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                _header(attendance),

                const SizedBox(height: 24),

                _welcomeCard(
                  data.employee.name,
                  data.employee.id,
                  data.employee.department,
                ),

                const SizedBox(height: 26),

                _sectionTitle("Today's Attendance", 'Track your workday'),

                const SizedBox(height: 13),

                _attendanceCard(attendance),

                const SizedBox(height: 22),

                _leaveBalance(data.leaveBalance),

                const SizedBox(height: 27),

                _sectionTitle('Recent Attendance', 'Your latest records'),

                const SizedBox(height: 13),

                if (controller.latestAttendance.isEmpty)
                  _emptyCard(
                    Icons.event_available_outlined,
                    'No attendance records',
                    'Your attendance history will appear here.',
                  )
                else
                  ...controller.latestAttendance.map(_attendanceTile),

                const SizedBox(height: 25),

                _syncSection(attendance),

                const SizedBox(height: 25),

                _sectionTitle('Quick Actions', 'Manage your workspace'),

                const SizedBox(height: 13),

                _quickActions(),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'REBS HRMS • Employee Workspace',
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Header
  Widget _header(AttendanceController attendance) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.grid_view_rounded, color: primary, size: 23),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REBS HRMS',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Text(
                'Employee workspace',
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),
        ),
        Obx(() {
          final online = attendance.isConnected.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: online
                  ? green.withOpacity(0.10)
                  : Colors.orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(
                  online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  size: 14,
                  color: online ? green : Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  online ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: online ? green : Colors.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(width: 5),
        IconButton(
          tooltip: 'Refresh',
          onPressed: controller.loadDashboard,
          icon: const Icon(Icons.refresh_rounded, color: textDark),
        ),
      ],
    );
  }

  // Welcome card
  Widget _welcomeCard(String name, String id, String department) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7164EE), Color(0xFF5144C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WELCOME BACK 👋',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            department,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.badge_outlined, size: 15, color: Colors.white),
                const SizedBox(width: 7),
                Text(
                  'Employee ID: $id',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section heading
  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: textMuted)),
      ],
    );
  }

  // Attendance
  Widget _attendanceCard(AttendanceController attendance) {
    final status = controller.attendanceStatus;

    final statusColor = status == 'Checked In'
        ? green
        : status == 'Checked Out'
        ? primary
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _timeInfo(
                  Icons.login_rounded,
                  'Check In',
                  controller.checkInTime,
                ),
              ),
              Expanded(
                child: _timeInfo(
                  Icons.logout_rounded,
                  'Check Out',
                  controller.checkOutTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),
          const Divider(color: Color(0xFFEEF0F5)),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 19, color: primary),
              const SizedBox(width: 8),
              const Text(
                'Working Duration',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),
              const Spacer(),
              Text(
                controller.workingDuration,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Obx(() {
            final busy = attendance.isProcessing.value;

            return Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: busy ? null : attendance.checkIn,
                    icon: const Icon(Icons.login_rounded, size: 17),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primary.withOpacity(0.4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : attendance.checkOut,
                    icon: const Icon(Icons.logout_rounded, size: 17),
                    label: const Text('Check Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: Color(0xFFDCD8FC)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _timeInfo(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  // Leave balance
  Widget _leaveBalance(double balance) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Leave',
                  style: TextStyle(
                    fontSize: 14,
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your remaining leave balance',
                  style: TextStyle(fontSize: 11, color: textMuted),
                ),
              ],
            ),
          ),
          Text(
            '${balance.toStringAsFixed(balance == balance.roundToDouble() ? 0 : 1)}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Days',
            style: TextStyle(
              fontSize: 11,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Attendance history
  Widget _attendanceTile(dynamic record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(record.checkInAt.toLocal()),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${DateFormat('hh:mm a').format(record.checkInAt.toLocal())} - '
                  '${record.checkOutAt == null ? '--' : DateFormat('hh:mm a').format(record.checkOutAt!.toLocal())}',
                  style: const TextStyle(fontSize: 11, color: textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, size: 17, color: green),
        ],
      ),
    );
  }

  // Synchronization
  Widget _syncSection(AttendanceController attendance) {
    return Obx(() {
      final pending = attendance.events
          .where((event) => event.status == 'Pending Sync')
          .length;

      final rejected = attendance.events
          .where((event) => event.status == 'Rejected')
          .length;

      final syncing = attendance.isSyncing.value;

      return Container(
        padding: const EdgeInsets.all(17),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEBFF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.cloud_sync_rounded, color: primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Synchronization',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Keep your attendance updated',
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                _syncCount('Pending', pending, Colors.orange),
                const SizedBox(width: 20),
                _syncCount('Rejected', rejected, Colors.red),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: syncing || !attendance.isConnected.value
                    ? null
                    : attendance.syncNow,
                icon: syncing
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded, size: 17),
                label: Text(syncing ? 'Synchronizing...' : 'Sync Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: Color(0xFFDCD8FC)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _syncCount(String label, int count, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            '$label: $count',
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation
  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            Icons.access_time_rounded,
            'Attendance',
            'View records',
            () => Get.toNamed('/attendance'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            Icons.event_note_rounded,
            'Apply Leave',
            'Request time off',
            () => Get.toNamed('/leave'),
          ),
        ),
      ],
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEF0F5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: primary, size: 25),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty and error states
  Widget _emptyCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 32, color: textMuted),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 55, color: textMuted),
            const SizedBox(height: 15),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: controller.loadDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEEF0F5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
