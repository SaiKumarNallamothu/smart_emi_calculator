import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/ad_service.dart';


class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '1000000');
  final _rateController = TextEditingController(text: '8.5');
  final _tenureController = TextEditingController(text: '120');
  final _feeController = TextEditingController(text: '10000');
  final _extraController = TextEditingController(text: '0');

  bool _isYears = false;
  bool _calculated = false;
  bool _isLoading = false;

  double _monthlyEmi = 0.0;
  double _totalInterest = 0.0;
  double _totalPayment = 0.0;
  List<double> _balanceTrend = [];

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _feeController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  void _calculateEmi() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final double principal = double.parse(_amountController.text);
    final double annualRate = double.parse(_rateController.text);
    final int tenureVal = int.parse(_tenureController.text);
    final int months = _isYears ? tenureVal * 12 : tenureVal;
    final double extra = double.tryParse(_extraController.text) ?? 0.0;

    final double monthlyRate = annualRate / 12 / 100;

    // Standard EMI formula
    double emi = 0.0;
    if (monthlyRate > 0) {
      emi = (principal * monthlyRate * pow(1 + monthlyRate, months)) /
          (pow(1 + monthlyRate, months) - 1);
    } else {
      emi = principal / months;
    }

    // Amortization Schedule (considering extra payment if any)
    double remainingBalance = principal;
    double totalInt = 0.0;
    List<double> balanceTrend = [principal];

    for (int i = 0; i < months; i++) {
      if (remainingBalance <= 0) {
        balanceTrend.add(0.0);
        continue;
      }
      final double interestForMonth = remainingBalance * monthlyRate;
      totalInt += interestForMonth;

      final double principalForMonth = (emi - interestForMonth) + extra;
      remainingBalance -= principalForMonth;

      if (remainingBalance < 0) {
        remainingBalance = 0;
      }
      balanceTrend.add(remainingBalance);
    }

    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        if (!mounted) return;
        setState(() {
          _monthlyEmi = emi;
          _totalInterest = totalInt;
          _totalPayment = principal + totalInt;
          _balanceTrend = balanceTrend;
          _calculated = true;
          _isLoading = false;
        });

        // Save calculation auto to DB
        final provider = Provider.of<CalculatorProvider>(context, listen: false);
        provider.saveCalculation(
          type: 'EMI',
          title: 'EMI - Rs. ${NumberFormat('#,##,###').format(principal)} @ ${annualRate.toStringAsFixed(1)}%',
          inputs: {
            'loanAmount': principal,
            'interestRate': annualRate,
            'tenureMonths': months,
            'processingFee': double.tryParse(_feeController.text) ?? 0.0,
            'extraMonthlyPayment': extra,
          },
          outputs: {
            'monthlyEmi': emi,
            'totalInterest': totalInt,
            'totalPayment': principal + totalInt,
          },
        );
      },
    );
  }



  void _reset() {
    _amountController.text = '';
    _rateController.text = '';
    _tenureController.text = '';
    _feeController.text = '0';
    _extraController.text = '0';
    setState(() {
      _calculated = false;
      _monthlyEmi = 0.0;
      _totalInterest = 0.0;
      _totalPayment = 0.0;
      _balanceTrend = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencyFormat = currencyProvider.getFormat();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        child: AdBannerWidget(),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INPUT CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Loan Amount (Principal)',
                          prefixText: '${currencyProvider.symbol} ',
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Enter loan amount' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Interest Rate (% P.A.)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Enter interest rate' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tenureController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: _isYears ? 'Tenure (Years)' : 'Tenure (Months)',
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Enter tenure' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(12),
                            isSelected: [!_isYears, _isYears],
                            onPressed: (index) {
                              setState(() {
                                _isYears = index == 1;
                              });
                            },
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Months'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Years'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ExpansionTile(
                        title: const Text('Advanced Options (Optional)', style: TextStyle(fontSize: 14)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _feeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Processing Fee',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _extraController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Extra Monthly Payment',
                                prefixIcon: Icon(Icons.add_circle_outline),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _calculateEmi,
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Calculate EMI'),
                      ),
                    ],
                  ),
                ),
              ),

              // RESULTS & CHARTS
              if (_calculated) ...[
                const SizedBox(height: 24),
                const Text('Repayment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        'Monthly EMI',
                        currencyFormat.format(_monthlyEmi),
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultCard(
                        'Total Interest',
                        currencyFormat.format(_totalInterest),
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
                        'Total Payment',
                        currencyFormat.format(_totalPayment),
                        Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Breakup Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Pie Chart
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
                                  color: Theme.of(context).colorScheme.primary,
                                  value: _totalPayment - _totalInterest,
                                  title: 'Principal',
                                  radius: 50,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                PieChartSectionData(
                                  color: Colors.amber.shade700,
                                  value: _totalInterest,
                                  title: 'Interest',
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
                            _buildLegendItem('Principal', Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 24),
                            _buildLegendItem('Interest', Colors.amber.shade700),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text('Remaining Balance Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 24.0, top: 24.0, bottom: 12.0),
                    child: SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: max(1.0, _balanceTrend.length / 5.0),
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < _balanceTrend.length) {
                                    if (index == 0) return const Text('Start', style: TextStyle(fontSize: 10, color: Colors.grey));
                                    if (index == _balanceTrend.length - 1) return const Text('End', style: TextStyle(fontSize: 10, color: Colors.grey));
                                    if (index == (_balanceTrend.length ~/ 2)) {
                                      return Text('${_isYears ? (index ~/ 12) : index} ${_isYears ? 'Yr' : 'Mo'}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                                    }
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                _balanceTrend.length,
                                (index) => FlSpot(index.toDouble(), _balanceTrend[index]),
                              ),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Export/Share Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () {
                          final text = 'Loan EMI Details:\nMonthly EMI: ${currencyFormat.format(_monthlyEmi)}\nTotal Interest: ${currencyFormat.format(_totalInterest)}\nTotal Repayment: ${currencyFormat.format(_totalPayment)}';
                          Share.share(text);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                        onPressed: () {
                          PDFService.sharePdfReport(
                            loanAmount: double.parse(_amountController.text),
                            interestRate: double.parse(_rateController.text),
                            tenureMonths: _isYears
                                ? int.parse(_tenureController.text) * 12
                                : int.parse(_tenureController.text),
                            monthlyEmi: _monthlyEmi,
                            totalInterest: _totalInterest,
                            totalPayment: _totalPayment,
                            processingFee: double.tryParse(_feeController.text) ?? 0.0,
                            extraPayment: double.tryParse(_extraController.text) ?? 0.0,
                            currencyFormat: currencyFormat,
                          );
                        },
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
      elevation: 1,
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
