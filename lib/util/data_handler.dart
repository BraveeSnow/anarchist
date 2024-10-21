import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DataSchema {
  String? accessToken;
  String? refreshToken;

  DataSchema({this.accessToken, this.refreshToken});

  DataSchema.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        refreshToken = json['refreshToken'];

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class DataHandler {
  static const String dataFilename = 'data.json';

  DataSchema currentData = DataSchema();

  Future<DataSchema> readData() async {
    File f = File('${await getApplicationDocumentsDirectory()}/$dataFilename');
    DataSchema schema = DataSchema();
    Map<String, dynamic> json;

    if (!await f.exists()) {
      return DataSchema();
    }

    json = jsonDecode(await f.readAsString());
    schema = json['accessToken'];

    return schema;
  }

  void writeData(DataSchema data) async {
    File f = File('${await getApplicationDocumentsDirectory()}/$dataFilename');
    if (!await f.exists()) {
      f = await f.create(recursive: true);
    }
    await f.writeAsString(jsonEncode(data));
  }
}
