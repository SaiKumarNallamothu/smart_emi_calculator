import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emi_calculator/features/comparison/loan_comparison_screen.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/providers/theme_provider.dart';
import 'helpers/fake_calculator_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Loan Comparison calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: LoanComparisonScreen(),
        ),
      ),
    );

    // Verify default values
    expect(find.text('1000000'), findsNWidgets(2)); // Loan A and Loan B default amounts
    expect(find.text('8.5'), findsOneWidget); // Loan A default rate
    expect(find.text('7.8'), findsOneWidget); // Loan B default rate

    // Tap Compare Loans
    await tester.tap(find.widgetWithText(ElevatedButton, 'Compare Loans'));
    await tester.pumpAndSettle();

    // Verify comparison completed
    expect(fakeCalcProvider.history.length, 1);
    expect(fakeCalcProvider.history.first.type, 'Compare');
    expect(find.textContaining('Loan B'), findsWidgets); // Winner highlight should mention Loan B because rate is lower
  });
}
