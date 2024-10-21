import 'dart:convert';
import 'dart:io';

import 'package:anarchist/types/anarchist_data.dart';
import 'package:path_provider/path_provider.dart';

class DataHandler {
  static const String dataFilename = 'data.json';

  AnarchistData currentData = AnarchistData();

  Future<AnarchistData> readData() async {
    File f = File('${await getApplicationDocumentsDirectory()}/$dataFilename');
    AnarchistData schema = AnarchistData();
    Map<String, dynamic> json;

    if (!await f.exists()) {
      return AnarchistData();
    }

    json = jsonDecode(await f.readAsString());
    schema = json['accessToken'];

    return schema;
  }

  void writeData(AnarchistData data) async {
    File f = File('${await getApplicationDocumentsDirectory()}/$dataFilename');
    if (!await f.exists()) {
      f = await f.create(recursive: true);
    }
    await f.writeAsString(jsonEncode(data));
  }
}
