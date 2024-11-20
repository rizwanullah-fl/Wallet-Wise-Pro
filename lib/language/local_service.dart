import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LocaleService {
  static const String _localeKey = 'locale';

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.toString());
  }

  Locale getLocaleFromString(String localeString) {
    final parts = localeString.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }

  Future<Locale?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(_localeKey);
    if (localeString == null) {
      return null;
    }
    return getLocaleFromString(localeString);
  }
}
