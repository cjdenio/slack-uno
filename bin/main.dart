import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';

import '../src/handlers/events.dart';
import '../src/handlers/interactivity.dart';
import '../src/db/db.dart';

import 'dart:io' show Platform;

main() async {
  await initDatabase();

  var app = Angel();

  app.errorHandler = (e, req, res) {
    print(e);
    print(e.stackTrace);
  };

  app.get('/', (req, res) {
    res.write("Hello earth!");
  });
  app.post('/slack/events', handleEvents);
  app.post('/slack/interactivity', handleInteractivity);

  var http = AngelHttp(app);
  await http.startServer('0.0.0.0', int.parse(Platform.environment["PORT"]));
}
