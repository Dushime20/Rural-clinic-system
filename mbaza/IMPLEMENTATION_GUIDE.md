# Quick Implementation Guide - Mbaza Translation for Medical Reports

## Overview

This guide shows how to integrate Mbaza NLP translator into your medical diagnosis system to provide Kinyarwanda translations of AI-generated medical reports.

---

## Step 1: Ensure Mbaza Service is Running

### Check if service is running:
```bash
# PowerShell
Invoke-RestMethod -Uri "http://localhost:9000/translate" -Method Post -ContentType "application/json" -Body '{"text": "Hello"}'
```

### Start Mbaza service (if not running):
```bash
cd c:\Users\educa\Desktop\Rural-clinic-system\mbaza
python app.py
```

The service should display:
```
--> Loading Mbaza NLP Engine into memory...
--> Success: Engine loaded on CPU. API is ready!
```

---

## Step 2: Add Translation Endpoint to Backend

Add this to your Flask backend (the API running on port 5000):

```python
import requests

# Translation helper function
def translate_to_kinyarwanda(text):
    """Translate English text to Kinyarwanda using Mbaza API"""
    if not text or text.strip() == "":
        return text
        
    try:
        response = requests.post(
            "http://localhost:9000/translate",
            json={"text": text},
            timeout=10
        )
        if response.status_code == 200:
            result = response.json()
            return result.get("kinyarwanda", text)
        return text  # Fallback to English
    except Exception as e:
        print(f"Translation error: {e}")
        return text  # Fallback to English

# New endpoint for translating medical reports
@app.route('/api/diagnoses/<int:diagnosis_id>/translate', methods=['GET'])
def translate_diagnosis_report(diagnosis_id):
    """
    Translate a diagnosis report to Kinyarwanda
    GET /api/diagnoses/{id}/translate
    """
    try:
        # Get the diagnosis (you already have this logic)
        diagnosis = Diagnosis.query.get_or_404(diagnosis_id)
        
        # Prepare sections for translation
        report_sections = {
            "disease": diagnosis.predicted_disease,
            "confidence": f"Confidence: {diagnosis.confidence_score}%",
            "description": diagnosis.description or "",
            "precautions": diagnosis.precautions or [],
            "medications": diagnosis.medications or [],  # Just instructions, not drug names
            "diet": diagnosis.diet_recommendations or [],
            "lifestyle": diagnosis.lifestyle_recommendations or [],
            "workout": diagnosis.workout_recommendations or []
        }
        
        # Translate each section
        translated = {
            "disease": translate_to_kinyarwanda(report_sections["disease"]),
            "confidence": translate_to_kinyarwanda(report_sections["confidence"]),
            "description": translate_to_kinyarwanda(report_sections["description"]),
            "precautions": [
                translate_to_kinyarwanda(item) 
                for item in report_sections["precautions"]
            ],
            "medications": [
                translate_to_kinyarwanda(item) 
                for item in report_sections["medications"]
            ],
            "diet": [
                translate_to_kinyarwanda(item) 
                for item in report_sections["diet"]
            ],
            "lifestyle": [
                translate_to_kinyarwanda(item) 
                for item in report_sections["lifestyle"]
            ],
            "workout": [
                translate_to_kinyarwanda(item) 
                for item in report_sections["workout"]
            ]
        }
        
        return jsonify({
            "success": True,
            "diagnosis_id": diagnosis_id,
            "language": "kinyarwanda",
            "original": report_sections,
            "translated": translated
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "message": f"Translation failed: {str(e)}"
        }), 500
```

---

## Step 3: Update Flutter Diagnosis Result Page

### 3.1 Add Translation State

```dart
class _DiagnosisResultPageState extends State<DiagnosisResultPage> {
  Map<String, dynamic>? _translatedReport;
  bool _isTranslating = false;
  
  @override
  void initState() {
    super.initState();
    _checkAndTranslate();
  }
  
  Future<void> _checkAndTranslate() async {
    final locale = Localizations.localeOf(context);
    
    // Only translate if user selected Kinyarwanda
    if (locale.languageCode == 'rw') {
      await _translateReport();
    }
  }
  
  Future<void> _translateReport() async {
    setState(() => _isTranslating = true);
    
    try {
      final diagnosisId = widget.diagnosis.id;
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/diagnoses/$diagnosisId/translate'),
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _translatedReport = result['translated'];
          _isTranslating = false;
        });
      } else {
        setState(() => _isTranslating = false);
      }
    } catch (e) {
      print('Translation error: $e');
      setState(() => _isTranslating = false);
    }
  }
  
  // Helper to get display text based on locale
  String _getDisplayText(String originalText, String? translatedText) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'rw' && translatedText != null) {
      return translatedText;
    }
    return originalText;
  }
  
  List<String> _getDisplayList(List<String> originalList, List<dynamic>? translatedList) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'rw' && translatedList != null) {
      return translatedList.cast<String>();
    }
    return originalList;
  }
}
```

### 3.2 Update UI to Show Translated Content

