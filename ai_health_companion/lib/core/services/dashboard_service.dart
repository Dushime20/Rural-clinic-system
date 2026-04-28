import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService().token}',
  };

  /// Fetch dashboard stats for the logged-in user (scoped to their clinic)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/analytics/dashboard'), headers: _headers)
          .timeout(AppConstants.apiTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load stats',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  /// Fetch today's appointments for the logged-in user's clinic
  Future<Map<String, dynamic>> getTodayAppointments() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final uri = Uri.parse('$_baseUrl/appointments').replace(
        queryParameters: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load appointments',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  /// Fetch patients for the logged-in user's clinic
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/patients',
      ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});

      final response = await http
          .get(uri, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load patients',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }
}
