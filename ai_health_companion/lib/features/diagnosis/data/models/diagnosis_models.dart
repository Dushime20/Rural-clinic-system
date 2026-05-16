// Diagnosis Request and Response Models

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
    if (medicalHistory != null) 'medicalHistory': medicalHistory,
    if (notes != null) 'notes': notes,
  };
}

class Symptom {
  final String name;
  final String? severity;
  final String? duration;
  final String? category;

  Symptom({required this.name, this.severity, this.duration, this.category});

  Map<String, dynamic> toJson() => {
    'name': name,
    if (severity != null) 'severity': severity,
    if (duration != null) 'duration': duration,
    if (category != null) 'category': category,
  };

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'] as String,
      severity: json['severity'] as String?,
      duration: json['duration'] as String?,
      category: json['category'] as String?,
    );
  }
}

class VitalSigns {
  final double? temperature;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final int? respiratoryRate;
  final int? oxygenSaturation;
  final double? weight;
  final double? height;

  VitalSigns({
    this.temperature,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.weight,
    this.height,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (temperature != null) map['temperature'] = temperature;
    if (bloodPressureSystolic != null) {
      map['bloodPressureSystolic'] = bloodPressureSystolic;
    }
    if (bloodPressureDiastolic != null) {
      map['bloodPressureDiastolic'] = bloodPressureDiastolic;
    }
    if (heartRate != null) map['heartRate'] = heartRate;
    if (respiratoryRate != null) map['respiratoryRate'] = respiratoryRate;
    if (oxygenSaturation != null) map['oxygenSaturation'] = oxygenSaturation;
    if (weight != null) map['weight'] = weight;
    if (height != null) map['height'] = height;
    return map;
  }

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      temperature: (json['temperature'] as num?)?.toDouble(),
      bloodPressureSystolic: json['bloodPressureSystolic'] as int?,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] as int?,
      heartRate: json['heartRate'] as int?,
      respiratoryRate: json['respiratoryRate'] as int?,
      oxygenSaturation: json['oxygenSaturation'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );
  }

  bool get hasAnyData =>
      temperature != null ||
      bloodPressureSystolic != null ||
      heartRate != null ||
      respiratoryRate != null ||
      oxygenSaturation != null;
}

class DiagnosisResponse {
  final String id;
  final String diagnosisId;
  final String patientId;
  final List<AIPrediction> aiPredictions;
  final SelectedDiagnosis? selectedDiagnosis;
  final List<Prescription>? prescriptions;
  final List<Symptom> symptoms;
  final VitalSigns vitalSigns;
  final DateTime diagnosisDate;
  final String? notes;
  final bool followUpRequired;
  final DateTime? followUpDate;

