import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/translations.dart';

class LanguageController extends ChangeNotifier {
  static const String LANGUAGE_KEY = 'selected_language';
  late SharedPreferences _prefs;
  Locale _currentLocale = const Locale('fr'); // Default to French

  LanguageController() {
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(LANGUAGE_KEY);
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _prefs.setString(LANGUAGE_KEY, languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return AppTranslations.translations[_currentLocale.languageCode]?[key] ??
        key;
  }
}
