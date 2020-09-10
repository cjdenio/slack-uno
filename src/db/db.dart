import 'package:dartis/dartis.dart';
import 'dart:io' show Platform;

Client client;

initDatabase() async {
  client = await Client.connect(Platform.environment["REDIS_URL"]);
}
