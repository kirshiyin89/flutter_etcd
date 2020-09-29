import 'dart:convert';

class ConfigData {
  ConfigData({this.prefix, this.name, this.value});

  String prefix;
  String name;
  String value;

  factory ConfigData.fromJson(
    String _prefix,
    Map<String, dynamic> json,
  ) {
    var key = utf8.decode(base64.decode(json['key']));

    return ConfigData(
        name: key,
        value: utf8.decode(base64.decode(json['value'])),
        prefix: _prefix);
  }
}
