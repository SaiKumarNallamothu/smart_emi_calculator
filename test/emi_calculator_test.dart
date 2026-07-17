import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emi_calculator/features/emi/emi_calculator_screen.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/providers/theme_provider.dart';
import 'helpers/fake_calculator_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('EMI Calculator calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: EmiCalculatorScreen(),
        ),
      ),
    );

    // Verify initial values in TextFields
    expect(find.text('1000000'), findsOneWidget); // principal default
    expect(find.text('8.5'), findsOneWidget); // rate default
    expect(find.text('120'), findsOneWidget); // tenure default

    // Tap Calculate EMI
    await tester.tap(find.text('Calculate EMI'));
    await tester.pumpAndSettle();

    // Verify calculation output is shown
    expect(find.text('Repayment Summary'), findsOneWidget);
    expect(fakeCalcProvider.history.length, 1);
    expect(fakeCalcProvider.history.first.type, 'EMI');
  });
}
