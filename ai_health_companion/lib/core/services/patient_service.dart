import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService().token}',
  };

  /// Get all patients (scoped to user's clinic)
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final params = <String, String>{
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final uri = Uri.parse(
        '$_baseUrl/patients',
      ).replace(queryParameters: params);
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

  /// Get single patient by ID
  Future<Map<String, dynamic>> getPatientById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/patients/$id'), headers: _headers)
          .timeout(AppConstants.apiTimeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']['patient']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Patient not found',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  /// Create a new patient
  Future<Map<String, dynamic>> createPatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/patients'),
            headers: _headers,
            body: jsonEncode(patientData),
          )
          .timeout(AppConstants.apiTimeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data']['patient'],
          'message': data['message'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create patient',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  /// Update an existing patient
  Future<Map<String, dynamic>> updatePatient(
    String id,
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/patients/$id'),
            headers: _headers,
            body: jsonEncode(patientData),
          )
          .timeout(AppConstants.apiTimeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data']['patient'],
          'message': data['message'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update patient',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }

  /// Soft delete a patient
  Future<Map<String, dynamic>> deletePatient(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/patients/$id'), headers: _headers)
          .timeout(AppConstants.apiTimeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete patient',
      };
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server'};
    }
  }
}
