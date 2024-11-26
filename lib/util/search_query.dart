import 'dart:convert';
import 'dart:developer';

import 'package:anarchist/types/anilist_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        context.go("/details/${entry.id}");
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
      id
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
        medium
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
    return DetailedMediaEntry.fromMap(parsed['data']['Media']);
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
        avatar {
          medium
        }
        bannerImage
        about
        mediaListOptions {
          scoreFormat
          rowOrder
          animeList {
            sectionOrder
          }
        }
        favourites {
           anime {
            nodes {
              id
            }
          }
        }
      }
    }
  ''';

  static const String _getUserIdentityQueryFromName = r'''
    query($username: String!){
      User(name: $username){
          id
          name
          avatar {
            medium
          }
          bannerImage
          about
          mediaListOptions{
            scoreFormat
            rowOrder
            animeList{
              sectionOrder
            }
          }
          favourites{
           anime{
            nodes {
              id
            }
          }
        }
      }
    }
  ''';

  static const String _getMediaFromId = r'''
    query($animeids: [Int]){
      Page{
        media(idMal_in:$animeids type: ANIME){
          id
          type
          genres
          title{
            romaji
            english
            native
            userPreferred
          }
          coverImage {
            medium
            extraLarge
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

  static const String _mutateUserSettings = r'''
    mutation ($id: Int!, $aboutstring: String!, $adultbool: bool!, $timezoneval: String!){
      UpdateUser(about: $aboutstring, displayAdultContent: $adultbool, timezone: $timezoneval){
        id
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

  Future<UserIdentity?> updateUserpreference(String? token, int id, String about, bool adultcont, String timezone) async{
    http.Response res = await http.post(_baseAPIURL, body: jsonEncode({
      'query': _mutateUserSettings,
      'variables': {'id': id, 'aboutstring': about, 'adultbool': adultcont, 'timezoneval': timezone}
    }),
      headers: {
        'Authorization': 'Bearer $token',
      }
    );

    if (res.statusCode != 200) {
      log(res.body);
      return null;
    }

    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      log('Received data was not JSON encoded');
      return null;
    }

    dynamic rawData = decoded['data']['User'];
    return UserIdentity.fromMap(rawData);
  }

  Future<List<MediaEntry>?> getmediafromID(List<int> id) async {
    http.Response res = await http.post(_baseAPIURL, body: jsonEncode({
      'query': _getMediaFromId,
      'variables': {'animeids':id}
    }),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    if (res.statusCode != 200){
      log("Received error ${res.statusCode}:\n${res.body}");
      return null;
    }


    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      return null;
    }
    dynamic rawData = decoded['data']['Page']['media'];

    List<MediaEntry>? listofmediaentries= [];
    for (var item in rawData){
      listofmediaentries.add(MediaEntry.fromMap(item));
    }

    for (var item in listofmediaentries){
      print(item.preferredName);
    }
    return listofmediaentries;
  }

  Future<UserIdentity?> getUserIdentityfromName(String searchname) async{
    http.Response res = await http.post(_baseAPIURL, body: jsonEncode({
      'query': _getUserIdentityQueryFromName,
      'variables': {'username':searchname}
    }),
      headers: {
        'Content-Type': 'application/json'
      }
    );
    if (res.statusCode != 200){
      log("Received error ${res.statusCode}:\n${res.body}");
      return null;
    }

    dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      return null;
    }

    dynamic rawData = decoded['data']['User'];
    return UserIdentity.fromMap(rawData);
  }

  Future<UserIdentity?> getUserIdentity(String token) async {
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
