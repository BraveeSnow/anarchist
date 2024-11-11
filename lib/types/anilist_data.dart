//ToDo: Actually use this
class MediaEntry {
  late int id;

  MediaEntry(this.id);

  //Optional Data
  late final String? englishName;
  late final String? nativeName;
  late final String? romajiName;
  late final String? coverImageURL;
  late final String? coverImageURLHD;

  late final int? episodes;

  MediaEntry.fromMap(Map<String, dynamic> media) {
    id = media["id"];

    if (media.containsKey("title")) {
      englishName = media["title"]["english"] ?? "";
      nativeName = media["title"]["native"] ?? "";
      romajiName = media["title"]["romaji"] ?? "";
    }

    if (media.containsKey("coverImage")) {
      coverImageURL = media["coverImage"]["medium"] ?? "";
      coverImageURLHD = media["coverImage"]["extraLarge"] ?? "";
    }

    episodes = media['episodes'];
  }
}

/// The status of a media entry as according to the user.
enum MediaListStatus {
  current,
  planning,
  completed,
  dropped,
  paused,
  repeating;

  factory MediaListStatus.from(String raw) => switch (raw) {
        "CURRENT" => MediaListStatus.current,
        "PLANNING" => MediaListStatus.planning,
        "COMPLETED" => MediaListStatus.completed,
        "DROPPED" => MediaListStatus.dropped,
        "PAUSED" => MediaListStatus.paused,
        "REPEATING" => MediaListStatus.repeating,
        String() => throw Exception("invalid media list status"),
      };

  @override
  String toString() => name.toUpperCase();

  String toJson() {
    return toString();
  }
}

/// The entry containing all of the relevant information related to the user
/// and a [MediaEntry].
class UserMediaEntry {
  final int id;
  final int score; // do not display ratings of 0
  final MediaListStatus status;
  final int progress;
  final MediaEntry mediaEntry;

  UserMediaEntry.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        score = data['score'],
        status = MediaListStatus.from(data['status']),
        progress = data['progress'],
        mediaEntry = MediaEntry.fromMap(data['media']);
}

class UserWatchlist {
  final String name;
  final List<UserMediaEntry> entries = [];

  UserWatchlist.fromMap(Map<String, dynamic> data) : name = data['name'] {
    if (data['entries'] is! List) {
      return;
    }

    for (var map in data['entries']) {
      entries.add(UserMediaEntry.fromMap(map));
    }
  }
}

/// The rating scheme that the user prefers.
///
/// This should be used to determine how the user's ratings should be
/// displayed in their lists, as well as how they rate something.
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
