import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rebshrms/controllers/employee_dashboard_controller.dart';
import 'package:rebshrms/screens/employee_dashboard_screen.dart';
import 'package:rebshrms/services/employee_api_service.dart';
import 'services/cache_service.dart';
import 'services/local_database_service.dart';
import 'services/location_service.dart';
import 'controllers/attendance_controller.dart';
import 'controllers/leave_controller.dart';
import 'screens/attendance_screen.dart';
import 'screens/leave_screen.dart';

import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(ApiService(), permanent: true);
  Get.put(CacheService(), permanent: true);

  Get.put(LocalDatabaseService(), permanent: true);
  Get.put(LocationService(), permanent: true);

  Get.put(EmployeeController(), permanent: true);
  Get.put(AttendanceController(), permanent: true);
  Get.put(LeaveController(), permanent: true);

  runApp(const REBSApp());
}

class REBSApp extends StatelessWidget {
  const REBSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'REBS HRMS',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),

      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const DashboardScreen()),
        GetPage(name: '/attendance', page: () => const AttendanceScreen()),
        GetPage(name: '/leave', page: () => const LeaveScreen()),
      ],
    );
  }
}
