import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/ad_service.dart';

class LoanComparisonScreen extends StatefulWidget {
  const LoanComparisonScreen({super.key});

  @override
  State<LoanComparisonScreen> createState() => _LoanComparisonScreenState();
}

class _LoanComparisonScreenState extends State<LoanComparisonScreen> {
  final _formKey = GlobalKey<FormState>();

  // Loan A Controllers
  final _amountAController = TextEditingController(text: '1000000');
  final _rateAController = TextEditingController(text: '8.5');
  final _tenureAController = TextEditingController(text: '120');

  // Loan B Controllers
  final _amountBController = TextEditingController(text: '1000000');
  final _rateBController = TextEditingController(text: '7.8');
  final _tenureBController = TextEditingController(text: '120');

  bool _compared = false;
  bool _isLoading = false;

  // Loan A Results
  double _emiA = 0.0;
  double _interestA = 0.0;
  double _totalA = 0.0;

  // Loan B Results
  double _emiB = 0.0;
  double _interestB = 0.0;
  double _totalB = 0.0;

  // Winner highlights
  String _winner = '';
  double _savings = 0.0;

  @override
  void dispose() {
    _amountAController.dispose();
    _rateAController.dispose();
    _tenureAController.dispose();
    _amountBController.dispose();
    _rateBController.dispose();
    _tenureBController.dispose();
    super.dispose();
  }

  void _compareLoans() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final double amountA = double.parse(_amountAController.text);
    final double rateA = double.parse(_rateAController.text);
    final int tenureA = int.parse(_tenureAController.text);

    final double amountB = double.parse(_amountBController.text);
    final double rateB = double.parse(_rateBController.text);
    final int tenureB = int.parse(_tenureBController.text);

    // Calculate Loan A
    final double monthlyRateA = rateA / 12 / 100;
    double emiA = 0.0;
    if (monthlyRateA > 0) {
      emiA =
          (amountA * monthlyRateA * pow(1 + monthlyRateA, tenureA)) /
          (pow(1 + monthlyRateA, tenureA) - 1);
    } else {
      emiA = amountA / tenureA;
    }
    double totalA = emiA * tenureA;
    double interestA = totalA - amountA;

    // Calculate Loan B
    final double monthlyRateB = rateB / 12 / 100;
    double emiB = 0.0;
    if (monthlyRateB > 0) {
      emiB =
          (amountB * monthlyRateB * pow(1 + monthlyRateB, tenureB)) /
          (pow(1 + monthlyRateB, tenureB) - 1);
    } else {
      emiB = amountB / tenureB;
    }
    double totalB = emiB * tenureB;
    double interestB = totalB - amountB;

    // Compare
    String winner = '';
    double savings = 0.0;
    if (totalA < totalB) {
      winner = 'Loan A';
      savings = totalB - totalA;
    } else if (totalB < totalA) {
      winner = 'Loan B';
      savings = totalA - totalB;
    } else {
      winner = 'Tie';
      savings = 0.0;
    }

    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        if (!mounted) return;
        setState(() {
          _emiA = emiA;
          _interestA = interestA;
          _totalA = totalA;
          _emiB = emiB;
          _interestB = interestB;
          _totalB = totalB;
          _winner = winner;
          _savings = savings;
          _compared = true;
          _isLoading = false;
        });

        // Auto save calculation
        final provider = Provider.of<CalculatorProvider>(
          context,
          listen: false,
        );
        provider.saveCalculation(
          type: 'Compare',
          title: 'Compare: Loan A vs Loan B',
          inputs: {
            'loanA_Amount': amountA,
            'loanA_Rate': rateA,
            'loanA_Tenure': tenureA,
            'loanB_Amount': amountB,
            'loanB_Rate': rateB,
            'loanB_Tenure': tenureB,
          },
          outputs: {
            'winner': winner,
            'savings': savings,
            'loanA_EMI': emiA,
            'loanB_EMI': emiB,
          },
        );
      },
    );
  }

  void _reset() {
    _amountAController.clear();
    _rateAController.clear();
    _tenureAController.clear();
    _amountBController.clear();
    _rateBController.clear();
    _tenureBController.clear();
    setState(() {
      _compared = false;
      _winner = '';
      _savings = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencyFormat = currencyProvider.getFormat();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Loans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LOAN A
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const Text(
                              'Loan A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _amountAController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '${currencyProvider.symbol} ',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _rateAController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Rate %',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _tenureAController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Tenure (Mo.)',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // LOAN B
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const Text(
                              'Loan B',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _amountBController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '${currencyProvider.symbol} ',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _rateBController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Rate %',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _tenureBController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Tenure (Mo.)',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _compareLoans,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Compare Loans'),
              ),

              if (_compared) ...[
                const SizedBox(height: 24),

                // Winner highlight
                if (_winner != 'Tie')
                  Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.green,
                            size: 36,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Winner: $_winner',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You will save ${currencyFormat.format(_savings)} in total payment!',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Both loans are identical in terms of total repayments.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Side by side Comparison Metrics
                const Text(
                  'Comparison Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Metrics',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Loan A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Loan B',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Monthly EMI'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(currencyFormat.format(_emiA)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(currencyFormat.format(_emiB)),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Total Interest'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(currencyFormat.format(_interestA)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(currencyFormat.format(_interestB)),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Total Payment'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(currencyFormat.format(_totalA)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(currencyFormat.format(_totalB)),
                        ),
                      ],
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
}
