import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

/// Helper class to translate symptom and category names
/// The English names are required by the ML backend, but we show translated names to users
class SymptomTranslations {
  /// Get translated category name
  static String getCategoryName(BuildContext context, String englishCategory) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (englishCategory) {
      case 'General':
        return l10n.categoryGeneral;
      case 'Respiratory':
        return l10n.categoryRespiratory;
      case 'Digestive':
        return l10n.categoryDigestive;
      case 'Skin & Nails':
        return l10n.categorySkinNails;
      case 'Pain & Discomfort':
        return l10n.categoryPainDiscomfort;
      case 'Neurological':
        return l10n.categoryNeurological;
      case 'Eyes & Vision':
        return l10n.categoryEyesVision;
      case 'Urinary':
        return l10n.categoryUrinary;
      case 'Cardiovascular':
        return l10n.categoryCardiovascular;
      case 'Mental & Behavioral':
        return l10n.categoryMentalBehavioral;
      case 'Liver & Digestive System':
        return l10n.categoryLiverDigestive;
      case 'Throat & Mouth':
        return l10n.categoryThroatMouth;
      case 'Endocrine & Metabolic':
        return l10n.categoryEndocrineMetabolic;
      case 'Other':
        return l10n.categoryOther;
      default:
        return englishCategory; // Fallback to English
    }
  }
  
  /// Get translated symptom name
  static String getSymptomName(BuildContext context, String englishSymptom) {
    final l10n = AppLocalizations.of(context)!;
    
    // Return translated symptom name based on English symptom
    // For now, we'll return the English name as fallback
    // TODO: Add all 132 symptom translations to ARB files
    
    final translations = _getSymptomTranslations(l10n);
    return translations[englishSymptom] ?? englishSymptom;
  }
  
  /// Internal method to get symptom translations map
  static Map<String, String> _getSymptomTranslations(AppLocalizations l10n) {
    return {
      // General symptoms
      'Fatigue': l10n.symptomFatigue,
      'Malaise': l10n.symptomMalaise,
      'Lethargy': l10n.symptomLethargy,
      'Sweating': l10n.symptomSweating,
      'Chills': l10n.symptomChills,
      'Shivering': l10n.symptomShivering,
      'Weight Loss': l10n.symptomWeightLoss,
      'Weight Gain': l10n.symptomWeightGain,
      'Dehydration': l10n.symptomDehydration,
      'High Fever': l10n.symptomHighFever,
      'Mild Fever': l10n.symptomMildFever,
      
      // Add more as needed - for MVP, we'll add the most common ones
      // The full list of 132 symptoms can be added incrementally
    };
  }
}
