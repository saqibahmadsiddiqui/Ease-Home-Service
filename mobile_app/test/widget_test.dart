import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: EaseHomeServiceApp()));

    // Verify that the splash screen or initial app structures exist.
    expect(find.byType(EaseHomeServiceApp), findsOneWidget);
  });
}
