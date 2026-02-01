import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

Future<void> main() async {
  final securityContext = SecurityContext()
    ..useCertificateChain('server.crt')
    ..usePrivateKey('server.key');

  // If the "PORT" environment variable is set, listen to it. Otherwise use port
  // 8080.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await HttpServer.bindSecure(
    InternetAddress.anyIPv4, // Allow external connections
    port,
    securityContext,
  );

  print('Serving at https://${server.address.host}:${server.port}');

  shelf_io.serveRequests(server, _router.call);
}

final _router = shelf_router.Router()..get('/', _rootHandler);

Response _rootHandler(Request request) => Response.ok('Hello, World!');
