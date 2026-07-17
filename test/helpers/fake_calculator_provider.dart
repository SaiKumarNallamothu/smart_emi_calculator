import 'package:flutter/material.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/models/calculation_model.dart';

class FakeCalculatorProvider extends ChangeNotifier implements CalculatorProvider {
  final List<CalculationModel> _history = [];
  bool _isLoading = false;

  @override
  List<CalculationModel> get history => _history;

  @override
  List<CalculationModel> get favorites => _history.where((element) => element.isFavorite).toList();

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> saveCalculation({
    required String type,
    required String title,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
  }) async {
    final calc = CalculationModel(
      id: _history.length + 1,
      type: type,
      title: title,
      inputs: inputs,
      outputs: outputs,
      createdAt: DateTime.now(),
    );
    _history.add(calc);
    notifyListeners();
  }

  @override
  Future<void> toggleFavorite(CalculationModel calc) async {
    final index = _history.indexWhere((element) => element.id == calc.id);
    if (index != -1) {
      final updated = _history[index].copyWith(isFavorite: !_history[index].isFavorite);
      _history[index] = updated;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteCalculation(int id) async {
    _history.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  @override
  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
  }
}
