import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_model.dart';

class CacheService {
  static const String key = 'rebs_dashboard';

  Future<void> save(DashboardModel dashboard) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(dashboard.toJson()));
  }

  Future<DashboardModel?> get() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) return null;

    return DashboardModel.fromJson(jsonDecode(data));
  }
}
