import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calculator_provider.dart';
import '../../services/ad_service.dart';


class FdRdCalculatorScreen extends StatefulWidget {
  final bool isFd;

  const FdRdCalculatorScreen({super.key, required this.isFd});

  @override
  State<FdRdCalculatorScreen> createState() => _FdRdCalculatorScreenState();
}

class _FdRdCalculatorScreenState extends State<FdRdCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _depositController = TextEditingController(text: '100000');
  final _rateController = TextEditingController(text: '7.1');
  final _tenureController = TextEditingController(text: '5');

  bool _calculated = false;
  double _investedAmount = 0.0;
  double _interestEarned = 0.0;
  double _maturityAmount = 0.0;

  @override
  void dispose() {
    _depositController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final double deposit = double.parse(_depositController.text);
    final double rate = double.parse(_rateController.text);
    final double years = double.parse(_tenureController.text);

    double investedAmount = 0.0;
    double interestEarned = 0.0;
    double maturityAmount = 0.0;

    if (widget.isFd) {
      // FD - Compounded Quarterly: A = P * (1 + r/400)^(4 * t)
      final double principal = deposit;
      final double A = principal * pow(1 + (rate / 400), 4 * years);
      final double interest = A - principal;

      investedAmount = principal;
      interestEarned = interest;
      maturityAmount = A;
    } else {
      // RD - Compounded Quarterly formula for recurring monthly deposit
      final int months = (years * 12).round();
      double totalMaturity = 0.0;

      for (int i = 1; i <= months; i++) {
        // Quarter term remaining
        final double t = (months - i + 1) / 12;
        final double amount = deposit * pow(1 + (rate / 400), 4 * t);
        totalMaturity += amount;
      }

      final double invested = deposit * months;
      final double interest = totalMaturity - invested;

      investedAmount = invested;
      interestEarned = interest;
      maturityAmount = totalMaturity;
    }

    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        if (!mounted) return;
        setState(() {
          _investedAmount = investedAmount;
          _interestEarned = interestEarned;
          _maturityAmount = maturityAmount;
          _calculated = true;
        });

        // Auto save calculation
        final provider = Provider.of<CalculatorProvider>(context, listen: false);
        provider.saveCalculation(
          type: widget.isFd ? 'FD' : 'RD',
          title: '${widget.isFd ? 'FD' : 'RD'} - Rs. ${NumberFormat('#,##,###').format(deposit)} @ $rate%',
          inputs: {
            'deposit': deposit,
            'interestRate': rate,
            'tenureYears': years,
          },
          outputs: {
            'interestEarned': interestEarned,
            'maturityAmount': maturityAmount,
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFd ? 'FD Calculator' : 'RD Calculator', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    children: [
                      TextFormField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: widget.isFd ? 'FD Deposit Amount' : 'RD Monthly Deposit',
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Interest Rate (% P.A.)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tenureController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Tenure (Years)',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _calculate,
                        child: const Text('Calculate Maturity'),
                      ),
                    ],
                  ),
                ),
              ),

              if (_calculated) ...[
                const SizedBox(height: 24),
                const Text('Maturity Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        'Invested Amount',
                        currencyFormat.format(_investedAmount),
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultCard(
                        'Interest Earned',
                        currencyFormat.format(_interestEarned),
                        Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        'Maturity Amount',
                        currencyFormat.format(_maturityAmount),
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
