import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gravity_swirl_game/main.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // Allow animations to settle
    await tester.pump();

    // Verify the home screen title is present.
    expect(find.text('Gravity Swirl'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
    expect(find.text('HIGH SCORES'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });

  testWidgets('Start game navigates to game screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));
    await tester.pump();

    // Tap the Start Game button.
    await tester.tap(find.text('START GAME'));
    await tester.pumpAndSettle();

    // Verify we're on the game screen with HUD elements.
    expect(find.textContaining('Level 1'), findsOneWidget);
    expect(find.textContaining('Tap & drag'), findsOneWidget);
  });
}
