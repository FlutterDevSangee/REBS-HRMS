import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';

class AttendanceScreen extends GetView<AttendanceController> {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            onPressed: controller.syncNow,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.events.isEmpty) {
          return const Center(child: Text('No local attendance events.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];

            final color = event.status == 'Synced'
                ? Colors.green
                : event.status == 'Rejected'
                ? Colors.red
                : Colors.orange;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(event.type.replaceAll('_', ' ')),
                subtitle: Text(
                  DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(event.timestamp.toLocal()),
                ),
                trailing: Text(
                  event.status,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
