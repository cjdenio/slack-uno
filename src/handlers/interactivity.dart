import 'package:angel_framework/angel_framework.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import '../slack/app_home.dart';
import '../slack/slack.dart';
import '../db/db.dart' as db;
import '../util/util.dart' as util;

handleInteractivity(
  RequestContext<dynamic> req,
  ResponseContext<dynamic> res,
) async {
  List<int> rawBody = [];

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

  var body = json.decode(Uri.splitQueryString(utf8.decode(rawBody))["payload"]);

  var client = SlackClient(Platform.environment["SLACK_TOKEN"]);

  switch (body["type"]) {
    case "block_actions":
      final action_id = body["actions"][0]["action_id"];

      if (action_id == "start") {
        client.openView(body["trigger_id"], startGameModal(null));
      } else if (action_id == "end") {
        await db.Game(body["view"]["private_metadata"]).end();
        await updateAppHomeForAllInGame(body["view"]["private_metadata"]);
      } else if (RegExp(r"play:(.+)").hasMatch(action_id)) {
        var game = db.Game(body["view"]["private_metadata"]);

        await game.playCard(
            body["user"]["id"], int.parse(body["actions"][0]["value"]));
        await game.nextPlayer();
        await updateAppHomeForAllInGame(body["view"]["private_metadata"]);
      } else if (action_id == "draw") {
        var game = db.Game(body["view"]["private_metadata"]);
        await game.drawTopCard(body["user"]["id"]);
        await updateAppHomeForAllInGame(body["view"]["private_metadata"]);
      }
      break;
    case "view_submission":
      var values = body["view"]["state"]["values"];

      switch (body["view"]["callback_id"]) {
        case "start":
          var alreadyPlaying = await db.getUsersAlreadyInGame(
              values['players']['players']['selected_users'].cast<String>());

          if (alreadyPlaying.length > 0) {
            res.json({
              "response_action": "update",
              "view": startGameModal(
                  "The following people are currently playing Uno, and thus can't be added to a game: " +
                      alreadyPlaying.map((e) => "<@$e>").join(", ")),
            });
          } else if (values['players']['players']['selected_users']
              .contains(body["user"]["id"])) {
            res.json({
              "response_action": "update",
              "view": startGameModal(
                  "No need to select yourself; you'll automatically be added in."),
            });
          } else {
            print(
                "Starting game with ${values['players']['players']['selected_users'].length} players");
            var gameID = await db.startGame(
              body["user"]["id"],
              values['players']['players']['selected_users'].cast<String>(),
            );
            await updateAppHomeForAllInGame(gameID);
            await util.sendDmToAllInGame(
                gameID,
                [
                  {
                    "type": "section",
                    "text": {
                      "type": "mrkdwn",
                      "text":
                          "<@${body['user']['id']}> has invited you to play Uno with these people: " +
                              values['players']['players']['selected_users']
                                  .map((e) => "<@$e>")
                                  .join(", ") +
                              "\nClick that button to join the game!"
                    }
                  },
                  {
                    "type": "actions",
                    "elements": [
                      {
                        "type": "button",
                        "action_id": "join",
                        "text": {"type": "plain_text", "text": "Join Game"},
                        "style": "primary",
                        "url": Uri(
                            scheme: "slack",
                            host: "app",
                            queryParameters: {
                              "tab": "home",
                              "id": body["api_app_id"],
                              "team": body["team"]["id"]
                            }).toString()
                      }
                    ]
                  }
                ],
                except: body["user"]["id"],
                text: "You've been invited to an Uno game!");
          }

          break;
      }
      break;
  }
}

Map<String, dynamic> startGameModal(String error) {
  return {
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
          "max_selected_items": 9,
        }
      },
      if (error != null)
        {
          "type": "context",
          "elements": [
            {
              "type": "mrkdwn",
              "text": ":rotating_light: *" + error + "* :rotating_light:",
            }
          ]
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
  };
}
