import 'package:dartis/dartis.dart';
import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';

import '../deck/deck.dart';

import 'dart:convert';

Client client;

initDatabase() async {
  try {
    client = await Client.connect(Platform.environment["REDIS_URL"]);

    var user = Uri.parse(Platform.environment["REDIS_URL"]).userInfo;
    if (user != "") {
      await client.asCommands<String, String>().auth(user.split(":")[1]);
    }
  } catch (e) {
    print(e);
  }
}

Future<String> startGame(String activePlayer, List<String> players) async {
  final gameID = Uuid().v4();
  var deck = Deck();

  var commands = client.asCommands<String, String>();

  players = [activePlayer, ...players];

  await Future.forEach(players, (p) async {
    // Set active game for all players
    await commands.set("users:${p}:activeGame", gameID);
    // Deal out cards to all players
    await commands.set("games:${gameID}:players:${p}:hand",
        json.encode(deck.dealOutCards(7).map((e) => e.toJson()).toList()));
  });

  await commands.set("games:${gameID}:players", json.encode(players));

  Card starterCard = deck.dealOutCards(1)[0];

  await commands.set("games:${gameID}:draw",
      json.encode(deck.cards.map((e) => e.toJson()).toList()));
  await commands.set(
      "games:${gameID}:discard", json.encode([starterCard.toJson()]));

  await commands.set("games:${gameID}:activePlayer", activePlayer);
  await commands.set(
      "games:${gameID}:activeColor", Card.ColorToString(starterCard.color));

  return gameID;
}

Future<String> getActiveGame(String user) async {
  return await client
      .asCommands<String, String>()
      .get("users:${user}:activeGame");
}

setActiveGame(String user, String gameID) async {
  await client
      .asCommands<String, String>()
      .set("users:${user}:activeGame", gameID);
}

removeActiveGame(String user) async {
  await client
      .asCommands<String, String>()
      .del(key: "users:${user}:activeGame");
}

class Game {
  final String game;
  Game(this.game);

  Future<List<Card>> getPlayerHand(String user) async {
    dynamic stuff = json.decode(await client
        .asCommands<String, String>()
        .get("games:${game}:players:${user}:hand"));
    stuff = stuff.map<Card>((v) => Card.fromJson(v)).toList();
    return stuff;
  }

  Future<Card> getTopCard() async {
    var discard =
        await client.asCommands<String, String>().get("games:${game}:discard");

    return Card.fromJson(json.decode(discard).last);
  }

  Future<List<Player>> getPlayers() async {
    var players = json
        .decode(await client
            .asCommands<String, String>()
            .get("games:${game}:players"))
        .cast<String>();

    List<Player> newList = [];

    await Future.forEach(players, (player) async {
      newList.add(Player(name: player, hand: await getPlayerHand(player)));
    });

    return newList;
  }

  Future<Player> getActivePlayer() async {
    var player = await client
        .asCommands<String, String>()
        .get("games:${game}:activePlayer");
    var hand = await getPlayerHand(player);

    return Player(name: player, hand: hand);
  }

  setActivePlayer(String player) async {
    await client
        .asCommands<String, String>()
        .set("games:${game}:activePlayer", player);
  }

  nextPlayer() async {
    var players = await getPlayers();
    var activePlayer = await getActivePlayer();

    if (activePlayer.name == players.last.name) {
      await setActivePlayer(players.first.name);
    } else {
      await setActivePlayer(
          players[players.indexWhere((e) => e.name == activePlayer.name) + 1]
              .name);
    }
  }

  end() async {
    var players = await getPlayers();
    Future.forEach<Player>(players, (e) async {
      await removeActiveGame(e.name);
    });
  }

  playCard(String user, int cardIndex) async {
    var hand = await getPlayerHand(user);
    dynamic discard = json.decode(
        await client.asCommands<String, String>().get("games:${game}:discard"));
    discard = discard.map((e) => Card.fromJson(e)).toList();

    var card = hand.removeAt(cardIndex);
    discard.add(card);

    await client
        .asCommands<String, String>()
        .set("games:${game}:discard", json.encode(discard));
    await client
        .asCommands<String, String>()
        .set("games:${game}:players:${user}:hand", json.encode(hand));
    await client
        .asCommands<String, String>()
        .set("games:${game}:activeColor", Card.ColorToString(card.color));

    if (hand.length == 0) {
      await setWinner(user);
    }
  }

  setWinner(String winner) async {
    await client
        .asCommands<String, String>()
        .set("games:${game}:winner", winner);
  }

  Future<String> getWinner() async {
    return await client
        .asCommands<String, String>()
        .get("games:${game}:winner");
  }

  Future<Card> drawTopCard(String user) async {
    var hand = await getPlayerHand(user);
    dynamic draw = json.decode(
        await client.asCommands<String, String>().get("games:${game}:draw"));
    draw = draw.map((e) => Card.fromJson(e)).toList();

    var drawn = draw.removeLast();
    hand.add(drawn);

    await client
        .asCommands<String, String>()
        .set("games:${game}:draw", json.encode(draw));
    await client
        .asCommands<String, String>()
        .set("games:${game}:players:${user}:hand", json.encode(hand));
  }
}

class Player {
  final String name;
  final List<Card> hand;

  Player({this.name, this.hand});

  String toString() => this.name;
}
