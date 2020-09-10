import 'package:angel_framework/angel_framework.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import '../slack/slack.dart';

handleInteractivity(
    RequestContext<dynamic> req, ResponseContext<dynamic> res) async {
  var client = SlackClient(Platform.environment["SLACK_TOKEN"]);

  await req.parseBody();
  var body = json.decode(req.bodyAsMap["payload"]);

  switch (body["type"]) {
    case "block_actions":
      client.openView(body["trigger_id"], {
        "type": "modal",
        "callback_id": "start",
        "title": {
          "type": "plain_text",
          "text": "Start Uno Game",
        },
        "blocks": [
          {
            "type": "input",
            "block_id": "players",
            "label": {
              "type": "plain_text",
              "text": "Players",
            },
            "element": {
              "type": "multi_users_select",
              "action_id": "players",
              "placeholder": {
                "type": "plain_text",
                "text": "Select some...",
              },
              "max_selected_items": 10,
            }
          }
        ],
        "submit": {
          "type": "plain_text",
          "text": "Start",
        },
        "close": {
          "type": "plain_text",
          "text": "Cancel",
        }
      });
      break;
    case "view_submission":
      var values = body["view"]["state"]["values"];

      switch (body["view"]["callback_id"]) {
        case "start":
          print(
              "Starting game with ${values['players']['players']['selected_users'].length} players");
          break;
        default:
          print(body["callback_id"]);
      }
      break;
  }
}
