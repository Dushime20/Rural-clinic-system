import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages
enum AppLanguage {
  english('en', 'English', 'English'),
  french('fr', 'Français', 'French'),
  kinyarwanda('rw', 'Ikinyarwanda', 'Kinyarwanda');

  const AppLanguage(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Language state notifier
class LanguageNotifier extends StateNotifier<Locale> {
  static const String _key = 'app_language';

  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  /// Load language from storage
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_key);

      if (languageCode != null) {
        state = Locale(languageCode);
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  /// Set language and save to storage
  Future<void> setLanguage(AppLanguage language) async {
    try {
      state = language.locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, language.code);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  /// Set language by code
  Future<void> setLanguageByCode(String code) async {
    final language = AppLanguage.fromCode(code);
    await setLanguage(language);
  }

  /// Get current language
  AppLanguage get currentLanguage {
    return AppLanguage.fromCode(state.languageCode);
  }
}

/// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => LanguageNotifier(),
);

/// Current language provider (convenience)
final currentLanguageProvider = Provider<AppLanguage>((ref) {
  final locale = ref.watch(languageProvider);
  return AppLanguage.fromCode(locale.languageCode);
});

/// Supported locales provider
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return AppLanguage.values.map((lang) => lang.locale).toList();
});
