import 'package:flutter_test/flutter_test.dart';
import 'package:yugal/main.dart';

void main() {
  testWidgets('App launches to onboarding', (tester) async {
    await tester.pumpWidget(const YugalApp());
    expect(find.text('Yugal'), findsWidgets);
  });
}
