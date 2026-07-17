import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calculator_provider.dart';

// ==========================================
// DISCOUNT CALCULATOR SCREEN
// ==========================================
class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController(text: '1999');
  final _discountController = TextEditingController(text: '20');

  bool _calculated = false;
  double _originalPrice = 0.0;
  double _savings = 0.0;
  double _finalPrice = 0.0;

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final double price = double.parse(_priceController.text);
    final double discountPercent = double.parse(_discountController.text);

    final double savings = price * (discountPercent / 100);
    final double finalPrice = price - savings;

    setState(() {
      _originalPrice = price;
      _savings = savings;
      _finalPrice = finalPrice;
      _calculated = true;
    });

    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    provider.saveCalculation(
      type: 'Discount',
      title: 'Discount: ${discountPercent.toStringAsFixed(0)}% off Rs. ${NumberFormat('#,##,###').format(price)}',
      inputs: {
        'originalPrice': price,
        'discountPercent': discountPercent,
      },
      outputs: {
        'finalPrice': finalPrice,
        'savings': savings,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Original Price',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount Percentage (%)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _calculate,
                        child: const Text('Calculate Discount'),
                      ),
                    ],
                  ),
                ),
              ),

              if (_calculated) ...[
                const SizedBox(height: 24),
                const Text('Discount Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRow('Original Price', currencyFormat.format(_originalPrice)),
                        const Divider(height: 24),
                        _buildRow('Total Savings', currencyFormat.format(_savings), color: Colors.green),
                        const Divider(height: 24),
                        _buildRow('Final Price', currencyFormat.format(_finalPrice), isBold: true),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color ?? (isBold ? Theme.of(context).colorScheme.primary : null),
          ),
        ),
      ],
    );
  }
}


// ==========================================
// PERCENTAGE CALCULATOR SCREEN
// ==========================================
class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends State<PercentageCalculatorScreen> {
  int _activeTab = 0; // 0: Find X% of Y, 1: What % is X of Y?, 2: % Increase/Decrease

  // Tab 0
  final _x1Controller = TextEditingController(text: '10');
  final _y1Controller = TextEditingController(text: '250');
  double? _result1;

  // Tab 1
  final _x2Controller = TextEditingController(text: '50');
  final _y2Controller = TextEditingController(text: '200');
  double? _result2;

  // Tab 2
  final _initialController = TextEditingController(text: '120');
  final _finalController = TextEditingController(text: '150');
  double? _result3;
  bool _isIncrease = true;

  @override
  void dispose() {
    _x1Controller.dispose();
    _y1Controller.dispose();
    _x2Controller.dispose();
    _y2Controller.dispose();
    _initialController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  void _calculateTab0() {
    final double x = double.tryParse(_x1Controller.text) ?? 0.0;
    final double y = double.tryParse(_y1Controller.text) ?? 0.0;
    setState(() {
      _result1 = (x / 100) * y;
    });
  }

  void _calculateTab1() {
    final double x = double.tryParse(_x2Controller.text) ?? 0.0;
    final double y = double.tryParse(_y2Controller.text) ?? 0.0;
    setState(() {
      _result2 = y > 0 ? (x / y) * 100 : 0.0;
    });
  }

  void _calculateTab2() {
    final double initialVal = double.tryParse(_initialController.text) ?? 0.0;
    final double finalVal = double.tryParse(_finalController.text) ?? 0.0;

    if (initialVal == 0.0) {
      setState(() {
        _result3 = 0.0;
        _isIncrease = true;
      });
      return;
    }

    final double change = finalVal - initialVal;
    final double pct = (change / initialVal) * 100;

    setState(() {
      _result3 = pct.abs();
      _isIncrease = change >= 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Percentage Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Custom Tab Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildTabButton('Find X% of Y', 0),
                const SizedBox(width: 8),
                _buildTabButton('X is what % of Y?', 1),
                const SizedBox(width: 8),
                _buildTabButton('% Increase/Dec', 2),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IndexedStack(
                index: _activeTab,
                children: [
                  // Tab 0
                  _buildCard(
                    title: 'Calculate X% of Y',
                    children: [
                      TextFormField(
                        controller: _x1Controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Percentage (X)', suffixText: '%'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _y1Controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Total Value (Y)'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _calculateTab0, child: const Text('Calculate')),
                      if (_result1 != null) ...[
                        const Divider(height: 40),
                        Center(
                          child: Text(
                            'Result: ${_result1!.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Tab 1
                  _buildCard(
                    title: 'X is what percentage of Y?',
                    children: [
                      TextFormField(
                        controller: _x2Controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Value (X)'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _y2Controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Total Value (Y)'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _calculateTab1, child: const Text('Calculate')),
                      if (_result2 != null) ...[
                        const Divider(height: 40),
                        Center(
                          child: Text(
                            'Result: ${_result2!.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Tab 2
                  _buildCard(
                    title: 'Percentage Increase / Decrease',
                    children: [
                      TextFormField(
                        controller: _initialController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Initial Value'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _finalController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Final Value'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _calculateTab2, child: const Text('Calculate')),
                      if (_result3 != null) ...[
                        const Divider(height: 40),
                        Center(
                          child: Text(
                            'Result: ${_result3!.toStringAsFixed(2)}% ${_isIncrease ? 'Increase' : 'Decrease'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isIncrease ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: active ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}
