import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emi_calculator/features/fd/fd_rd_calculator_screen.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/providers/theme_provider.dart';
import 'helpers/fake_calculator_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FD Calculator calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: FdRdCalculatorScreen(isFd: true),
        ),
      ),
    );

    // Verify default value
    expect(find.text('100000'), findsOneWidget);

    // Tap Calculate Maturity
    await tester.tap(find.text('Calculate Maturity'));
    await tester.pumpAndSettle();

    // Verify output shows up
    expect(find.text('Maturity Details'), findsOneWidget);
    expect(fakeCalcProvider.history.length, 1);
    expect(fakeCalcProvider.history.first.type, 'FD');
  });

  testWidgets('RD Calculator calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: FdRdCalculatorScreen(isFd: false),
        ),
      ),
    );

    // Tap Calculate Maturity
    await tester.tap(find.text('Calculate Maturity'));
    await tester.pumpAndSettle();

    // Verify output shows up
    expect(find.text('Maturity Details'), findsOneWidget);
    expect(fakeCalcProvider.history.length, 1);
    expect(fakeCalcProvider.history.first.type, 'RD');
  });
}
