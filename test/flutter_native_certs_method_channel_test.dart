import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_certs/flutter_native_certs_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterNativeCerts platform = MethodChannelFlutterNativeCerts();
  const MethodChannel channel = MethodChannel('flutter_native_certs');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return [
            {
              'subject': 'CN=Test Subject',
              'issuer': 'CN=Test Issuer',
              'der': Uint8List.fromList([0x30, 0x82]),
              'sha1': Uint8List.fromList(List.filled(20, 0)),
              'startValidity': 1704067200000, // 2024-01-01
              'endValidity': 1735689600000,   // 2025-01-01
            }
          ];
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getCertificates returns parsed certificates', () async {
    final certs = await platform.getCertificates();
    expect(certs.length, 1);
    expect(certs.first.subject, 'CN=Test Subject');
    expect(certs.first.issuer, 'CN=Test Issuer');
  });
}
