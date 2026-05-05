import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diagnosis_models.dart';
import '../services/diagnosis_service.dart';
import '../../../../core/services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Diagnosis Service Provider
final diagnosisServiceProvider = Provider<DiagnosisService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DiagnosisService(apiService);
});

// Current Diagnosis State Provider
final currentDiagnosisProvider = StateProvider<DiagnosisResponse?>(
  (ref) => null,
);

// Nearby Pharmacies Provider
final nearbyPharmaciesProvider = StateProvider<List<NearbyPharmacy>>(
  (ref) => [],
);

// Diagnosis Loading State
final diagnosisLoadingProvider = StateProvider<bool>((ref) => false);

// Diagnosis Error State
final diagnosisErrorProvider = StateProvider<String?>((ref) => null);

// Create Diagnosis Provider
final createDiagnosisProvider =
    FutureProvider.family<DiagnosisResponse, DiagnosisRequest>((
      ref,
      request,
    ) async {
      final service = ref.read(diagnosisServiceProvider);
      return await service.createDiagnosis(request);
    });

// Get Patient Diagnoses Provider
final patientDiagnosesProvider = FutureProvider.family<
  List<DiagnosisResponse>,
  ({String patientId, int page, int limit})
>((ref, params) async {
  final service = ref.read(diagnosisServiceProvider);
  return await service.getPatientDiagnoses(
    params.patientId,
    page: params.page,
    limit: params.limit,
  );
});

// Find Nearby Pharmacies Provider
final findNearbyPharmaciesProvider = FutureProvider.family<
  List<NearbyPharmacy>,
  ({double latitude, double longitude, String medicineName, double radius})
>((ref, params) async {
  final service = ref.read(diagnosisServiceProvider);
  return await service.findNearbyPharmacies(
    latitude: params.latitude,
    longitude: params.longitude,
    medicineName: params.medicineName,
    radius: params.radius,
  );
});

// Get All Pharmacies Provider
final allPharmaciesProvider = FutureProvider<List<NearbyPharmacy>>((ref) async {
  final service = ref.read(diagnosisServiceProvider);
  return await service.getAllPharmacies();
});
