/// Clinic Recommendation Models
/// 
/// This file contains models for clinic recommendations feature:
/// - ClinicRecommendation: Represents a clinic recommendation
/// - PatternAnalysis: Represents disease pattern analysis
/// - Extensions to DiagnosisResponse to include clinic data

/// Pattern Analysis Model
/// Represents the detected patterns in patient's diagnosis history
class PatternAnalysis {
  final bool isRecurring;
  final bool isPersistent;
  final bool matchesChronicCondition;
  final int? occurrenceCount;
  final int? durationDays;
  final String? matchedCondition;

  const PatternAnalysis({
    required this.isRecurring,
    required this.isPersistent,
    required this.matchesChronicCondition,
    this.occurrenceCount,
    this.durationDays,
    this.matchedCondition,
  });

  factory PatternAnalysis.fromJson(Map<String, dynamic> json) {
    return PatternAnalysis(
      isRecurring: json['isRecurring'] as bool? ?? false,
      isPersistent: json['isPersistent'] as bool? ?? false,
      matchesChronicCondition:
          json['matchesChronicCondition'] as bool? ?? false,
      occurrenceCount: json['occurrenceCount'] as int?,
      durationDays: json['durationDays'] as int?,
      matchedCondition: json['matchedCondition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'isRecurring': isRecurring,
        'isPersistent': isPersistent,
        'matchesChronicCondition': matchesChronicCondition,
        if (occurrenceCount != null) 'occurrenceCount': occurrenceCount,
        if (durationDays != null) 'durationDays': durationDays,
        if (matchedCondition != null) 'matchedCondition': matchedCondition,
      };

  /// Check if any pattern is detected
  bool get hasPattern =>
      isRecurring || isPersistent || matchesChronicCondition;

  /// Get a user-friendly description of the pattern
  String get patternDescription {
    if (matchesChronicCondition && matchedCondition != null) {
      return 'Matches chronic condition: $matchedCondition';
    }
    if (isPersistent && durationDays != null) {
      return 'Persistent condition (active for $durationDays days)';
    }
    if (isRecurring && occurrenceCount != null) {
      return 'Recurring condition ($occurrenceCount occurrences in 90 days)';
    }
    if (hasPattern) {
      return 'Pattern detected in diagnosis history';
    }
    return 'No pattern detected';
  }

  /// Get the pattern type for UI display
  String get patternType {
    if (matchesChronicCondition) return 'Chronic';
    if (isPersistent) return 'Persistent';
    if (isRecurring) return 'Recurring';
    return 'None';
  }
}

/// Clinic Recommendation Model
/// Represents a specialized clinic recommendation
class ClinicRecommendation {
  final String id;
  final String name;
  final List<String> specialties;
  final String? phoneNumber;
  final String address;
  final String? city;
  final String? district;
  final String? country;
  final double latitude;
  final double longitude;
  final double? distance; // in km
  final bool? isOpenNow;
  final Map<String, dynamic>? openingHours;
  final String? reason; // Why this clinic is recommended

  const ClinicRecommendation({
    required this.id,
    required this.name,
    required this.specialties,
    this.phoneNumber,
    required this.address,
    this.city,
    this.district,
    this.country,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.isOpenNow,
    this.openingHours,
    this.reason,
  });

  factory ClinicRecommendation.fromJson(Map<String, dynamic> json) {
    return ClinicRecommendation(
      id: json['id'] as String,
      name: json['name'] as String,
      specialties: (json['specialties'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      district: json['district'] as String?,
      country: json['country'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      distance: _parseDoubleNullable(json['distance']),
      isOpenNow: json['isOpenNow'] as bool?,
      openingHours: json['openingHours'] as Map<String, dynamic>?,
      reason: json['reason'] as String?,
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
        'specialties': specialties,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'address': address,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (country != null) 'country': country,
        'latitude': latitude,
        'longitude': longitude,
        if (distance != null) 'distance': distance,
        if (isOpenNow != null) 'isOpenNow': isOpenNow,
        if (openingHours != null) 'openingHours': openingHours,
        if (reason != null) 'reason': reason,
      };

  /// Get full address as a single string
  String get fullAddress {
    final parts = <String>[address];
    if (city != null) parts.add(city!);
    if (district != null) parts.add(district!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  /// Get distance as formatted text
  String get distanceText =>
      distance != null ? '${distance!.toStringAsFixed(1)} km' : 'Distance unknown';

  /// Get specialties as a comma-separated string
  String get specialtiesText => specialties.isEmpty
      ? 'General Medicine'
      : specialties.map((s) => s.replaceAll('_', ' ')).join(', ');

  /// Get opening status text
  String get openingStatusText {
    if (isOpenNow == null) return '';
    return isOpenNow! ? 'Open now' : 'Closed';
  }

  /// Get reason badge text for UI
  String get reasonBadgeText {
    if (reason == null) return 'Specialist Care';
    if (reason!.contains('recurring')) return 'Recurring';
    if (reason!.contains('persistent')) return 'Persistent';
    if (reason!.contains('chronic')) return 'Chronic';
    if (reason!.contains('no pharmacy')) return 'Specialist Care';
    return 'Specialist Care';
  }

  /// Get reason explanation for UI
  String get reasonExplanation {
    if (reason == null) return 'Specialized medical care recommended';
    return reason!;
  }
}

/// Recommendations container with both pharmacy and clinic recommendations
class Recommendations {
  final List<dynamic> pharmacies; // List of NearbyPharmacy
  final List<ClinicRecommendation>? clinics;
  final String? clinicRecommendationReason;
  final PatternAnalysis? patternAnalysis;

  const Recommendations({
    required this.pharmacies,
    this.clinics,
    this.clinicRecommendationReason,
    this.patternAnalysis,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      pharmacies: json['pharmacies'] as List? ?? [],
      clinics: json['clinics'] != null
          ? (json['clinics'] as List)
              .map((c) =>
                  ClinicRecommendation.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
      clinicRecommendationReason:
          json['clinicRecommendationReason'] as String?,
      patternAnalysis: json['patternAnalysis'] != null
          ? PatternAnalysis.fromJson(
              json['patternAnalysis'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'pharmacies': pharmacies,
        if (clinics != null) 'clinics': clinics!.map((c) => c.toJson()).toList(),
        if (clinicRecommendationReason != null)
          'clinicRecommendationReason': clinicRecommendationReason,
        if (patternAnalysis != null)
          'patternAnalysis': patternAnalysis!.toJson(),
      };

  /// Check if clinic recommendations are available
  bool get hasClinics => clinics != null && clinics!.isNotEmpty;

  /// Check if clinic recommendations were triggered (even if empty)
  bool get hasClinicsRecommended => clinics != null;

  /// Check if pharmacy recommendations are available
  bool get hasPharmacies => pharmacies.isNotEmpty;

  /// Check if any recommendations are available
  bool get hasRecommendations => hasPharmacies || hasClinics;

  /// Check if pattern analysis is available
  bool get hasPatternAnalysis =>
      patternAnalysis != null && patternAnalysis!.hasPattern;
}
