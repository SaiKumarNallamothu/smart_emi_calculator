import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calculator_provider.dart';

class GstCalculatorScreen extends StatefulWidget {
  const GstCalculatorScreen({super.key});

  @override
  State<GstCalculatorScreen> createState() => _GstCalculatorScreenState();
}

class _GstCalculatorScreenState extends State<GstCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '10000');

  double _selectedRate = 18.0;
  bool _addGst = true; // Add GST or Remove GST

  bool _calculated = false;
  double _originalAmount = 0.0;
  double _gstAmount = 0.0;
  double _finalAmount = 0.0;

  final List<double> _gstRates = [3.0, 5.0, 12.0, 18.0, 28.0];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateGst() {
    if (!_formKey.currentState!.validate()) return;

    final double amount = double.parse(_amountController.text);

    double gst = 0.0;
    double finalAmt = 0.0;

    if (_addGst) {
      // Add GST: GST Amount = Amount * Rate / 100
      gst = amount * (_selectedRate / 100);
      finalAmt = amount + gst;
    } else {
      // Remove GST: Original Amount = Net Amount / (1 + Rate/100)
      final double original = amount / (1 + (_selectedRate / 100));
      gst = amount - original;
      finalAmt = original;
    }

    setState(() {
      _originalAmount = _addGst ? amount : finalAmt;
      _gstAmount = gst;
      _finalAmount = _addGst ? finalAmt : amount;
      _calculated = true;
    });

    // Auto save calculation
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    provider.saveCalculation(
      type: 'GST',
      title: 'GST (${_addGst ? '+' : '-'}${_selectedRate.toStringAsFixed(0)}%) on Rs. ${NumberFormat('#,##,###').format(amount)}',
      inputs: {
        'initialAmount': amount,
        'rate': _selectedRate,
        'mode': _addGst ? 'Add GST' : 'Remove GST',
      },
      outputs: {
        'originalAmount': _originalAmount,
        'gstAmount': _gstAmount,
        'finalAmount': _finalAmount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Input
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Add/Remove GST Selector
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Add GST (+)', style: TextStyle(fontWeight: FontWeight.bold))),
                              selected: _addGst,
                              onSelected: (selected) {
                                if (selected) setState(() => _addGst = true);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Remove GST (-)', style: TextStyle(fontWeight: FontWeight.bold))),
                              selected: !_addGst,
                              onSelected: (selected) {
                                if (selected) setState(() => _addGst = false);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // GST Rates List Selector
                      const Text('Select GST Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: _gstRates.map((rate) {
                          return ChoiceChip(
                            label: Text('${rate.toStringAsFixed(0)}%'),
                            selected: _selectedRate == rate,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedRate = rate;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateGst,
                        child: const Text('Calculate GST'),
                      ),
                    ],
                  ),
                ),
              ),

              if (_calculated) ...[
                const SizedBox(height: 24),
                const Text('GST Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRow('Original Amount', currencyFormat.format(_originalAmount)),
                        const Divider(height: 24),
                        _buildRow('GST Rate', '${_selectedRate.toStringAsFixed(0)}%'),
                        const Divider(height: 24),
                        _buildRow('GST Tax Amount', currencyFormat.format(_gstAmount)),
                        const Divider(height: 24),
                        _buildRow(_addGst ? 'Net Amount (Gross)' : 'Net Amount (Original)', currencyFormat.format(_finalAmount), isBold: true),
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

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: isBold ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
