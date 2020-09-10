import 'package:angel_framework/angel_framework.dart';
import 'dart:io' show Platform;
import '../slack/slack.dart';

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
      await client.publishView(body["event"]["user"], {
        "type": "home",
        "blocks": [
          {
            "type": "actions",
            "elements": [
              {
                "type": "button",
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": ":rocket: Start an Uno game"
                },
                "action_id": "start",
              }
            ],
          },
        ],
      });
      break;
  }
}
