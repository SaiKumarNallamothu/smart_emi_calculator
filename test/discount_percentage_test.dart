import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emi_calculator/features/discount/discount_percentage_screens.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/providers/theme_provider.dart';
import 'helpers/fake_calculator_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Discount Calculator calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: DiscountCalculatorScreen(),
        ),
      ),
    );

    // Verify initial values
    expect(find.text('1999'), findsOneWidget); // Original price default
    expect(find.text('20'), findsOneWidget); // Discount % default

    // Tap Calculate
    await tester.tap(find.text('Calculate Discount'));
    await tester.pumpAndSettle();

    // Verify savings and final price
    expect(find.text('Discount Details'), findsOneWidget);
    expect(fakeCalcProvider.history.length, 1);
    expect(fakeCalcProvider.history.first.type, 'Discount');
  });

  testWidgets('Percentage Calculator calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: PercentageCalculatorScreen(),
        ),
      ),
    );

    // Default values for Tab 0: Find 10% of 250
    expect(find.text('10'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);

    // Tap Calculate
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    // 10% of 250 should be 25.00
    expect(find.text('Result: 25.00'), findsOneWidget);
  });
}
