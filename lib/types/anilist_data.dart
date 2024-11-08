
import 'package:anarchist/util/search_query.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//ToDo: Actually use this
class MediaEntry {
  int id;

  MediaEntry(this.id);

  //Optional Data
  String? englishName;
  String? nativeName;
  String? romajiName;
  String? coverImageURL;
}