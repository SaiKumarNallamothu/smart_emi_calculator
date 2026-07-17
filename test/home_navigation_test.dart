import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emi_calculator/features/home/home_screen.dart';
import 'package:smart_emi_calculator/features/emi/emi_calculator_screen.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/providers/theme_provider.dart';
import 'helpers/fake_calculator_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home Screen navigation test to EMI Calculator', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify Home Screen elements are present
    expect(find.text('Finance Tools'), findsOneWidget);
    expect(find.text('EMI Calculator'), findsOneWidget);

    // Tap on the EMI Calculator card
    await tester.tap(find.text('EMI Calculator'));
    await tester.pumpAndSettle();

    // Verify we navigated to the EMI Calculator Screen
    expect(find.byType(EmiCalculatorScreen), findsOneWidget);
  });
}
