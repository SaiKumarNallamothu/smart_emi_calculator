import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/ad_service.dart';


class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _investmentController = TextEditingController(text: '5000');
  final _returnController = TextEditingController(text: '12');
  final _durationController = TextEditingController(text: '10');

  bool _calculated = false;
  bool _isLoading = false;
  double _investedAmount = 0.0;
  double _estimatedReturns = 0.0;
  double _futureValue = 0.0;

  @override
  void dispose() {
    _investmentController.dispose();
    _returnController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculateSip() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final double monthlyInvestment = double.parse(_investmentController.text);
    final double expectedReturn = double.parse(_returnController.text);
    final int years = int.parse(_durationController.text);

    final int totalMonths = years * 12;
    final double monthlyRate = expectedReturn / 12 / 100;

    // SIP formula: M = P * [ ( (1 + i)^n - 1 ) / i ] * (1 + i)
    double futureValue = 0.0;
    if (monthlyRate > 0) {
      futureValue = monthlyInvestment *
          ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate) *
          (1 + monthlyRate);
    } else {
      futureValue = monthlyInvestment * totalMonths;
    }

    final double invested = monthlyInvestment * totalMonths;
    final double returns = futureValue - invested;

    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        if (!mounted) return;
        setState(() {
          _investedAmount = invested;
          _estimatedReturns = returns;
          _futureValue = futureValue;
          _calculated = true;
          _isLoading = false;
        });

        // Auto save calculation
        final provider = Provider.of<CalculatorProvider>(context, listen: false);
        provider.saveCalculation(
          type: 'SIP',
          title: 'SIP - Rs. ${NumberFormat('#,##,###').format(monthlyInvestment)}/mo @ $expectedReturn%',
          inputs: {
            'monthlyInvestment': monthlyInvestment,
            'expectedReturn': expectedReturn,
            'durationYears': years,
          },
          outputs: {
            'investedAmount': invested,
            'estimatedReturns': returns,
            'futureValue': futureValue,
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencyFormat = currencyProvider.getFormat();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        controller: _investmentController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Monthly Investment',
                          prefixText: '${currencyProvider.symbol} ',
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _returnController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Expected Return Rate (% P.A.)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Years)',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _calculateSip,
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Calculate Returns'),
                      ),
                    ],
                  ),
                ),
              ),

              if (_calculated) ...[
                const SizedBox(height: 24),
                const Text('Investment Projection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        'Est. Returns',
                        currencyFormat.format(_estimatedReturns),
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        'Total Value',
                        currencyFormat.format(_futureValue),
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('Breakdown Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value: _investedAmount,
                                  title: 'Invested',
                                  radius: 50,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: _estimatedReturns,
                                  title: 'Returns',
                                  radius: 50,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Invested Amount', Colors.blue),
                            const SizedBox(width: 24),
                            _buildLegendItem('Est. Returns', Colors.green),
                          ],
                        ),
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

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