```dart
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context);
  
  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.diagnosisResult),
    ),
    body: _isTranslating
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(l10n.translatingToKinyarwanda ?? 'Translating to Kinyarwanda...'),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                // Disease Name
                _buildSection(
                  title: l10n.diagnosis,
                  content: _getDisplayText(
                    widget.diagnosis.predictedDisease,
                    _translatedReport?['disease'],
                  ),
                ),
                
                // Description
                _buildSection(
                  title: l10n.about,
                  content: _getDisplayText(
                    widget.diagnosis.description ?? '',
                    _translatedReport?['description'],
                  ),
                ),
                
                // Precautions
                _buildListSection(
                  title: l10n.precautions,
                  items: _getDisplayList(
                    widget.diagnosis.precautions ?? [],
                    _translatedReport?['precautions'],
                  ),
                ),
                
                // Medications
                _buildListSection(
                  title: l10n.medications,
                  items: _getDisplayList(
                    widget.diagnosis.medications ?? [],
                    _translatedReport?['medications'],
                  ),
                ),
                
                // Diet
                _buildListSection(
                  title: l10n.diet,
                  items: _getDisplayList(
                    widget.diagnosis.dietRecommendations ?? [],
                    _translatedReport?['diet'],
                  ),
                ),
                
                // Lifestyle
                _buildListSection(
                  title: l10n.lifestyle,
                  items: _getDisplayList(
                    widget.diagnosis.lifestyleRecommendations ?? [],
                    _translatedReport?['lifestyle'],
                  ),
                ),
                
                // Workout
                _buildListSection(
                  title: l10n.workout,
                  items: _getDisplayList(
                    widget.diagnosis.workoutRecommendations ?? [],
                    _translatedReport?['workout'],
                  ),
                ),
              ],
            ),
          ),
  );
}
```

---

## Step 4: Add Translation Keys to ARB Files

Add these keys to your ARB files:

### app_en.arb
```json
{
  "translatingToKinyarwanda": "Translating to Kinyarwanda...",
  "translationFailed": "Translation failed. Showing English version."
}
```

### app_fr.arb
```json
{
  "translatingToKinyarwanda": "Traduction en kinyarwanda...",
  "translationFailed": "La traduction a échoué. Affichage de la version anglaise."
}
```

### app_rw.arb
```json
{
  "translatingToKinyarwanda": "Guhindura mu Kinyarwanda...",
  "translationFailed": "Guhindura byanze. Turerekana verisiyo y'Icyongereza."
}
```

---

## Step 5: Testing

### Backend Test
```bash
# Test translation endpoint
curl -X GET http://localhost:5000/api/diagnoses/1/translate
```

### Flutter Test
1. Run the app in Kinyarwanda language
2. Create a diagnosis
3. View the result page
4. Should see "Guhindura mu Kinyarwanda..." loading message
5. Report should display in Kinyarwanda

---

## Performance Tips

### 1. Cache Translations
```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def translate_to_kinyarwanda_cached(text):
    return translate_to_kinyarwanda(text)
```

### 2. Translate in Background
```dart
// Load English version first
// Translate in background
Future.microtask(() => _translateReport());
```

### 3. Show Progress
```dart
// Show which section is being translated
String _currentSection = '';
setState(() => _currentSection = 'Translating precautions...');
```

---

## Error Handling

### Backend
```python
try:
    translated = translate_to_kinyarwanda(text)
except Exception as e:
    logger.error(f"Translation failed: {e}")
    translated = text  # Fallback to English
```

### Flutter
```dart
try {
  await _translateReport();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.translationFailed)),
  );
}
```

---

## Important Notes

### ✅ DO:
- Keep medication names in English (e.g., "Paracetamol")
- Translate only instructions and descriptions
- Show loading indicator during translation
- Fall back to English if translation fails
- Cache common translations

### ❌ DON'T:
- Don't translate disease names to unrecognized terms
- Don't block UI while translating
- Don't fail silently - inform user if translation fails
- Don't translate technical medical codes

---

## Example Flow

```
1. User selects Kinyarwanda language in Settings
2. User runs AI diagnosis
3. App receives English diagnosis from ML model
4. App detects locale is 'rw'
5. App shows English version immediately
6. App displays "Guhindura mu Kinyarwanda..." loading
7. Backend calls Mbaza API for each section
8. App updates UI with Kinyarwanda translations
9. User reads report in Kinyarwanda
```

---

## Troubleshooting

### Issue: Translation service not responding
**Solution**: Check if Mbaza service is running on port 9000

### Issue: Translation takes too long
**Solution**: Implement caching or translate in background

### Issue: Some sections not translating
**Solution**: Check if text is empty or null before translating

### Issue: Translation quality poor
**Solution**: Break long sentences into shorter ones

---

## Next Steps

1. ✅ Start Mbaza service
2. ✅ Add translation endpoint to backend
3. ✅ Update Flutter diagnosis result page
4. ✅ Add ARB translation keys
5. ✅ Test with real medical reports
6. ✅ Get feedback from Kinyarwanda speakers

---

**Ready to implement!** 🚀
