
import 'package:anarchist/util/search_query.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//ToDo: Actually use this
class MediaEntry {
  late int id;

  MediaEntry(this.id);

  //Optional Data
  String? englishName;
  String? nativeName;
  String? romajiName;
  String? coverImageURL;


  MediaEntry.fromMap(Map<String, dynamic> media){

    id = media["id"];

    if(media.containsKey("title")){
      englishName = media["title"]["english"] ?? "";
      nativeName = media["title"]["native"] ?? "";
      romajiName = media["title"]["romaji"] ?? "";
    }

    if(media.containsKey("coverImage")) {
      coverImageURL = media["coverImage"]["medium"] ?? "";
    }

  }


}