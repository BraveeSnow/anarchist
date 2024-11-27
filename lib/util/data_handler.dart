import 'dart:convert';
import 'dart:io';

import 'package:anarchist/types/anarchist_data.dart';
import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/search_query.dart';
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

class DataHandler with AuthorizedQueryHandler {
  static final DataHandler _instance = DataHandler._internal();
  static const String dataFilename = 'data.json';

  UserIdentity? identity;

  DataHandler._internal();

  factory DataHandler() {
    return _instance;
  }

  Future<AnarchistData> readData() async {
    File f = File(
        '${(await getApplicationDocumentsDirectory()).path}/$dataFilename');

    if (!await f.exists()) {
      return AnarchistData();
    }

    AnarchistData data = AnarchistData.fromJson(jsonDecode(await f.readAsString()));

    if (data.accessToken != null) {
      identity = await getUserIdentity(data.accessToken!);
    }

    return data;
  }

  void writeData(AnarchistData data) async {
    File f = File(
        '${(await getApplicationDocumentsDirectory()).path}/$dataFilename');

    if (!await f.exists()) {
      f = await f.create(recursive: true);
    }
    await f.writeAsString(jsonEncode(data));

    if (data.accessToken != null) {
      identity = await getUserIdentity(data.accessToken!);
    }
  }
}
