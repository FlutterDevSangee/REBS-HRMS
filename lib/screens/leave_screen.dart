import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rebshrms/controllers/employee_dashboard_controller.dart';
import '../controllers/leave_controller.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final controller = Get.find<LeaveController>();
  final employee = Get.find<EmployeeController>();

  final reasonController = TextEditingController();

  String leaveType = 'Casual';

  DateTime? startDate;
  DateTime? endDate;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> selectDate(bool isStart) async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate ?? now : endDate ?? startDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          startDate = selected;

          if (endDate != null && endDate!.isBefore(selected)) {
            endDate = selected;
          }
        } else {
          endDate = selected;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Application')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apply for Leave',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: leaveType,
                    decoration: const InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Casual',
                        child: Text('Casual Leave'),
                      ),
                      DropdownMenuItem(
                        value: 'Sick',
                        child: Text('Sick Leave'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        leaveType = value ?? 'Casual';
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  OutlinedButton.icon(
                    onPressed: () => selectDate(true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      startDate == null
                          ? 'Select Start Date'
                          : 'Start: ${DateFormat('dd MMM yyyy').format(startDate!)}',
                    ),
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: () => selectDate(false),
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      endDate == null
                          ? 'Select End Date'
                          : 'End: ${DateFormat('dd MMM yyyy').format(endDate!)}',
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: reasonController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Enter your leave reason...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : submit,
                        child: controller.isSubmitting.value
                            ? const CircularProgressIndicator()
                            : const Text('Submit Application'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Available Leave',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Obx(
            () => Card(
              child: ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Remaining Balance'),
                trailing: Text(
                  '${employee.dashboard.value?.leaveBalance ?? 0} Days',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'My Leave Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Obx(() {
            final requests = employee.dashboard.value?.leaveRequests ?? [];

            if (requests.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No leave requests found.'),
                ),
              );
            }

            return Column(
              children: requests.map((request) {
                final color = request.status == 'Approved'
                    ? Colors.green
                    : request.status == 'Rejected'
                    ? Colors.red
                    : Colors.orange;

                return Card(
                  child: ListTile(
                    title: Text('${request.type} Leave'),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(request.startDate)} - '
                      '${DateFormat('dd MMM yyyy').format(request.endDate)}\n'
                      '${request.reason}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      request.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  void submit() {
    if (startDate == null || endDate == null) {
      Get.snackbar('Missing Information', 'Please select both dates.');
      return;
    }

    controller.submitLeave(
      type: leaveType,
      startDate: startDate!,
      endDate: endDate!,
      reason: reasonController.text,
    );
  }
}
