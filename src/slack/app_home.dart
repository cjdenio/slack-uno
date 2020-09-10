import 'slack.dart';
import 'dart:io' show Platform;
import '../db/db.dart' as db;
import 'dart:convert';

updateAppHomeForAllInGame(String gameID) async {
  var players = await db.Game(gameID).getPlayers();
  await Future.forEach<db.Player>(players, (e) async {
    await updateAppHome(e.name);
  });
}

updateAppHome(String user) async {
  var client = SlackClient(Platform.environment["SLACK_TOKEN"]);

  final activeGame = await db.getActiveGame(user);

  var view = {
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
  };

  if (activeGame != null) {
    var game = db.Game(activeGame);

    final hand = await game.getPlayerHand(user);
    var url = Uri.https("slack-uno-renderer.vercel.app", "/api/image", {
      "hand": json.encode(hand),
      "table": json.encode(await game.getTopCard())
    });

    final players = await game.getPlayers();
    final player = await game.getActivePlayer();

    view = {
      "type": "home",
      "private_metadata": activeGame,
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text":
                "It's ${user == player.name ? '*your*' : '<@' + player.name + '>\'s'} turn"
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "End game",
            },
            "style": "danger",
            "action_id": "end",
            "confirm": {
              "title": {"type": "plain_text", "text": "End game?"},
              "text": {
                "type": "plain_text",
                "text":
                    "Are you sure you'd like to end this game for all players?"
              },
              "confirm": {"type": "plain_text", "text": "End"},
              "deny": {"type": "plain_text", "text": "Cancel"},
              "style": "danger"
            }
          }
        },
        {
          "type": "image",
          "image_url": url.toString(),
          "alt_text": "stuff",
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "mrkdwn",
              "text": "Players: " +
                  players
                      .map<String>((e) => "<@${e.name}>")
                      .toList()
                      .join(", "),
            }
          ]
        }
      ]
    };
  }

  client.publishView(user, view);
}
