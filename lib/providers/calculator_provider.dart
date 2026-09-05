import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/calculation_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CalculatorProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<CalculationModel> _history = [];
  bool _isLoading = false;

  List<CalculationModel> get history => _history;
  List<CalculationModel> get favorites => _history.where((element) => element.isFavorite).toList();
  bool get isLoading => _isLoading;

  CalculatorProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _dbHelper.getAllCalculations();
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCalculation({
    required String type,
    required String title,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final autoSave = prefs.getBool('auto_save') ?? true;
    if (!autoSave) return;

    final calc = CalculationModel(
      type: type,
      title: title,
      inputs: inputs,
      outputs: outputs,
      createdAt: DateTime.now(),
    );
    try {
      await _dbHelper.insertCalculation(calc);
      await loadHistory();
    } catch (e) {
      debugPrint('Error saving calculation: $e');
    }
  }

  Future<void> toggleFavorite(CalculationModel calc) async {
    final newFavoriteStatus = !calc.isFavorite;
    try {
      if (calc.id != null) {
        await _dbHelper.toggleFavorite(calc.id!, newFavoriteStatus);
        await loadHistory();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> deleteCalculation(int id) async {
    try {
      await _dbHelper.deleteCalculation(id);
      await loadHistory();
    } catch (e) {
      debugPrint('Error deleting calculation: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _dbHelper.clearHistory();
      await loadHistory();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
