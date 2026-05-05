import 'package:dio/dio.dart';
import '../models/diagnosis_models.dart';
import '../../../../core/services/api_service.dart';

class DiagnosisService {
  final ApiService _apiService;

  DiagnosisService(this._apiService);

  /// Create AI diagnosis
  Future<DiagnosisResponse> createDiagnosis(DiagnosisRequest request) async {
    try {
      final response = await _apiService.post(
        '/diagnosis',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return DiagnosisResponse.fromJson(
          response.data['data']['diagnosis'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Diagnosis failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to create diagnosis: $e');
    }
  }

  /// Get diagnosis by ID
  Future<DiagnosisResponse> getDiagnosisById(String id) async {
    try {
      final response = await _apiService.get('/diagnosis/$id');

      if (response.data['success'] == true) {
        return DiagnosisResponse.fromJson(
          response.data['data']['diagnosis'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch diagnosis',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get diagnosis: $e');
    }
  }

  /// Get patient diagnoses with pagination
  Future<List<DiagnosisResponse>> getPatientDiagnoses(
    String patientId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/diagnosis/patients/$patientId/diagnoses',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final diagnoses = response.data['data']['diagnoses'] as List;
        return diagnoses
            .map((d) => DiagnosisResponse.fromJson(d as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch patient diagnoses',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get patient diagnoses: $e');
    }
  }

  /// Find nearby pharmacies with specific medicine
  Future<List<NearbyPharmacy>> findNearbyPharmacies({
    required double latitude,
    required double longitude,
    required String medicineName,
    double radius = 50, // km
  }) async {
    try {
      final response = await _apiService.get(
        '/pharmacy-manager/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'medicineName': medicineName,
          'radius': radius,
        },
      );

      if (response.data['success'] == true) {
        final pharmacies = response.data['data']['pharmacies'] as List;
        return pharmacies
            .map((p) => NearbyPharmacy.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to find nearby pharmacies',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to find nearby pharmacies: $e');
    }
  }

  /// Get all active pharmacies
  Future<List<NearbyPharmacy>> getAllPharmacies() async {
    try {
      final response = await _apiService.get('/pharmacy-manager/map');

      if (response.data['success'] == true) {
        final pharmacies = response.data['data']['pharmacies'] as List;
        return pharmacies
            .map((p) => NearbyPharmacy.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch pharmacies',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get pharmacies: $e');
    }
  }

  /// Update diagnosis
  Future<DiagnosisResponse> updateDiagnosis(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put('/diagnosis/$id', data: updates);

      if (response.data['success'] == true) {
        return DiagnosisResponse.fromJson(
          response.data['data']['diagnosis'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update diagnosis',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to update diagnosis: $e');
    }
  }

  /// Confirm diagnosis (select from AI predictions)
  Future<DiagnosisResponse> confirmDiagnosis(
    String id,
    SelectedDiagnosis selectedDiagnosis,
  ) async {
    try {
      final response = await _apiService.put(
        '/diagnosis/$id',
        data: {
          'selectedDiagnosis': selectedDiagnosis.toJson(),
          'status': 'confirmed',
        },
      );

      if (response.data['success'] == true) {
        return DiagnosisResponse.fromJson(
          response.data['data']['diagnosis'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to confirm diagnosis',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to confirm diagnosis: $e');
    }
  }

  /// Add prescriptions to diagnosis
  Future<DiagnosisResponse> addPrescriptions(
    String id,
    List<Prescription> prescriptions,
  ) async {
    try {
      final response = await _apiService.put(
        '/diagnosis/$id',
        data: {'prescriptions': prescriptions.map((p) => p.toJson()).toList()},
      );

      if (response.data['success'] == true) {
        return DiagnosisResponse.fromJson(
          response.data['data']['diagnosis'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to add prescriptions',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to add prescriptions: $e');
    }
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Request failed';
      }
      return 'Request failed with status ${error.response!.statusCode}';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please try again.';
    }
  }
}
