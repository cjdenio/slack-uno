import 'package:angel_framework/angel_framework.dart';
import 'dart:io' show Platform;
import '../slack/slack.dart';
import '../slack/app_home.dart';

handleEvents(RequestContext<dynamic> req, ResponseContext<dynamic> res) async {
  var client = SlackClient(Platform.environment["SLACK_TOKEN"]);

  await req.parseBody();
  var body = req.bodyAsMap;

  if (body["type"] == "url_verification") {
    res.write(body["challenge"]);
    return;
  }

  switch (body["event"]["type"]) {
    case "app_home_opened":
      await updateAppHome(body["event"]["user"]);
      break;
  }
}
