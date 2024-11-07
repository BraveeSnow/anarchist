import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchCard extends StatelessWidget {
  final String nameNative;
  final String nameEnglish;
  final String coverImageURL;

  const SearchCard(
      {super.key,
        required this.nameNative,
        required this.nameEnglish,
        required this.coverImageURL});

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
                        nameEnglish,
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

  Future<List<SearchCard>> fetchSearchCards(String search, String type) async {
    final searchQuery = """query (\$search: String!) {
  Page {
    media(search: \$search, type: ${type.toUpperCase()}) {
      id
      title {
        english
        native
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

    List<SearchCard> searchResults = [];

    if(response.statusCode == 200){

      final responseBody = jsonDecode(response.body);
      if(responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for(final element in media){

        dynamic english = element["title"]["english"];
        dynamic native = element["title"]["native"];
        dynamic image = element["coverImage"]["medium"];

        final card = SearchCard(
           nameEnglish: english ?? "",
           nameNative: native ?? "",
           coverImageURL: image ?? "",
        );

        searchResults.add(card);

      }

    }

    return searchResults;
  }
}
