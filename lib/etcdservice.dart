import 'configdata.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<List<ConfigData>> fetchServerInfo(String prefix) async {
  var key = utf8.encode(prefix);
  var keyEnd = utf8.encode("${prefix}p");
  String _body =
      "{\"key\": \"${base64.encode(key)}\", \"range_end\":\"${base64.encode(keyEnd)}\"}";

  final response =
      await http.post("http://localhost:2379/v3/kv/range", body: _body);

  if (response.statusCode == 200) {
    var responseJson = json.decode(response.body);
    if (responseJson["count"] != null) {
      return (responseJson["kvs"] as List)
          .map((p) => ConfigData.fromJson(prefix, p))
          .toList();
    } else {
      return new Future.value(List<ConfigData>());
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load server data');
  }
}

setEtcdValue(ConfigData data) {
  var key = utf8.encode(data.name);
  var value = utf8.encode(data.value);
  String _body =
      "{\"key\": \"${base64.encode(key)}\", \"value\":\"${base64.encode(value)}\"}";
  print(_body);
  http.post("http://localhost:2379/v3/kv/put", body: _body);
}
