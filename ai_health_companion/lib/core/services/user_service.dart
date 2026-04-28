import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService().token}',
  };

  /// Get current logged-in user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users/me'), headers: _headers)
          .timeout(AppConstants.apiTimeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']['user']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load profile',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  /// Update current user profile (firstName, lastName, phoneNumber)
  Future<Map<String, dynamic>> updateCurrentUser(
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/users/me'),
            headers: _headers,
            body: jsonEncode(updates),
          )
          .timeout(AppConstants.apiTimeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data']['user'],
          'message': data['message'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update profile',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }
}
