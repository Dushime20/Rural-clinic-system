/// Disease name translations for Kinyarwanda
/// These are loaded from the backend translation cache during app initialization
/// and used to display disease names in the user's selected language

import 'package:flutter/material.dart';

class DiseaseNameTranslations {
  // Singleton
  static final DiseaseNameTranslations _instance = DiseaseNameTranslations._internal();
  factory DiseaseNameTranslations() => _instance;
  DiseaseNameTranslations._internal();
  
  // Map of English disease names to Kinyarwanda translations
  final Map<String, String> _kinyarwandaNames = {};
  
  bool _isInitialized = false;
  
  /// Initialize translations from backend cache or local storage
  Future<void> initialize(Map<String, String>? translations) async {
    if (translations != null) {
      _kinyarwandaNames.clear();
      _kinyarwandaNames.addAll(translations);
      _isInitialized = true;
    }
  }
  
  /// Get translated disease name based on locale
  String getTranslatedName(String englishName, Locale locale) {
    if (locale.languageCode == 'rw' && _kinyarwandaNames.containsKey(englishName)) {
      return _kinyarwandaNames[englishName]!;
    }
    return englishName; // Return English if no translation or not Kinyarwanda
  }
  
  /// Check if a translation exists for a disease
  bool hasTranslation(String englishName) {
    return _kinyarwandaNames.containsKey(englishName);
  }
  
  /// Load from local cache (fallback if no backend data)
  /// These are common diseases that should always be available
  void loadFallbackTranslations() {
    _kinyarwandaNames.addAll({
      // Common diseases - add more as needed
      'Malaria': 'Malariya',
      'Typhoid': 'Tipayifo',
      'Dengue': 'Dengue',
      'Diabetes': 'Diyabete',
      'Hypertension': 'Umuvuduko w\'amaraso',
      'Pneumonia': 'Penumoniya',
      'Common Cold': 'Ibicurane',
      'Influenza': 'Ibicurane',
      'Tuberculosis': 'Igituntu',
      'HIV/AIDS': 'SIDA',
      'Cholera': 'Koleera',
      'Hepatitis': 'Hepatite',
      'Arthritis': 'Kuribwa n\'imisatsi',
      'Asthma': 'Asthma',
      'Gastroenteritis': 'Indwara y\'inda',
      'Allergy': 'Allergie',
      'Migraine': 'Umutwe',
      'Anemia': 'Anemiya',
    });
    _isInitialized = true;
  }
  
  /// Get all available translations
  Map<String, String> getAllTranslations() {
    return Map.unmodifiable(_kinyarwandaNames);
  }
  
  bool get isInitialized => _isInitialized;
}

// Global helper function for easy access
String translateDiseaseName(String englishName, Locale locale) {
  return DiseaseNameTranslations().getTranslatedName(englishName, locale);
}
