# Flutter Native Certs

<p align="center">
<a href="https://pub.dev/packages/flutter_native_certs"><img src="https://img.shields.io/pub/v/flutter_native_certs.svg" alt="Pub"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

A Flutter plugin to use the certificates from the native certificate store on every platform.

## Background
Flutter does not use the native certificate store on every platform.

### Android
Flutter uses a custom certificate bundle of trusted root certificates.
There are several issues related to this topic:
* https://github.com/dart-lang/sdk/issues/50435
* https://github.com/dart-lang/sdk/issues/48056

This issue is especially important if the [`dart:io:HttpClient`](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html) or the [`IOClient`](https://pub.dev/documentation/http/latest/io_client/IOClient-class.html) must be used, because it does rely on [`SecurityContext.defaultContext`](https://api.flutter.dev/flutter/dart-io/SecurityContext/defaultContext.html) by default.

#### Side Note: `network_security_config.xml`
Normally for trusting user certificates on Android a [`network_security_config.xml`](https://developer.android.com/privacy-and-security/security-config) similar to the sample below would need to be placed inside `android/app/src/main/res/xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <base-config>
    <trust-anchors>
      <certificates src="system"/>
      <certificates src="user"/>
    </trust-anchors>
  </base-config>
</network-security-config>
```
This is **not necessary** for `flutter_native_certs`, but is still recommended if a package like [`cronet_http`](https://pub.dev/packages/cronet_http) is used which *does consider* user certificates even on Android.

## Getting Started
This plugin provides a custom [`SecurityContext`](https://api.flutter.dev/flutter/dart-io/SecurityContext-class.html) which includes certificates loaded from the native certificate store at startup.

Please note that due to the architecture of this plugin user installed certificates are not trusted until the app is fully restarted.

### Installation
Run
```bash
flutter pub add flutter_native_certs
```
in order to install the plugin.

### Initialization
The plugin must be initialized at application startup.

It is recommended to make the `main` function `async` and initialize the plugin there, before calling [`runApp`](https://api.flutter.dev/flutter/widgets/runApp.html):
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FlutterNativeCerts.instance.initialize();
  } on PlatformException catch (e) {
    debugPrint(
      'Failed to initialize FlutterNativeCerts plugin: ${e.toString()}',
    );
  }

  runApp(const MyApp());
}
```

### Usage
The plugin provides a custom [`SecurityContext`](https://api.flutter.dev/flutter/dart-io/SecurityContext-class.html) that must be used everywhere, where the native certificates should be used.

#### [`HttpClient`](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html)
In order to use the plugin with the [`HttpClient`](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html) from [`dart:io`](https://api.flutter.dev/flutter/dart-io/), supply its [`SecurityContext`](https://api.flutter.dev/flutter/dart-io/SecurityContext-class.html) to the constructor of the client:
```dart
HttpClient(
    context: FlutterNativeCerts.instance.securityContext
)
```

#### [`IOClient`](https://pub.dev/documentation/http/latest/io_client/IOClient-class.html)
If the plugin should be used with the [`IOClient`](https://pub.dev/documentation/http/latest/io_client/IOClient-class.html) from the [`http`](https://pub.dev/packages/http) package, a custom [`HttpClient`](https://api.flutter.dev/flutter/dart-io/HttpClient-class.html) must be created as demonstrated above and then this client must be supplied to the constructor of the `IOClient`:
```dart
IOClient(
    HttpClient(
        context: FlutterNativeCerts.instance.securityContext
    )
)
```

## Platform Support
While the plugin **supports all platforms**, it is currently only useful on Android.

On all platforms except Android `FlutterNativeCerts.instance.securityContext` will be the same as [`SecurityContext.defaultContext`](https://api.flutter.dev/flutter/dart-io/SecurityContext/defaultContext.html) regardless of the parameters specified when calling `FlutterNativeCerts.instance.initialize()`.

## License
Released under the terms of the MIT License.