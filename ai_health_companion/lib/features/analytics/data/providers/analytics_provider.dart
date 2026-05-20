import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_models.dart';
import '../services/analytics_service.dart';
import '../../../diagnosis/data/providers/diagnosis_provider.dart';

// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AnalyticsService(apiService);
});

// Dashboard analytics provider
final dashboardAnalyticsProvider =
    FutureProvider<DashboardAnalytics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return await analyticsService.getDashboardAnalytics();
});

// Patient demographics provider
final patientDemographicsProvider =
    FutureProvider<PatientDemographics>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return await analyticsService.getPatientDemographics();
});
