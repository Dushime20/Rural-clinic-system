# Flutter AI Diagnosis Implementation Guide

## Overview
This guide outlines the implementation of the complete AI diagnosis flow in the Flutter app, including:
1. AI-powered disease prediction
2. Prescription recommendations
3. Nearest pharmacy finder with medicine availability
4. Complete diagnosis workflow

## Current Status

### ✅ Already Implemented:
- Patient selection UI
- Symptoms input (manual selection)
- Vital signs recording
- Voice input interface
- Basic diagnosis page structure
- Navigation to diagnosis result page

### ⏳ To Be Implemented:
1. **Backend API Integration** for AI diagnosis
2. **Diagnosis Service** to handle API calls
3. **Diagnosis Models** for data structures
4. **Enhanced Result Page** with:
   - AI predictions
   - Prescriptions
   - Nearby pharmacies with medicine availability
5. **Pharmacy Finder** with medicine search
6. **Offline Support** for diagnosis data

## Implementation Steps

### Step 1: Create Diagnosis Models

Create `lib/features/diagnosis/data/models/diagnosis_models.dart`:

```dart
class DiagnosisRequest {
  final String patientId;
  final List<Symptom> symptoms;
  final VitalSigns vitalSigns;
  final int age;
  final String gender;
  final List<String>? medicalHistory;
  final String? notes;

  DiagnosisRequest({
    required this.patientId,
    required this.symptoms,
    required this.vitalSigns,
    required this.age,
    required this.gender,
    this.medicalHistory,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'symptoms': symptoms.map((s) => s.toJson()).toList(),
    'vitalSigns': vitalSigns.toJson(),
    'age': age,
    'gender': gender,
    'medicalHistory': medicalHistory,
    'notes': notes,
  };
}

class Symptom {
  final String name;
  final String? severity;
  final String? duration;

  Symptom({
    required this.name,
    this.severity,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (severity != null) 'severity': severity,
    if (duration != null) 'duration': duration,
  };
}

class VitalSigns {
  final double? temperature;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final int? respiratoryRate;
  final int? oxygenSaturation;

  VitalSigns({
    this.temperature,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.respiratoryRate,
    this.oxygenSaturation,
  });

  Map<String, dynamic> toJson() => {
    if (temperature != null) 'temperature': temperature,
    if (bloodPressureSystolic != null) 'bloodPressureSystolic': bloodPressureSystolic,
    if (bloodPressureDiastolic != null) 'bloodPressureDiastolic': bloodPressureDiastolic,
    if (heartRate != null) 'heartRate': heartRate,
    if (respiratoryRate != null) 'respiratoryRate': respiratoryRate,
    if (oxygenSaturation != null) 'oxygenSaturation': oxygenSaturation,
  };
}

class DiagnosisResponse {
  final String id;
  final String diagnosisId;
  final List<AIPrediction> aiPredictions;
  final SelectedDiagnosis? selectedDiagnosis;
  final List<Prescription>? prescriptions;
  final List<NearbyPharmacy>? nearbyPharmacies;
  final String status;
  final DateTime diagnosisDate;

  DiagnosisResponse({
    required this.id,
    required this.diagnosisId,
    required this.aiPredictions,
    this.selectedDiagnosis,
    this.prescriptions,
    this.nearbyPharmacies,
    required this.status,
    required this.diagnosisDate,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisResponse(
      id: json['id'],
      diagnosisId: json['diagnosisId'],
      aiPredictions: (json['aiPredictions'] as List)
          .map((p) => AIPrediction.fromJson(p))
          .toList(),
      selectedDiagnosis: json['selectedDiagnosis'] != null
          ? SelectedDiagnosis.fromJson(json['selectedDiagnosis'])
          : null,
      prescriptions: json['prescriptions'] != null
          ? (json['prescriptions'] as List)
              .map((p) => Prescription.fromJson(p))
              .toList()
          : null,
      nearbyPharmacies: json['nearbyPharmacies'] != null
          ? (json['nearbyPharmacies'] as List)
              .map((p) => NearbyPharmacy.fromJson(p))
              .toList()
          : null,
      status: json['status'],
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
    );
  }
}

class AIPrediction {
  final String disease;
  final double confidence;
  final String? icd10Code;
  final List<String>? recommendations;

  AIPrediction({
    required this.disease,
    required this.confidence,
    this.icd10Code,
    this.recommendations,
  });

  factory AIPrediction.fromJson(Map<String, dynamic> json) {
    return AIPrediction(
      disease: json['disease'],
      confidence: (json['confidence'] as num).toDouble(),
      icd10Code: json['icd10Code'],
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'])
          : null,
    );
  }
}

class SelectedDiagnosis {
  final String disease;
  final double confidence;
  final String? icd10Code;

  SelectedDiagnosis({
    required this.disease,
    required this.confidence,
    this.icd10Code,
  });

  factory SelectedDiagnosis.fromJson(Map<String, dynamic> json) {
    return SelectedDiagnosis(
      disease: json['disease'],
      confidence: (json['confidence'] as num).toDouble(),
      icd10Code: json['icd10Code'],
    );
  }
}

class Prescription {
  final String medication;
  final String dosage;
  final String frequency;
  final String duration;

  Prescription({
    required this.medication,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medication: json['medication'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
    );
  }
}

class NearbyPharmacy {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? phoneNumber;
  final double latitude;
  final double longitude;
  final double distance; // in km
  final List<PharmacyMedicine> availableMedicines;

  NearbyPharmacy({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.availableMedicines,
  });

  factory NearbyPharmacy.fromJson(Map<String, dynamic> json) {
    return NearbyPharmacy(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      availableMedicines: json['medicines'] != null
          ? (json['medicines'] as List)
              .map((m) => PharmacyMedicine.fromJson(m))
              .toList()
          : [],
    );
  }
}

class PharmacyMedicine {
  final String id;
  final String medicationName;
  final String? genericName;
  final String? brandName;
  final double price;
  final String currency;
  final int stockQuantity;
  final bool isAvailable;

  PharmacyMedicine({
    required this.id,
    required this.medicationName,
    this.genericName,
    this.brandName,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.isAvailable,
  });

  factory PharmacyMedicine.fromJson(Map<String, dynamic> json) {
    return PharmacyMedicine(
      id: json['id'],
      medicationName: json['medicationName'],
      genericName: json['genericName'],
      brandName: json['brandName'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? 'RWF',
      stockQuantity: json['stockQuantity'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}
```

