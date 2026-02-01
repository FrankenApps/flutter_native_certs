import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_certs/model/native_certificate.dart';

import 'flutter_native_certs_platform_interface.dart';

/// An implementation of [FlutterNativeCertsPlatform] that uses method channels.
class MethodChannelFlutterNativeCerts extends FlutterNativeCertsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_certs');

  @override
  Future<List<X509Certificate>> getCertificates({
    bool includeSystemCertificates = true,
    bool includeUserCertificates = true,
  }) async {
    final result = await methodChannel
        .invokeMethod<List<dynamic>>('getCertificates', <String, dynamic>{
          'includeSystemCertificates': includeSystemCertificates,
          'includeUserCertificates': includeUserCertificates,
        });

    if (result == null) {
      return [];
    }

    return result.map((item) {
      final map = item as Map<Object?, Object?>;
      return NativeCertificate(
        der: map['der'] as Uint8List,
        sha1: map['sha1'] as Uint8List,
        subject: map['subject'] as String,
        issuer: map['issuer'] as String,
        startValidity: DateTime.fromMillisecondsSinceEpoch(
          map['startValidity'] as int,
        ),
        endValidity: DateTime.fromMillisecondsSinceEpoch(
          map['endValidity'] as int,
        ),
      );
    }).toList();
  }
}
