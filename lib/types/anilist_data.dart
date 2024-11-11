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
  final int lastUpdated;
  final MediaEntry mediaEntry;

  UserMediaEntry.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        score = data['score'],
        status = MediaListStatus.from(data['status']),
        progress = data['progress'],
        lastUpdated = data['updatedAt'],
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

enum UserRowOrder {
  score,
  title,
  lastUpdated,
  lastAdded; // sorted using user entry id

  factory UserRowOrder.from(String raw) => switch (raw) {
        'score' => UserRowOrder.score,
        'title' => UserRowOrder.title,
        'updatedAt' => UserRowOrder.lastUpdated,
        'id' => UserRowOrder.lastAdded,
        String() => throw ArgumentError('Invalid row order string "$raw"'),
      };

  int Function(UserMediaEntry, UserMediaEntry) getSortFunction() =>
      switch (this) {
        // not fully perfect with symbols, as seen with entries like FSN UBW
        // and FSN Heaven's Feel
        UserRowOrder.title => (e1, e2) => _titleSort(e1, e2),
        UserRowOrder.score => (e1, e2) {
            if (e1.score == e2.score) {
              return _titleSort(e1, e2);
            }
            // replicate behavior on platform: highest rated first
            return e2.score.compareTo(e1.score);
          },
        UserRowOrder.lastUpdated => (e1, e2) =>
            e2.lastUpdated.compareTo(e1.lastUpdated),
        UserRowOrder.lastAdded => (e1, e2) => e2.id.compareTo(e1.id),
      };

  int _titleSort(UserMediaEntry e1, UserMediaEntry e2) =>
      (e1.mediaEntry.englishName?.toLowerCase() ?? '')
          .compareTo(e2.mediaEntry.englishName?.toLowerCase() ?? '');
}

class UserIdentity {
  final int id;
  final String name;
  final UserRatingScheme ratingScheme;
  final UserRowOrder rowOrder;
  final List<String> animeSectionOrder = [];

  UserIdentity.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        ratingScheme =
            UserRatingScheme.from(data['mediaListOptions']['scoreFormat']),
        rowOrder = UserRowOrder.from(data['mediaListOptions']['rowOrder']) {
    for (String section in data['mediaListOptions']['animeList']
        ['sectionOrder']) {
      animeSectionOrder.add(section);
    }
  }
}
