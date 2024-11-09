import 'dart:convert';
import 'dart:developer';

import 'package:anarchist/types/anilist_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data_handler.dart';

final Uri _baseAPIURL = Uri.parse("https://graphql.anilist.co");

class SearchCard extends StatelessWidget {
  late String nameNative;
  late String nameEnglish;
  late String nameRomaji;
  late String coverImageURL;

  final MediaEntry entry;

  SearchCard({super.key, required this.entry}) {
    nameNative = entry.nativeName!;
    nameEnglish = entry.englishName!;
    nameRomaji = entry.romajiName!;
    coverImageURL = entry.coverImageURL!;
  }

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return GestureDetector(
      onTap: () {
        //ToDo: Implement On Click Logic
        print("Clicked $nameEnglish}");
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.black12),
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
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left)),
                SizedBox(
                  width: cWidth,
                  child: Text(nameNative,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      textAlign: TextAlign.left),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum MediaType {
  anime,
  manga;

  String get graphQLString => switch (this) {
        MediaType.anime => "ANIME",
        MediaType.manga => "MANGA",
      };
}

mixin SearchQueryHandler {
  Future<List<MediaEntry>> fetchSearchCards(String search, String type,
      {int pageNumber = 1}) async {
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

    final jsonBody = jsonEncode({"query": searchQuery, "variables": variables})
        .replaceAll("\\n", "");

    final response = await http.post(_baseAPIURL,
        headers: {"Content-Type": "application/json"}, body: jsonBody);

    List<MediaEntry> searchResults = [];

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for (final element in media) {
        final entry = MediaEntry.fromMap(element);
        searchResults.add(entry);
      }
    }

    return searchResults;
  }

  Future<List<MediaEntry>> fetchTrending(String type,
      {int pageNumber = 1}) async {
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

    final response = await http.post(_baseAPIURL,
        headers: {"Content-Type": "application/json"}, body: jsonBody);

    List<MediaEntry> searchResults = [];

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for (final element in media) {
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

    final response = await http.post(_baseAPIURL,
        headers: {"Content-Type": "application/json"}, body: jsonBody);

    List<MediaEntry> searchResults = [];

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody is! Map) return [];

      final media = responseBody["data"]["Page"]["media"];

      for (final element in media) {
        final entry = MediaEntry.fromMap(element);
        searchResults.add(entry);
      }
    }

    return searchResults;
  }
}

mixin AuthorizedQueryHandler {
  static const String _getUserIdentityQuery = r'''
    query {
      Viewer {
        id
        name
        mediaListOptions {
          scoreFormat
          rowOrder
          animeList {
            sectionOrder
          }
        }
      }
    }
  ''';

  static const String _getUserListsQuery = r'''
    query ($userId: Int!, $type: MediaType!) {
      MediaListCollection(userId: $userId, type: $type) {
        lists {
          name
          entries {
            media {
              id
              title {
                english
                romaji
                native
              }
              coverImage {
                color
                medium
              }
            }
          }
        }
      }
    }
  ''';

  Future<UserIdentity?> getUserIdentity(String token) async {
    http.Response res = await http.post(
      _baseAPIURL,
      body: { 'query': _getUserIdentityQuery },
      headers: {
        'Authorization': 'Bearer $token',
      }
    );

    if (res.statusCode != 200) {
      return null;
    }

    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      return null;
    }

    dynamic rawData = decoded['data']['Viewer'];
    return UserIdentity.fromMap(rawData);
  }

  Future<List<UserWatchlist>?> fetchUserLists(MediaType type) async {
    int? userId = DataHandler().identity?.id;
    if (userId == null) {
      return null;
    }

    http.Response res = await http.post(
      _baseAPIURL,
      body: jsonEncode({
        'query': _getUserListsQuery,
        'variables': {'userId': userId, 'type': type.graphQLString},
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      log(res.body);
      return null;
    }

    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      return null;
    }

    dynamic rawData = decoded['data']['MediaListCollection']['lists'];
    List<UserWatchlist> watchlists = [];
    for (var map in rawData) {
      watchlists.add(UserWatchlist.fromMap(map));
    }

    return watchlists;
  }
}