### Step 2: Create Diagnosis Service

Create `lib/features/diagnosis/data/services/diagnosis_service.dart`:

```dart
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

      return DiagnosisResponse.fromJson(response.data['data']['diagnosis']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get diagnosis by ID
  Future<DiagnosisResponse> getDiagnosisById(String id) async {
    try {
      final response = await _apiService.get('/diagnosis/$id');
      return DiagnosisResponse.fromJson(response.data['data']['diagnosis']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient diagnoses
  Future<List<DiagnosisResponse>> getPatientDiagnoses(
    String patientId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/patients/$patientId/diagnoses',
        queryParameters: {'page': page, 'limit': limit},
      );

      final diagnoses = response.data['data']['diagnoses'] as List;
      return diagnoses
          .map((d) => DiagnosisResponse.fromJson(d))
          .toList();
    } catch (e) {
      throw _handleError(e);
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

      final pharmacies = response.data['data']['pharmacies'] as List;
      return pharmacies
          .map((p) => NearbyPharmacy.fromJson(p))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update diagnosis
  Future<DiagnosisResponse> updateDiagnosis(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put(
        '/diagnosis/$id',
        data: updates,
      );

      return DiagnosisResponse.fromJson(response.data['data']['diagnosis']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response!.data['message'] ?? 'Diagnosis failed';
      }
      return 'Network error. Please check your connection.';
    }
    return error.toString();
  }
}
```

### Step 3: Update Diagnosis Page to Call API

Modify `_runDiagnosis()` method in `diagnosis_page.dart`:

```dart
Future<void> _runDiagnosis() async {
  if (_selectedPatient == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a patient first'),
        backgroundColor: Colors.orange,
      ),
    );
    _tabController.animateTo(0);
    return;
  }

  if (_selectedSymptoms.isEmpty && _recordedText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please provide symptoms or voice input'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Running AI Diagnosis...'),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    // Prepare diagnosis request
    final request = DiagnosisRequest(
      patientId: _selectedPatient!['id'],
      symptoms: _selectedSymptoms.map((s) => Symptom(name: s)).toList(),
      vitalSigns: VitalSigns(
        temperature: _temperatureController.text.isNotEmpty
            ? double.tryParse(_temperatureController.text)
            : null,
        heartRate: _heartRateController.text.isNotEmpty
            ? int.tryParse(_heartRateController.text)
            : null,
        // ... other vital signs
      ),
      age: _selectedPatient!['age'],
      gender: _selectedPatient!['gender'].toLowerCase(),
      medicalHistory: _selectedMedicalHistory,
      notes: _additionalNotesController.text,
    );

    // Call diagnosis service
    final diagnosisService = ref.read(diagnosisServiceProvider);
    final result = await diagnosisService.createDiagnosis(request);

    // Get user location for pharmacy search
    final position = await _getCurrentLocation();
    
    // Find nearby pharmacies with prescribed medicines
    List<NearbyPharmacy> nearbyPharmacies = [];
    if (result.prescriptions != null && result.prescriptions!.isNotEmpty) {
      for (final prescription in result.prescriptions!) {
        final pharmacies = await diagnosisService.findNearbyPharmacies(
          latitude: position.latitude,
          longitude: position.longitude,
          medicineName: prescription.medication,
        );
        nearbyPharmacies.addAll(pharmacies);
      }
      // Remove duplicates
      nearbyPharmacies = nearbyPharmacies.toSet().toList();
    }

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Navigate to result page
    if (mounted) {
      context.go('/diagnosis/result', extra: {
        'diagnosis': result,
        'patient': _selectedPatient,
        'nearbyPharmacies': nearbyPharmacies,
      });
    }
  } catch (e) {
    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Show error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnosis failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<Position> _getCurrentLocation() async {
  // Request location permission
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }

  // Get current position
  return await Geolocator.getCurrentPosition();
}
```

