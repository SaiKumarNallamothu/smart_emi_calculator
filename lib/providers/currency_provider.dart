import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  String _symbol = '₹';
  String _locale = 'en_IN';

  String get symbol => _symbol;
  String get locale => _locale;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _symbol = prefs.getString('currency_symbol') ?? '₹';
    _locale = prefs.getString('currency_locale') ?? 'en_IN';
    notifyListeners();
  }

  Future<void> setCurrency(String symbol, String locale) async {
    _symbol = symbol;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    await prefs.setString('currency_locale', locale);
    notifyListeners();
  }

  NumberFormat getFormat({int decimalDigits = 0}) {
    return NumberFormat.currency(locale: _locale, symbol: '$_symbol ', decimalDigits: decimalDigits);
  }
}
