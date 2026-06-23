import 'package:flutter_test/flutter_test.dart';
import 'package:f4_supermarket/main.dart';

void main() {
  testWidgets('F4 Supermarket app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const F4SupermarketApp());
  });
}
