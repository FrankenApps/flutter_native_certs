import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_certs/flutter_native_certs.dart';
import 'package:flutter_native_certs/flutter_native_certs_platform_interface.dart';
import 'package:flutter_native_certs/flutter_native_certs_method_channel.dart';
import 'package:flutter_native_certs/model/native_certificate.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNativeCertsPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNativeCertsPlatform {
  @override
  Future<List<X509Certificate>> getCertificates({
    bool includeSystemCertificates = true,
    bool includeUserCertificates = true,
  }) => Future.value([
    NativeCertificate(
      der: Uint8List.fromList([0x30, 0x82]),
      sha1: Uint8List.fromList(List.filled(20, 0)),
      subject: 'CN=Test Subject',
      issuer: 'CN=Test Issuer',
      startValidity: DateTime(2024, 1, 1),
      endValidity: DateTime(2025, 1, 1),
    ),
  ]);
}

void main() {
  final FlutterNativeCertsPlatform initialPlatform =
      FlutterNativeCertsPlatform.instance;

  test('$MethodChannelFlutterNativeCerts is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNativeCerts>());
  });

  test('initialize completes without error', () async {
    FlutterNativeCerts flutterNativeCertsPlugin = FlutterNativeCerts.instance;
    MockFlutterNativeCertsPlatform fakePlatform =
        MockFlutterNativeCertsPlatform();
    FlutterNativeCertsPlatform.instance = fakePlatform;

    await flutterNativeCertsPlugin.initialize();
  });
}
