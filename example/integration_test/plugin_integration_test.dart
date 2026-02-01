import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_native_certs/flutter_native_certs.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initialize completes without error', (WidgetTester tester) async {
    await FlutterNativeCerts.instance.initialize();

    // securityContext should be accessible after initialization.
    final context = FlutterNativeCerts.instance.securityContext;
    expect(context, isA<SecurityContext>());
  });

  testWidgets('HTTPS request succeeds with native certs',
      (WidgetTester tester) async {
    await FlutterNativeCerts.instance.initialize();

    // A real HTTPS request proves the SecurityContext trusts well-known CAs.
    final client = HttpClient(
      context: FlutterNativeCerts.instance.securityContext,
    );
    client.connectionTimeout = const Duration(seconds: 10);

    final request = await client.getUrl(Uri.parse('https://example.com'));
    final response = await request.close();
    await response.drain<void>();

    expect(response.statusCode, 200);
    client.close();
  });
}
