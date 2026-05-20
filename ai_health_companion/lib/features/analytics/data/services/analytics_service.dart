import 'package:dio/dio.dart';
import '../models/analytics_models.dart';
import '../../../../core/services/api_service.dart';

class AnalyticsService {
  final ApiService _apiService;

  AnalyticsService(this._apiService);

  /// Get dashboard analytics
  Future<DashboardAnalytics> getDashboardAnalytics() async {
    try {
      final response = await _apiService.get('/analytics/dashboard');

      if (response.data['success'] == true) {
        return DashboardAnalytics.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch analytics',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get dashboard analytics: $e');
    }
  }

  /// Get patient demographics
  Future<PatientDemographics> getPatientDemographics() async {
    try {
      final response = await _apiService.get('/analytics/patients');

      if (response.data['success'] == true) {
        return PatientDemographics.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch patient demographics',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get patient demographics: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Request failed';
      return Exception(message);
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection');
    } else {
      return Exception('Network error occurred');
    }
  }
}
