import 'dart:io' show Platform;

import '../db/db.dart' as db;
import '../slack/slack.dart';

sendDmToAllInGame(String gameID, List<Map<String, dynamic>> blocks,
    {String except, String text}) async {
  var client = SlackClient(Platform.environment["SLACK_TOKEN"]);

  var players = await db.Game(gameID).getPlayers();

  if (except != null) {
    players = players.where((e) => e.name != except).toList();
  }

  Future.forEach(players, (player) async {
    client.postMessage(channel: player.name, blocks: blocks, text: text);
  });
}
