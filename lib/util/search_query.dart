import 'dart:convert';

import 'package:anarchist/types/anilist_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchCard extends StatelessWidget {
  late String nameNative;
  late String nameEnglish;
  late String nameRomaji;
  late String coverImageURL;

  final MediaEntry entry;

  SearchCard({super.key, required this.entry}){
    nameNative = entry.nativeName!;
    nameEnglish = entry.englishName!;
    nameRomaji = entry.romajiName!;
    coverImageURL = entry.coverImageURL!;
  }

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width*0.8;
    return GestureDetector(
      onTap: () {
        //ToDo: Implement On Click Logic
        print("Clicked $nameEnglish}");
      },
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.black12
        ),
        height: 110,
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 80,
              child: Image.network(coverImageURL),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: cWidth,
                    child: Text(
                        nameEnglish.isNotEmpty ? nameEnglish : nameRomaji,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left
                    )
                ),
                SizedBox(
                  width: cWidth,
                  child: Text(
                      nameNative,
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      textAlign: TextAlign.left
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}


mixin SearchQueryHandler {
  String _baseAPIURL = "https://graphql.anilist.co";

  Future<List<MediaEntry>> fetchSearchCards(String search, String type, {int pageNumber = 1}) async {
    final searchQuery = """
    query (\$search: String!) {
      Page {
        media(search: \$search, type: ${type.toUpperCase()}) {
          id
          title {
            english
            native
            romaji
          }
          coverImage {
            color
            medium
          }
        }
      }
    }
    """;

    final variables = """
    {
      "search": "$search"
    }
    """;

    final jsonBody = jsonEncode({
      "query": searchQuery,
      "variables": variables
    }).replaceAll("\\n", "");

    final response = await http.post(
        Uri.parse(_baseAPIURL),
        headers: {"Content-Type": "application/json"},
        body: jsonBody
    );

    List<MediaEntry> searchResults = [];

    if(response.statusCode == 200){

      final responseBody = jsonDecode(response.body);
      if(responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for(final element in media){
        final entry = MediaEntry.fromMap(element);
        searchResults.add(entry);
      }

    }

    return searchResults;
  }

  Future<List<MediaEntry>> fetchTrending(String type, {int pageNumber = 1}) async {
    final searchQuery = """
    query {
      Page {
        media(type: ${type.toUpperCase()}, sort: TRENDING_DESC) {
          id
          title {
            english
            native
            romaji
          }
          coverImage {
            color
            medium
          }
        }
      }
    }
    """;

    final jsonBody = jsonEncode({
      "query": searchQuery,
    }).replaceAll("\\n", "");

    final response = await http.post(
        Uri.parse(_baseAPIURL),
        headers: {"Content-Type": "application/json"},
        body: jsonBody
    );

    List<MediaEntry> searchResults = [];

    if(response.statusCode == 200){

      final responseBody = jsonDecode(response.body);
      if(responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for(final element in media){
        final entry = MediaEntry.fromMap(element);
        searchResults.add(entry);
      }

    }

    return searchResults;
  }

  Future<List<MediaEntry>> fetchTop(String type, {int pageNumber = 1}) async {
    final searchQuery = """
    query {
      Page {
        media(type: ${type.toUpperCase()}, sort: SCORE_DESC) {
          id
          title {
            english
            native
            romaji
          }
          coverImage {
            color
            medium
          }
        }
      }
    }
    """;

    final jsonBody = jsonEncode({
      "query": searchQuery,
    }).replaceAll("\\n", "");

    final response = await http.post(
        Uri.parse(_baseAPIURL),
        headers: {"Content-Type": "application/json"},
        body: jsonBody
    );

    List<MediaEntry> searchResults = [];

    if(response.statusCode == 200){

      final responseBody = jsonDecode(response.body);
      if(responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for(final element in media){
        final entry = MediaEntry.fromMap(element);
        searchResults.add(entry);
      }

    }

    return searchResults;
  }
}
