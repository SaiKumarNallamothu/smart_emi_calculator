import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime _dob = DateTime(2000, 1, 1);
  DateTime _today = DateTime.now();
  bool _calculated = false;

  int _years = 0;
  int _months = 0;
  int _days = 0;
  int _totalDays = 0;
  int _nextBdayMonths = 0;
  int _nextBdayDays = 0;

  void _calculateAge() {
    if (_dob.isAfter(_today)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Dates'),
          content: const Text('Date of birth cannot be after today.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Calculate years, months, days
    int years = _today.year - _dob.year;
    int months = _today.month - _dob.month;
    int days = _today.day - _dob.day;

    if (days < 0) {
      // borrow days from previous month
      final prevMonthDate = DateTime(_today.year, _today.month, 0);
      days += prevMonthDate.day;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    // Total Days lived
    final difference = _today.difference(_dob);
    final totalDays = difference.inDays;

    // Next Birthday countdown
    DateTime nextBday = DateTime(_today.year, _dob.month, _dob.day);
    if (nextBday.isBefore(_today) || nextBday.isAtSameMomentAs(_today)) {
      nextBday = DateTime(_today.year + 1, _dob.month, _dob.day);
    }

    int nextMonths = nextBday.month - _today.month;
    int nextDays = nextBday.day - _today.day;

    if (nextDays < 0) {
      final prevMonthDate = DateTime(nextBday.year, nextBday.month, 0);
      nextDays += prevMonthDate.day;
      nextMonths--;
    }

    if (nextMonths < 0) {
      nextMonths += 12;
    }

    if (!mounted) return;
    setState(() {
      _years = years;
      _months = months;
      _days = days;
      _totalDays = totalDays;
      _nextBdayMonths = nextMonths;
      _nextBdayDays = nextDays;
      _calculated = true;
    });
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
        _calculated = false;
      });
    }
  }

  Future<void> _selectToday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _today,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _today) {
      setState(() {
        _today = picked;
        _calculated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Age Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // DOB selection
                    ListTile(
                      leading: const Icon(Icons.cake, color: Colors.blue),
                      title: const Text('Date of Birth'),
                      subtitle: Text(df.format(_dob)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () => _selectDob(context),
                    ),
                    const Divider(),
                    // Today selection
                    ListTile(
                      leading: const Icon(Icons.today, color: Colors.green),
                      title: const Text('Today\'s Date'),
                      subtitle: Text(df.format(_today)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () => _selectToday(context),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateAge,
                      child: const Text('Calculate Age'),
                    ),
                  ],
                ),
              ),
            ),

            if (_calculated) ...[
              const SizedBox(height: 24),
              const Text(
                'Age Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildMetricCard('$_years', 'Years')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard('$_months', 'Months')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricCard('$_days', 'Days')),
                ],
              ),

              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Days lived',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '$_totalDays days',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Next Birthday in',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '$_nextBdayMonths Months, $_nextBdayDays Days',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
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
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
