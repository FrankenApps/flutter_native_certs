import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_certs_method_channel.dart';

/// Represents the platform interface for the flutter_native_certs plugin.
abstract class FlutterNativeCertsPlatform extends PlatformInterface {
  /// Constructs a FlutterNativeCertsPlatform.
  FlutterNativeCertsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativeCertsPlatform _instance =
      MethodChannelFlutterNativeCerts();

  /// The default instance of [FlutterNativeCertsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativeCerts].
  static FlutterNativeCertsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativeCertsPlatform] when
  /// they register themselves.
  static set instance(FlutterNativeCertsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Loads all certificates from the native certificate store of the current
  /// platform.
  Future<List<X509Certificate>> getCertificates({
    bool includeSystemCertificates = true,
    bool includeUserCertificates = true,
  }) {
    throw UnimplementedError(
      'The getCertificates method has not been implemented.',
    );
  }
}
