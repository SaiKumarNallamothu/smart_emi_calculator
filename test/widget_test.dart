import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_emi_calculator/features/age/age_calculator_screen.dart';

void main() {
  testWidgets('Age Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: AgeCalculatorScreen(),
      ),
    );

    // Verify input fields are present
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Today\'s Date'), findsOneWidget);
    expect(find.text('Calculate Age'), findsOneWidget);

    // Age details should not be shown yet
    expect(find.text('Age Details'), findsNothing);

    // Tap the calculate button and trigger a frame.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify age details show up after calculation
    expect(find.text('Age Details'), findsOneWidget);
  });
}
