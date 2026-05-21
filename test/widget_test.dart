// This is a basic Flutter widget test for MudiriApp.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mudiri/app.dart';
import 'package:mudiri/core/constants/app_constants.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MudiriApp(),
      ),
    );

    // Verify that the splash screen displays the app name
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Pump the timer forward by the splash duration so that the navigation timer fires
    await tester.pump(const Duration(milliseconds: 1500));
    // Let the routing complete by pumping a few frames manually
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}

