import 'dart:io' show Platform;

import '../db/db.dart' as db;
import '../slack/slack.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

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

verifySlackRequest(String timestamp, List<int> body, String signature) {
  var hmac = new Hmac(
      sha256, utf8.encode(Platform.environment["SLACK_SIGNING_SECRET"]));
  var digest =
      hmac.convert(utf8.encode("v0:${timestamp}:${utf8.decode(body)}"));

  return "v0=" + digest.toString() == signature;
}
