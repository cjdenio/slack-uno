import 'dart:convert';

import 'package:http/http.dart' as http;

class SlackClient {
  final String token;
  SlackClient(this.token);

  Future<Map<String, dynamic>> publishView(
    String user,
    Map<String, dynamic> view,
  ) async {
    return await _doRequestJson(
      "https://slack.com/api/views.publish",
      {"user_id": user, "view": view},
    );
  }

  Future<Map<String, dynamic>> openView(
    String triggerID,
    Map<String, dynamic> view,
  ) async {
    return await _doRequestJson(
      "https://slack.com/api/views.open",
      {"trigger_id": triggerID, "view": view},
    );
  }

  Future<Map<String, dynamic>> postMessage({
    String channel,
    String text,
    List<Map<String, dynamic>> blocks,
    String threadTS,
  }) async {
    assert(channel != null, "Please provide a channel.");
    assert(text != null || blocks != null,
        "Please provide either text or blocks.");

    return await _doRequestJson("https://slack.com/api/chat.postMessage", {
      "channel": channel,
      if (text != null) "text": text,
      if (blocks != null) "blocks": blocks,
      if (threadTS != null) "thread_ts": threadTS
    });
  }

  Future<Map<String, dynamic>> _doRequestJson(
      String url, Map<String, dynamic> data) async {
    var client = http.Client();
    var req = http.Request("POST", Uri.parse(url));

    req.headers["Authorization"] = "Bearer $token";
    req.headers["Content-Type"] = "application/json";
    req.body = json.encode(data);

    var resp = await client.send(req);

    var respString = await resp.stream.bytesToString();

    return json.decode(respString);
  }
}
