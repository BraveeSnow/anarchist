import 'dart:convert';

import 'package:anarchist/types/anilist_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data_handler.dart';

final Uri _baseAPIURL = Uri.parse("https://graphql.anilist.co");

class SearchCard extends StatelessWidget {
  late final String namePreferred;
  late final String nameNative;
  late final String coverImageURL;
  late final String coverImageURLHD;

  final MediaEntry entry;

  SearchCard({super.key, required this.entry}) {
    namePreferred = entry.preferredName!;
    nameNative = entry.nativeName!;
    coverImageURL = entry.coverImageURL!;
    coverImageURLHD = entry.coverImageURLHD!;
  }

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return GestureDetector(
      onTap: () {
        //ToDo: Implement On Click Logic
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
                        namePreferred,
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

  factory MediaType.from(String raw) => switch (raw) {
        "ANIME" => MediaType.anime,
        "MANGA" => MediaType.manga,
        String() => throw ArgumentError('invalid media type string "$raw"'),
      };

  String get graphQLString => switch (this) {
        MediaType.anime => "ANIME",
        MediaType.manga => "MANGA",
      };
}

mixin SearchQueryHandler {
  static const String _getMediaDetailsQuery = r'''
  query($id: Int!) {
    Media(id: $id) {
      title {
        userPreferred
        native
      }
      type
      format
      status
      description
      startDate {
        day
        month
        year
      }
      endDate {
        day
        month
        year
      }
      seasonYear
    seasonInt
      episodes
      duration
      chapters
      volumes
      trailer {
        id
        site
      }
      coverImage {
        extraLarge
      }
      bannerImage
      genres
      averageScore
      meanScore
      popularity
      favourites
      isFavourite
      stats {
        scoreDistribution {
          amount
          score
        }
        statusDistribution {
          amount
          status
        }
      }
    }
  }
  ''';

  Future<List<MediaEntry>> fetchSearchCards(String search, String type,
      {int pageNumber = 1}) async {
    final searchQuery = """
    query (\$search: String!) {
      Page {
        media(search: \$search, type: ${type.toUpperCase()}) {
          id
          title {
            userPreferred
            native
          }
          coverImage {
            color
            medium
            extraLarge
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

  Future<DetailedMediaEntry> fetchMediaDetails(int id) async {
    // this is optional; user does not need to be signed in for this to work
    String? token = (await DataHandler().readData()).accessToken;

    http.Response res = await http.post(
      _baseAPIURL,
      body: jsonEncode({
        'query': _getMediaDetailsQuery,
        'variables': {'id': id},
      }),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> parsed = _parseResponse(res);
    return DetailedMediaEntry.fromMap(parsed);
  }

  Future<List<MediaEntry>> fetchTrending(String type,
      {int pageNumber = 1}) async {
    final searchQuery = """
    query {
      Page {
        media(type: ${type.toUpperCase()}, sort: TRENDING_DESC) {
          id
          title {
            userPreferred
            native
          }
          coverImage {
            color
            medium
            extraLarge
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
            userPreferred
            native
          }
          coverImage {
            color
            medium
            extraLarge
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

  Map<String, dynamic> _parseResponse(http.Response res) {
    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw http.ClientException('Server response was malformed.');
    }

    if (res.statusCode != 200) {
      List<dynamic> errors = decoded['errors'];
      if (errors.isEmpty || errors[0] is! Map) {
        throw http.ClientException('Unknown');
      }
      throw http.ClientException(errors[0]['message']);
    }

    return decoded;
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
                id
                score
                status
                progress
                updatedAt
                media {
                  id
                  title {
                    userPreferred
                    native
                  }
                  coverImage {
                    color
                    medium
                  }
                  episodes
                }
              }
            }
          }
        }
  ''';

  static const String _mutateMediaEntry = r'''
    mutation ($id: Int!, $status: MediaListStatus) {
      SaveMediaListEntry(id: $id, status: $status) {
        id
        score
        status
        progress
        updatedAt
        media {
          id
          title {
            userPreferred
            native
          }
          coverImage {
            color
            medium
          }
          episodes
        }
      }
    }
  ''';

  Future<UserIdentity> getUserIdentity(String token) async {
    http.Response res = await http.post(_baseAPIURL, body: {
      'query': _getUserIdentityQuery
    }, headers: {
      'Authorization': 'Bearer $token',
    });

    Map<String, dynamic> parsed = _parseResponse(res);

    dynamic rawData = parsed['data']['Viewer'];
    return UserIdentity.fromMap(rawData);
  }

  Future<List<UserWatchlist>> fetchUserLists(MediaType type) async {
    int? userId = DataHandler().identity?.id;
    if (userId == null) {
      throw http.ClientException('Sign in to see this content.');
    }

    http.Response res = await http.post(
      _baseAPIURL,
      body: jsonEncode({
        'query': _getUserListsQuery,
        'variables': {'userId': userId, 'type': type.graphQLString},
      }),
      headers: {'Content-Type': 'application/json'},
    );

    Map<String, dynamic> parsed = _parseResponse(res);
    dynamic rawData = parsed['data']['MediaListCollection']['lists'];
    List<UserWatchlist> watchlists = [];
    for (var map in rawData) {
      watchlists.add(UserWatchlist.fromMap(map));
    }

    return watchlists;
  }

  /// Updates a [UserMediaEntry] through the GraphQL API.
  ///
  /// Returns: the newly updated entry details to replace the old entry.
  Future<UserMediaEntry> mutateUserMediaEntry(
      int mediaId, MediaListStatus status) async {
    String? token = await _getAccessToken();
    http.Response res = await http.post(
      _baseAPIURL,
      body: jsonEncode({
        'query': _mutateMediaEntry,
        'variables': {'id': mediaId, 'status': status}
      }),
      headers: {
        'authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    Map<String, dynamic> parsed = _parseResponse(res);
    return UserMediaEntry.fromMap(parsed['data']['SaveMediaListEntry']);
  }

  Future<String> _getAccessToken() async {
    String? token = (await DataHandler().readData()).accessToken;
    if (token == null) {
      throw Exception("no token exists");
    }
    return token;
  }

  Map<String, dynamic> _parseResponse(http.Response res) {
    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw http.ClientException('Server response was malformed.');
    }

    if (res.statusCode != 200) {
      List<dynamic> errors = decoded['errors'];
      if (errors.isEmpty || errors[0] is! Map) {
        throw http.ClientException('Unknown');
      }
      throw http.ClientException(errors[0]['message']);
    }

    return decoded;
  }
}
