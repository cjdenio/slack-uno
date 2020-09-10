import 'package:http/http.dart' as http;
import 'dart:convert';

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
    String trigger_id,
    Map<String, dynamic> view,
  ) async {
    return await _doRequestJson(
      "https://slack.com/api/views.open",
      {"trigger_id": trigger_id, "view": view},
    );
  }

  Future<Map<String, dynamic>> _doRequestJson(
      String url, Map<String, dynamic> data) async {
    var client = http.Client();
    var req = http.Request("POST", Uri.parse(url));

    req.headers["Authorization"] = "Bearer ${this.token}";
    req.headers["Content-Type"] = "application/json";
    req.body = json.encode(data);

    var resp = await client.send(req);

    var respString = await resp.stream.bytesToString();

    return json.decode(respString);
  }
}
