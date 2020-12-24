import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;

Future<void> giveHn(String botUserId, String user, int amount) async {
  var client = http.Client();
  var request = http.Request("POST", Uri.parse("https://hn.rishi.cx"));

  request.headers["secret"] = Platform.environment["HN_TOKEN"];
  print(Platform.environment["HN_TOKEN"]);

  request.headers["Content-Type"] = "application/json";

  request.body = json.encode({
    "query": """
      mutation(\$botUserId: String!, \$user: String!, \$amount: Float!) {
        send(data: {from: \$botUserId, to: \$user, balance: \$amount}) {
          id
        } 
      } 
    """,
    "variables": {"botUserId": botUserId, "user": user, "amount": amount}
  });

  var res = await client.send(request);
  var resString = await res.stream.bytesToString();

  print(resString);
}
