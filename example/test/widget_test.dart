import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_native_certs_example/main.dart';

void main() {
  testWidgets('App renders TLS Trust Probe page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TLS Trust Probe'), findsOneWidget);
    expect(find.text('Send TLS Request'), findsOneWidget);
    expect(find.text('Send with default SecurityContext'), findsOneWidget);
  });
}
