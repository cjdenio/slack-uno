import 'dart:convert';

import 'package:angel_framework/angel_framework.dart';
import '../slack/app_home.dart';
import '../util/util.dart' as util;

void handleEvents(
    RequestContext<dynamic> req, ResponseContext<dynamic> res) async {
  var rawBody = <int>[];

  await for (var chunk in req.body) {
    rawBody.addAll(chunk);
  }

  if (!util.verifySlackRequest(
    req.headers.value("X-Slack-Request-Timestamp"),
    rawBody,
    req.headers.value("X-Slack-Signature"),
  )) {
    res.statusCode = 400;
    res.write("Slack request not verified");
    return;
  }

  var body = json.decode(utf8.decode(rawBody));

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
