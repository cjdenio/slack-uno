import 'dart:io' show Platform;

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';

import '../src/db/db.dart';
import '../src/handlers/events.dart';
import '../src/handlers/interactivity.dart';
import '../src/hn/hn.dart';

void main() async {
  await giveHn("U01AAM4E1M4", "U013B6CPV62", 5);
  await initDatabase();

  var app = Angel();

  app.errorHandler = (e, req, res) {
    print(e);
    print(e.stackTrace);
  };

  app.get('/', (req, res) {
    res.redirect("https://github.com/cjdenio/slack-uno");
  });
  app.post('/slack/events', handleEvents);
  app.post('/slack/interactivity', handleInteractivity);

  var http = AngelHttp(app);
  await http.startServer('0.0.0.0', int.parse(Platform.environment["PORT"]));
}
