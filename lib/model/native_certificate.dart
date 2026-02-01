import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// An implementation of [X509Certificate] which represents a certificate loaded
/// from the platforms' native certificate store.
class NativeCertificate implements X509Certificate {
  final Uint8List _der;
  final Uint8List _sha1;
  final String _subject;
  final String _issuer;
  final DateTime _startValidity;
  final DateTime _endValidity;

  /// Creates a new instance of the [NativeCertificate] class.
  NativeCertificate({
    required Uint8List der,
    required Uint8List sha1,
    required String subject,
    required String issuer,
    required DateTime startValidity,
    required DateTime endValidity,
  }) : _der = der,
       _sha1 = sha1,
       _subject = subject,
       _issuer = issuer,
       _startValidity = startValidity,
       _endValidity = endValidity;

  @override
  Uint8List get der => _der.asUnmodifiableView();

  @override
  Uint8List get sha1 => _sha1.asUnmodifiableView();

  @override
  String get subject => _subject;

  /// Returns the Common Name (CN) extracted from the certificate's subject
  /// Distinguished Name, or `null` if no CN is present.
  ///
  /// Example: For a subject of `CN=Example Root CA, O=Example Org, C=US`,
  /// this returns `Example Root CA`.
  ///
  /// Note: The CN is primarily useful as a human-readable label. For TLS
  /// server certificates, the Subject Alternative Name (SAN) extension is
  /// the authoritative source for hostnames.
  String? get commonName {
    final match = RegExp(r'CN=([^,]+)').firstMatch(_subject);
    return match?.group(1)?.trim();
  }

  /// Returns the Organization (O) extracted from the certificate's subject
  /// Distinguished Name, or `null` if no Organization is present.
  ///
  /// Example: For a subject of `CN=Example Root CA, O=Example Org, C=US`,
  /// this returns `Example Org`.
  String? get organization {
    final match = RegExp(r'O=([^,]+)').firstMatch(_subject);
    return match?.group(1)?.trim();
  }

  /// Returns the Country (C) extracted from the certificate's subject
  /// Distinguished Name, or `null` if no Country is present.
  ///
  /// Example: For a subject of `CN=Example Root CA, O=Example Org, C=US`,
  /// this returns `US`.
  String? get country {
    final match = RegExp(r'C=([^,]+)').firstMatch(_subject);
    return match?.group(1)?.trim();
  }

  @override
  String get issuer => _issuer;

  @override
  DateTime get startValidity => _startValidity;

  @override
  DateTime get endValidity => _endValidity;

  @override
  String get pem {
    final base64Content = base64Encode(_der);
    final wrappedContent = _wrapLines(base64Content, 64);
    return '-----BEGIN CERTIFICATE-----\n$wrappedContent\n-----END CERTIFICATE-----';
  }

  @override
  String toString() {
    final sha1Hex = _sha1
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
    return 'X509Certificate(\n'
        '  Subject:        $_subject\n'
        '  Issuer:         $_issuer\n'
        '  SHA-1:          $sha1Hex\n'
        '  Valid from:     $_startValidity\n'
        '  Valid until:    $_endValidity\n'
        ')';
  }

  String _wrapLines(String input, int lineLength) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i += lineLength) {
      if (i > 0) buffer.write('\n');
      buffer.write(
        input.substring(
          i,
          i + lineLength > input.length ? input.length : i + lineLength,
        ),
      );
    }
    return buffer.toString();
  }
}
