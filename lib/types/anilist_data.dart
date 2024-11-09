//ToDo: Actually use this
import 'dart:developer';

class MediaEntry {
  late int id;

  MediaEntry(this.id);

  //Optional Data
  String? englishName;
  String? nativeName;
  String? romajiName;
  String? coverImageURL;

  MediaEntry.fromMap(Map<String, dynamic> media) {
    id = media["id"];

    if (media.containsKey("title")) {
      englishName = media["title"]["english"] ?? "";
      nativeName = media["title"]["native"] ?? "";
      romajiName = media["title"]["romaji"] ?? "";
    }

    if (media.containsKey("coverImage")) {
      coverImageURL = media["coverImage"]["medium"] ?? "";
    }
  }
}

class UserWatchlist {
  final String name;
  final List<MediaEntry> entries = [];

  UserWatchlist.fromMap(Map<String, dynamic> data) : name = data['name'] {
    if (data['entries'] is! List) {
      return;
    }

    for (var map in data['entries']) {
      entries.add(MediaEntry.fromMap(map['media']));
    }
  }
}

enum UserRatingScheme {
  point100, // out of 100
  point10Decimal, // out of 10, decimals included
  point10, // out of 10 but no decimals
  point5, // out of 5, represented in stars
  point3; // out of 3, represented with :), :|, :(

  factory UserRatingScheme.from(String raw) => switch (raw) {
        "POINT_100" => UserRatingScheme.point100,
        "POINT_10_DECIMAL" => UserRatingScheme.point10Decimal,
        "POINT_10" => UserRatingScheme.point10,
        "POINT_5" => UserRatingScheme.point5,
        "POINT_3" => UserRatingScheme.point3,
        String() => throw Exception("invalid point scheme"),
      };
}

class UserIdentity {
  final int id;
  final String name;
  final UserRatingScheme ratingScheme;
  final String rowOrder;
  final List<String> animeSectionOrder = [];

  UserIdentity.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        ratingScheme =
            UserRatingScheme.from(data['mediaListOptions']['scoreFormat']),
        rowOrder = data['mediaListOptions']['rowOrder'] {
    for (String section in data['mediaListOptions']['animeList']
        ['sectionOrder']) {
      animeSectionOrder.add(section);
    }
  }
}
