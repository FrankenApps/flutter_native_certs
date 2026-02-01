import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_native_certs/flutter_native_certs.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TlsProbePage());
  }
}

class TlsProbePage extends StatefulWidget {
  const TlsProbePage({super.key});

  @override
  State<TlsProbePage> createState() => _TlsProbePageState();
}

class _TlsProbePageState extends State<TlsProbePage> {
  final _controller = TextEditingController(text: 'https://example.com');
  bool? _trusted;
  String? _error;
  bool _loading = false;

  Future<void> _probe({bool withCustomSecurityContext = true}) async {
    setState(() {
      _loading = true;
      _trusted = null;
      _error = null;
    });

    try {
      final uri = Uri.parse(_controller.text);

      final client = withCustomSecurityContext
          ? HttpClient(context: FlutterNativeCerts.instance.securityContext)
          : HttpClient(context: SecurityContext.defaultContext);
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(uri);
      final response = await request.close();
      await response.drain();

      setState(() {
        _trusted = true;
      });
    } on HandshakeException catch (e) {
      setState(() {
        _trusted = false;
        _error = e.message;
      });
    } on Exception catch (e) {
      setState(() {
        _trusted = null;
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TLS Trust Probe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Endpoint URL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://host:port',
              ),
              onEditingComplete: _probe,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _probe,
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send TLS Request'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => _probe(withCustomSecurityContext: false),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send with default SecurityContext'),
            ),
            const SizedBox(height: 24),
            if (_trusted != null)
              Row(
                children: [
                  Icon(
                    _trusted! ? Icons.check_circle : Icons.error,
                    color: _trusted! ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _trusted!
                        ? 'Handshake succeeded — CA is trusted'
                        : 'Handshake failed — CA is NOT trusted',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
