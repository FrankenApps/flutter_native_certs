import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'flutter_native_certs_platform_interface.dart';

/// A class used to interact with certificates loaded from the platforms' native
/// certificate store.
class FlutterNativeCerts {
  static final FlutterNativeCerts _instance = FlutterNativeCerts._internal();
  bool _isInitializing = false;
  bool _isInitialized = false;

  late final SecurityContext _securityContext;

  FlutterNativeCerts._internal();

  /// Gets the [FlutterNativeCerts] singleton instance.
  static FlutterNativeCerts get instance => _instance;

  /// Gets a [SecurityContext] that uses the certificates loaded from the
  /// certificate stores declared in the [initialize] invocation.
  ///
  /// On all platforms except Android this is always the same as
  /// [SecurityContext.defaultContext].
  ///
  /// Throws a [StateError] if the [FlutterNativeCerts] plugin is not fully
  /// initialized when the getter is called.
  SecurityContext get securityContext {
    if (!_isInitialized) {
      throw StateError('The plugin is not initialized.');
    }

    if (_isInitializing) {
      throw StateError(
        'The plugin is currently within the process of being initialized.',
      );
    }

    if (!Platform.isAndroid) {
      return SecurityContext.defaultContext;
    }

    return _securityContext;
  }

  /// Initializes the plugin.
  ///
  /// This method must only be called once at startup.
  ///
  /// The following parameters are available:
  /// * `includeDefaultFlutterCertificates`: Whether to include the certificates
  /// bundled with the Flutter framework.
  /// * `includeSystemCertificates`: Whether to include the native system
  /// certificates.
  /// * `includeUserCertificates`: Whether to include custom user installed
  /// certificates.
  Future<void> initialize({
    bool includeDefaultFlutterCertificates = false,
    bool includeSystemCertificates = true,
    bool includeUserCertificates = true,
  }) async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    // Loading user certificates is only supported on Android for now.
    if (!Platform.isAndroid) {
      _isInitialized = true;
      return;
    }

    _isInitializing = true;

    final certificates = await FlutterNativeCertsPlatform.instance
        .getCertificates(
          includeSystemCertificates: includeSystemCertificates,
          includeUserCertificates: includeUserCertificates,
        );

    if (const bool.fromEnvironment(
      'LOG_TRUSTED_CERTIFICATES',
      defaultValue: false,
    )) {
      for (final certificate in certificates) {
        debugPrint(certificate.toString());
      }
    }

    _securityContext = SecurityContext(
      withTrustedRoots: includeDefaultFlutterCertificates,
    );
    for (final certificate in certificates) {
      _securityContext.setTrustedCertificatesBytes(
        utf8.encode(certificate.pem),
      );
    }

    _isInitialized = true;
    _isInitializing = false;
  }
}