### Step 4: Enhanced Diagnosis Result Page

Update `diagnosis_result_page.dart` to show:
1. AI predictions with confidence
2. Selected diagnosis
3. Prescriptions
4. Nearby pharmacies with medicine availability
5. Map view of pharmacies
6. Call/Navigate buttons for pharmacies

Key sections to add:
- **AI Predictions Card** - Show top 3 predictions
- **Prescriptions Card** - List all prescribed medicines
- **Nearby Pharmacies Card** - Show pharmacies with:
  - Distance
  - Available medicines
  - Stock quantity
  - Price
  - Call button
  - Navigate button (open maps)

### Step 5: Add Pharmacy Finder Feature

Create `lib/features/pharmacy/presentation/pages/pharmacy_finder_page.dart`:

```dart
class PharmacyFinderPage extends StatefulWidget {
  final String? medicineName;
  
  const PharmacyFinderPage({super.key, this.medicineName});
  
  @override
  State<PharmacyFinderPage> createState() => _PharmacyFinderPageState();
}

class _PharmacyFinderPageState extends State<PharmacyFinderPage> {
  // Search for pharmacies with specific medicine
  // Show on map
  // List view with distance
  // Call/Navigate buttons
}
```

## Backend API Endpoints Required

### 1. Create Diagnosis
```
POST /api/v1/diagnosis
Body: {
  patientId, symptoms, vitalSigns, age, gender, medicalHistory, notes
}
Response: {
  diagnosis with aiPredictions, selectedDiagnosis, prescriptions
}
```

### 2. Find Nearby Pharmacies
```
GET /api/v1/pharmacy-manager/nearby
Query: latitude, longitude, medicineName, radius
Response: {
  pharmacies: [{ id, name, address, distance, medicines: [...] }]
}
```

### 3. Get Diagnosis History
```
GET /api/v1/patients/:patientId/diagnoses
Response: { diagnoses: [...] }
```

## UI/UX Flow

### Complete Diagnosis Flow:
1. **Select Patient** → Patient list with search
2. **Enter Symptoms** → Multi-select chips
3. **Record Vital Signs** → Input fields with validation
4. **Voice Input** (Optional) → Record consultation
5. **Review** → Summary of all data
6. **Run AI Diagnosis** → Loading indicator
7. **View Results** → 
   - AI predictions (top 3)
   - Selected diagnosis
   - Prescriptions
   - Nearby pharmacies with medicines
8. **Select Pharmacy** → 
   - View on map
   - Check medicine availability
   - See prices
   - Call or navigate

## Dependencies to Add

```yaml
dependencies:
  geolocator: ^10.1.0  # Location services
  google_maps_flutter: ^2.5.0  # Map display
  url_launcher: ^6.2.2  # Call/Navigate
  permission_handler: ^11.1.0  # Permissions
```

## Testing Checklist

- [ ] Create diagnosis with symptoms
- [ ] AI predictions returned correctly
- [ ] Prescriptions displayed
- [ ] Location permission requested
- [ ] Nearby pharmacies found
- [ ] Medicine availability shown
- [ ] Distance calculated correctly
- [ ] Call pharmacy works
- [ ] Navigate to pharmacy works
- [ ] Offline mode handles gracefully
- [ ] Error handling works

## Next Steps

1. Implement diagnosis models
2. Create diagnosis service
3. Update diagnosis page with API integration
4. Enhance result page with pharmacy finder
5. Add map view for pharmacies
6. Implement call/navigate features
7. Add offline support
8. Test complete flow

---

**Status**: Implementation Guide Created
**Date**: 2026-05-05
