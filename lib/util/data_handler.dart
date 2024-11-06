import 'dart:convert';
import 'dart:io';

import 'package:anarchist/types/anarchist_data.dart';
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

  AnarchistData currentData = AnarchistData();

  Future<AnarchistData> readData() async {
    File f = File(
        '${(await getApplicationDocumentsDirectory()).path}/$dataFilename');

    if (!await f.exists()) {
      return AnarchistData();
    }

    return AnarchistData.fromJson(jsonDecode(await f.readAsString()));
  }

  void writeData(AnarchistData data) async {
    File f = File(
        '${(await getApplicationDocumentsDirectory()).path}/$dataFilename');

    if (!await f.exists()) {
      f = await f.create(recursive: true);
    }
    await f.writeAsString(jsonEncode(data));
  }
}
