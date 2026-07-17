import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_emi_calculator/features/gst/gst_calculator_screen.dart';
import 'package:smart_emi_calculator/providers/calculator_provider.dart';
import 'package:smart_emi_calculator/providers/theme_provider.dart';
import 'helpers/fake_calculator_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GST Calculator calculation test', (WidgetTester tester) async {
    final fakeCalcProvider = FakeCalculatorProvider();
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: fakeCalcProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: GstCalculatorScreen(),
        ),
      ),
    );

    // Verify initial values
    expect(find.text('10000'), findsOneWidget); // amount default

    // Tap Calculate GST
    await tester.tap(find.text('Calculate GST'));
    await tester.pumpAndSettle();

    // Verify output shows up
    expect(find.text('GST Breakdown'), findsOneWidget);
    expect(fakeCalcProvider.history.length, 1);
    expect(fakeCalcProvider.history.first.type, 'GST');
  });
}