  DiagnosisResponse({
    required this.id,
    required this.diagnosisId,
    required this.patientId,
    required this.aiPredictions,
    this.selectedDiagnosis,
    this.prescriptions,
    required this.symptoms,
    required this.vitalSigns,
    required this.diagnosisDate,
    this.notes,
    this.followUpRequired = false,
    this.followUpDate,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisResponse(
      id: json['id'] as String,
      diagnosisId: json['diagnosisId'] as String,
      patientId: json['patientId'] as String,
      aiPredictions:
          (json['aiPredictions'] as List)
              .map((p) => AIPrediction.fromJson(p as Map<String, dynamic>))
              .toList(),
      selectedDiagnosis:
          json['selectedDiagnosis'] != null
              ? SelectedDiagnosis.fromJson(
                json['selectedDiagnosis'] as Map<String, dynamic>,
              )
              : null,
      prescriptions:
          json['prescriptions'] != null
              ? (json['prescriptions'] as List)
                  .map((p) => Prescription.fromJson(p as Map<String, dynamic>))
                  .toList()
              : null,
      symptoms:
          (json['symptoms'] as List)
              .map((s) => Symptom.fromJson(s as Map<String, dynamic>))
              .toList(),
      vitalSigns: VitalSigns.fromJson(
        json['vitalSigns'] as Map<String, dynamic>,
      ),
      diagnosisDate: DateTime.parse(json['diagnosisDate'] as String),
      notes: json['notes'] as String?,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
      followUpDate:
          json['followUpDate'] != null
              ? DateTime.parse(json['followUpDate'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'diagnosisId': diagnosisId,
    'patientId': patientId,
    'aiPredictions': aiPredictions.map((p) => p.toJson()).toList(),
    if (selectedDiagnosis != null)
      'selectedDiagnosis': selectedDiagnosis!.toJson(),
    if (prescriptions != null)
      'prescriptions': prescriptions!.map((p) => p.toJson()).toList(),
    'symptoms': symptoms.map((s) => s.toJson()).toList(),
    'vitalSigns': vitalSigns.toJson(),
    'diagnosisDate': diagnosisDate.toIso8601String(),
    if (notes != null) 'notes': notes,
    'followUpRequired': followUpRequired,
    if (followUpDate != null) 'followUpDate': followUpDate!.toIso8601String(),
  };
}

class AIPrediction {
  final String disease;
  final double confidence;
  final String? icd10Code;
  final List<String>? recommendations;
  // Full disease information from Flask
  final String? description;
  final List<String>? precautions;
  final List<String>? medications;
  final List<String>? diet;
  final List<String>? workout;

  AIPrediction({
    required this.disease,
    required this.confidence,
    this.icd10Code,
    this.recommendations,
    this.description,
    this.precautions,
    this.medications,
    this.diet,
    this.workout,
  });

  factory AIPrediction.fromJson(Map<String, dynamic> json) {
    return AIPrediction(
      disease: json['disease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      icd10Code: json['icd10Code'] as String?,
      recommendations:
          json['recommendations'] != null
              ? List<String>.from(json['recommendations'] as List)
              : null,
      description: json['description'] as String?,
      precautions:
          json['precautions'] != null
              ? List<String>.from(json['precautions'] as List)
              : null,
      medications:
          json['medications'] != null
              ? List<String>.from(json['medications'] as List)
              : null,
      diet:
          json['diet'] != null ? List<String>.from(json['diet'] as List) : null,
      workout:
          json['workout'] != null
              ? List<String>.from(json['workout'] as List)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'disease': disease,
    'confidence': confidence,
    if (icd10Code != null) 'icd10Code': icd10Code,
    if (recommendations != null) 'recommendations': recommendations,
    if (description != null) 'description': description,
    if (precautions != null) 'precautions': precautions,
    if (medications != null) 'medications': medications,
    if (diet != null) 'diet': diet,
    if (workout != null) 'workout': workout,
  };

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';
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
      disease: json['disease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      icd10Code: json['icd10Code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'disease': disease,
    'confidence': confidence,
    if (icd10Code != null) 'icd10Code': icd10Code,
  };
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
      medication: json['medication'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'medication': medication,
    'dosage': dosage,
    'frequency': frequency,
    'duration': duration,
  };
}

class NearbyPharmacy {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? district;
  final String? phoneNumber;
  final double latitude;
  final double longitude;
  final double? distance; // in km
  final String? openingHours;
  final bool isActive;
  final List<PharmacyMedicine> medicines;

  NearbyPharmacy({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.district,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.openingHours,
    this.isActive = true,
    this.medicines = const [],
  });

  factory NearbyPharmacy.fromJson(Map<String, dynamic> json) {
    return NearbyPharmacy(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      district: json['district'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      distance: _parseDoubleNullable(json['distance']),
      openingHours: json['openingHours'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      medicines:
          json['medicines'] != null
              ? (json['medicines'] as List)
                  .map(
                    (m) => PharmacyMedicine.fromJson(m as Map<String, dynamic>),
                  )
                  .toList()
              : [],
    );
  }

  /// Helper to parse double from either String or num
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Cannot parse $value as double');
  }

  /// Helper to parse nullable double from either String or num
  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    if (city != null) 'city': city,
    if (district != null) 'district': district,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'latitude': latitude,
    'longitude': longitude,
    if (distance != null) 'distance': distance,
    if (openingHours != null) 'openingHours': openingHours,
    'isActive': isActive,
    'medicines': medicines.map((m) => m.toJson()).toList(),
  };

  String get distanceText =>
      distance != null ? '${distance!.toStringAsFixed(1)} km' : 'Unknown';

  String get fullAddress {
    final parts = <String>[address];
    if (city != null) parts.add(city!);
    if (district != null) parts.add(district!);
    return parts.join(', ');
  }
}

class PharmacyMedicine {
  final String id;
  final String medicationName;
  final String? genericName;
  final String? brandName;
  final String? strength;
  final String? form;
  final double price;
  final String currency;
  final int stockQuantity;
  final bool isAvailable;
  final String? notes;

  PharmacyMedicine({
    required this.id,
    required this.medicationName,
    this.genericName,
    this.brandName,
    this.strength,
    this.form,
    required this.price,
    this.currency = 'RWF',
    required this.stockQuantity,
    required this.isAvailable,
    this.notes,
  });

  factory PharmacyMedicine.fromJson(Map<String, dynamic> json) {
    return PharmacyMedicine(
      id: json['id'] as String,
      medicationName: json['medicationName'] as String,
      genericName: json['genericName'] as String?,
      brandName: json['brandName'] as String?,
      strength: json['strength'] as String?,
      form: json['form'] as String?,
      price: _parseDouble(json['price']),
      currency: json['currency'] as String? ?? 'RWF',
      stockQuantity: _parseInt(json['stockQuantity']),
      isAvailable: json['isAvailable'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Helper to parse double from either String or num
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Cannot parse $value as double');
  }

  /// Helper to parse int from either String or num
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationName': medicationName,
    if (genericName != null) 'genericName': genericName,
    if (brandName != null) 'brandName': brandName,
    if (strength != null) 'strength': strength,
    if (form != null) 'form': form,
    'price': price,
    'currency': currency,
    'stockQuantity': stockQuantity,
    'isAvailable': isAvailable,
    if (notes != null) 'notes': notes,
  };

  String get priceText => '$price $currency';

  String get stockText {
    if (!isAvailable) return 'Out of stock';
    if (stockQuantity <= 0) return 'Out of stock';
    if (stockQuantity <= 10) return 'Low stock ($stockQuantity)';
    return 'In stock ($stockQuantity)';
  }

  String get displayName {
    if (brandName != null && brandName!.isNotEmpty) {
      return '$brandName ($medicationName)';
    }
    return medicationName;
  }
}
