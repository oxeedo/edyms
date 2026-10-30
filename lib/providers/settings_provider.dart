import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/platform_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _service = SettingsService();
  PlatformSettings? _settings;
  bool _isLoading = false;
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');

  PlatformSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;

  String get currencySymbol => _settings?.currency.symbol ?? '\$';
  String get currencyCode => _settings?.currency.code ?? 'USD';
  List<PaymentMethod> get paymentMethods => _settings?.paymentMethods ?? [];

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadPreferences();
      final result = await _service.getSettings();
      if (result != null) {
        _settings = result;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString('language_code');
      final bool isDarkMode = prefs.getBool('is_dark_mode') ?? false;

      if (languageCode != null &&
          AppLocalizations.supportedLocales.any(
            (Locale locale) => locale.languageCode == languageCode,
          )) {
        _locale = Locale(languageCode);
      }
      _isDarkMode = isDarkMode;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      _locale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting locale: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', value);
      _isDarkMode = value;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }
  }

  String formatPrice(dynamic price) {
    if (price == null) return '';
    final double value = price is num ? price.toDouble() : 0.0;
    return NumberFormat.currency(symbol: currencySymbol).format(value);
  }
}
