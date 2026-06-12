# Translation Quick Reference Guide

## Quick Start

### Changing Language in the App
1. Open the app
2. Navigate to **Profile** page
3. Tap on **Language** option
4. Select desired language (English / Français / Ikinyarwanda)
5. **Perform a hot restart** (press `R` in terminal running Flutter)

---

## For Developers

### Adding Translations to a New Page

#### Step 1: Add Translation Keys to ARB Files
Add your keys to all 3 files with matching key names:

**`lib/l10n/app_en.arb`**
```json
{
  "myNewKey": "My English Text",
  "myKeyWithParam": "Hello {name}"
}
```

**`lib/l10n/app_fr.arb`**
```json
{
  "myNewKey": "Mon Texte Français",
  "myKeyWithParam": "Bonjour {name}"
}
```

**`lib/l10n/app_rw.arb`**
```json
{
  "myNewKey": "Umwandiko Wanjye",
  "myKeyWithParam": "Muraho {name}"
}
```

#### Step 2: Regenerate Localization Files
```bash
cd ai_health_companion
flutter pub get
```

#### Step 3: Update Your Page File
```dart
// 1. Import AppLocalizations
import '../../../generated/app_localizations.dart';

// 2. In your widget's build method, get the l10n object
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Scaffold(
    appBar: AppBar(
      // 3. Use translations
      title: Text(l10n.myNewKey),
    ),
    body: Text(
      // 4. Use parameters
      l10n.myKeyWithParam.replaceAll('{name}', userName),
    ),
  );
}
```

#### Step 4: Check for Errors
```bash
# Check diagnostics
flutter analyze lib/your_page.dart
```

---

## Common Patterns

### Simple Text Translation
```dart
Text(l10n.welcomeMessage)
```

### Text with Parameters
```dart
// ARB: "greeting": "Hello {name}, welcome!"
Text(l10n.greeting.replaceAll('{name}', userName))
```

### Button Labels
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(l10n.submitButton),
)
```

### Validation Messages
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return l10n.fieldRequired;
  }
  return null;
}
```

### Dynamic Lists
```dart
List<String> _getCategories(AppLocalizations l10n) {
  return [
    l10n.category1,
    l10n.category2,
    l10n.category3,
  ];
}

// In build method:
final categories = _getCategories(l10n);
```

### Snackbar Messages
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(l10n.successMessage),
  ),
)
```

### Dialog Content
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.confirmTitle),
    content: Text(l10n.confirmMessage),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n.cancelButton),
      ),
      ElevatedButton(
        onPressed: () {},
        child: Text(l10n.confirmButton),
      ),
    ],
  ),
)
```

---

## Medical Terminology Reference

| English | French | Kinyarwanda |
|---------|--------|-------------|
| Patient | Patient | Umurwayi |
| Doctor | Médecin | Muganga |
| Diagnosis | Diagnostic | Isuzuma |
| Symptoms | Symptômes | Ibimenyetso |
| Medicine | Médicament | Imiti |
| Pharmacy | Pharmacie | Iduka ry'imiti |
| Clinic | Clinique | Ivuriro |
| Hospital | Hôpital | Ibitaro |
| Appointment | Rendez-vous | Gahunda |
| Emergency | Urgence | Ihutirwa |
| Health | Santé | Ubuzima |
| Disease | Maladie | Indwara |
| Treatment | Traitement | Kuvura |
| Prescription | Ordonnance | Icyanditswe |
| Laboratory | Laboratoire | Laboratoire |
| Test | Test | Ikizamini |

---

## Translation Rules

### DO ✅
- Use descriptive key names (e.g., `appointmentCancelConfirm`)
- Keep keys consistent across all 3 ARB files
- Run `flutter pub get` after updating ARB files
- Check diagnostics after code changes
- Use `.replaceAll()` for simple parameter substitution
- Group related keys with common prefixes

### DON'T ❌
- Use Dart reserved keywords as keys (e.g., `continue`, `import`)
- Hardcode any strings in the UI
- Forget to add keys to all 3 language files
- Use special characters in key names
- Nest objects in ARB files (keep flat structure)

---

## Troubleshooting

### Problem: Translations not showing
**Solution**: Perform a hot restart (press `R`), not just hot reload

### Problem: "Undefined name 'l10n'"
**Solution**: Add `final l10n = AppLocalizations.of(context)!;` to build method

### Problem: "The getter 'keyName' isn't defined"
**Solution**: 
1. Verify key exists in ARB files
2. Run `flutter pub get` to regenerate
3. Check for typos in key name

### Problem: Key missing in one language
**Solution**: Ensure key exists in all 3 ARB files with same key name

### Problem: Special characters not displaying
**Solution**: Ensure files are saved with UTF-8 encoding

---

## File Locations

```
ai_health_companion/
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb      ← English translations
│   │   ├── app_fr.arb      ← French translations
│   │   └── app_rw.arb      ← Kinyarwanda translations
│   └── generated/
│       └── app_localizations.dart  ← Auto-generated (don't edit)
```

---

## Testing Your Translations

### Manual Testing Checklist
1. Switch to English → verify all text appears correctly
2. Switch to French → verify all text appears correctly
3. Switch to Kinyarwanda → verify all text appears correctly
4. Test with long text → ensure no overflow
5. Test error messages → verify they're translated
6. Test empty states → verify they're translated
7. Test dialogs and modals → verify they're translated

### Test Different Screen Sizes
- Small phones (320px width)
- Medium phones (375px width)
- Large phones (414px width)
- Tablets (768px width)

---

## Need Help?

### Common Questions

**Q: How do I add a new language?**
A: Create a new ARB file (e.g., `app_sw.arb` for Swahili), add all keys, update `l10n.yaml` configuration.

**Q: Can I use plurals in translations?**
A: Yes, use ICU message format in ARB files. See Flutter internationalization docs.

**Q: How do I translate dates and numbers?**
A: Use Flutter's `intl` package formatters which automatically respect locale.

**Q: What if I need gender-specific translations?**
A: Use multiple keys (e.g., `welcomeMale`, `welcomeFemale`) or use ICU select format.

---

## Resources

- [Flutter Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format Specification](https://github.com/google/app-resource-bundle)
- [Kinyarwanda Language Resources](https://en.wikipedia.org/wiki/Kinyarwanda)

---

**Last Updated**: June 12, 2026
**Version**: 1.0.0
