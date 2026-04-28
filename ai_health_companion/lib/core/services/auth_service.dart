import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../constants/user_roles.dart';
import '../constants/app_constants.dart';

// any change

class AuthService extends ChangeNotifier {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  String? _token;
  String? _refreshToken;
  bool _isAuthenticated = false;
  bool _mustChangePassword = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _isAuthenticated;
  bool get mustChangePassword => _mustChangePassword;
  UserRole? get userRole => _currentUser?.role;

  final String baseUrl = AppConstants.baseUrl;

  // Login with API
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final userData = data['data']['user'];
          final accessToken = data['data']['accessToken'];
          final refreshToken = data['data']['refreshToken'];

          _currentUser = UserModel.fromJson(userData);
          _token = accessToken;
          _refreshToken = refreshToken;
          _isAuthenticated = true;
          _mustChangePassword = userData['mustChangePassword'] ?? false;

          notifyListeners();

          return {
            'success': true,
            'mustChangePassword': _mustChangePassword,
            'user': _currentUser,
          };
        }
      }

      final errorData = jsonDecode(response.body);
      final serverMessage = errorData['message'] as String? ?? '';

      // Map specific status codes to clear messages
      String userMessage;
      if (response.statusCode == 401) {
        userMessage =
            serverMessage.isNotEmpty
                ? serverMessage
                : 'Invalid email or password. Please try again.';
      } else if (response.statusCode == 400) {
        userMessage =
            serverMessage.isNotEmpty
                ? serverMessage
                : 'Please check your input and try again.';
      } else if (response.statusCode >= 500) {
        userMessage = 'Server error. Please try again later.';
      } else {
        userMessage =
            serverMessage.isNotEmpty
                ? serverMessage
                : 'Login failed. Please try again.';
      }

      return {'success': false, 'message': userMessage};
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('ClientException')) {
        return {
          'success': false,
          'message': 'Cannot connect to server. Please check your connection.',
        };
      }
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Forgot Password - Request reset
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset email sent',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to send reset email',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Reset Password with token
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successful',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to reset password',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Change Password (for authenticated users)
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _mustChangePassword = false;
        notifyListeners();

        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to change password',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      // Ignore logout errors
    }

    _currentUser = null;
    _token = null;
    _refreshToken = null;
    _isAuthenticated = false;
    _mustChangePassword = false;
    notifyListeners();
  }

  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    return _currentUser!.hasPermission(permission);
  }

  bool canAccessFeature(String feature) {
    if (_currentUser == null) return false;
    return _currentUser!.canAccessFeature(feature);
  }

  // Check if user can perform action on resource
  bool canPerformAction(String action, String resource) {
    if (_currentUser == null) return false;

    final permissionMap = {
      'create_patient': Permission.patientCreate,
      'read_patient': Permission.patientRead,
      'update_patient': Permission.patientUpdate,
      'delete_patient': Permission.patientDelete,
      'create_diagnosis': Permission.diagnosisCreate,
      'read_diagnosis': Permission.diagnosisRead,
      'create_prescription': Permission.prescriptionCreate,
      'dispense_prescription': Permission.prescriptionDispense,
      'create_lab_order': Permission.labOrderCreate,
      'view_analytics': Permission.analyticsView,
      'view_audit': Permission.auditLogView,
      'manage_users': Permission.userCreate,
    };

    final key = '${action}_$resource';
    final permission = permissionMap[key];

    if (permission == null) return false;
    return hasPermission(permission);
  }
}
