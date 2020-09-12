class Deck {
  List<Card> cards = [];

  final Map<int, Color> colors = {
    0: Color.red,
    1: Color.green,
    2: Color.blue,
    3: Color.yellow,
  };

  Deck() {
    // Loop over all four colors
    for (var i = 0; i < 4; i++) {
      for (var x = 0; x <= 9; x++) {
        cards.add(Card(color: colors[i], number: x.toString()));
        if (x != 0) {
          // Do it again
          cards.add(Card(color: colors[i], number: x.toString()));
        }
      }
    }

    cards.shuffle();
  }

  List<Card> dealOutCards(int number) {
    var hand = <Card>[];

    for (var i = 0; i < number; i++) {
      hand.add(cards.removeLast());
    }

    return hand;
  }
}

class Card {
  String number;
  Color color;
  Card({this.number, this.color});

  Card.fromJson(Map<String, dynamic> v) {
    number = v["number"];

    switch (v["color"]) {
      case "red":
        color = Color.red;
        break;
      case "green":
        color = Color.green;
        break;
      case "blue":
        color = Color.blue;
        break;
      case "yellow":
        color = Color.yellow;
        break;
    }
  }

  String toString() {
    return "${color.toString()} ${number.toString()}";
  }

  Map<String, String> toJson() {
    return {
      "color": colorToString(color),
      "number": number,
    };
  }

  bool canBePlayedOn(Card card) {
    return number == card.number || color == card.color;
  }

  static String colorToString(Color color) {
    switch (color) {
      case Color.red:
        return "red";
      case Color.green:
        return "green";
      case Color.blue:
        return "blue";
      case Color.yellow:
        return "yellow";
      default:
        return "";
    }
  }

  static String colorToEmoji(Color color) {
    switch (color) {
      case Color.red:
        return ":red_circle:";
      case Color.green:
        return ":green_heart:";
      case Color.blue:
        return ":large_blue_circle:";
      case Color.yellow:
        return ":yellow_heart:";
      default:
        return "";
    }
  }
}

enum Color { red, green, blue, yellow }
