import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageController extends ChangeNotifier {
  AppLanguageController._();

  static final AppLanguageController instance = AppLanguageController._();

  String _language = 'English';

  String get language => _language;

  bool get isArabic => _language.toLowerCase() == 'arabic';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('app_language') ?? 'English';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    notifyListeners();
  }
}
