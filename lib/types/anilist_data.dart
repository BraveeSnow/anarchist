//ToDo: Actually use this
import 'dart:ui';

import 'package:flutter/material.dart';

import '../util/search_query.dart';

enum MediaFormat {
  tv,
  tvShort,
  movie,
  special,
  ova,
  ona,
  music,
  manga,
  novel,
  oneShot;

  factory MediaFormat.from(String raw) => switch (raw) {
        'TV' => MediaFormat.tv,
        'TV_SHORT' => MediaFormat.tvShort,
        'MOVIE' => MediaFormat.movie,
        'SPECIAL' => MediaFormat.special,
        'OVA' => MediaFormat.ova,
        'ONA' => MediaFormat.ona,
        'MUSIC' => MediaFormat.music,
        'MANGA' => MediaFormat.manga,
        'NOVEL' => MediaFormat.novel,
        'ONE_SHOT' => MediaFormat.oneShot,
        String() => throw ArgumentError('invalid media format "$raw"'),
      };
}

enum MediaStatus {
  finished,
  releasing,
  notYetReleased,
  cancelled,
  hiatus;

  factory MediaStatus.from(String raw) => switch (raw) {
        'FINISHED' => MediaStatus.finished,
        'RELEASING' => MediaStatus.releasing,
        'NOT_YET_RELEASED' => MediaStatus.notYetReleased,
        'CANCELLED' => MediaStatus.cancelled,
        'HIATUS' => MediaStatus.hiatus,
        String() => throw ArgumentError('invalid media status "$raw"'),
      };
}

class MediaEntry {
  late int id;

  MediaEntry(this.id);

  //Optional Data
  late final String? preferredName;
  late final String? nativeName;
  late final Color coverImageColor;
  late final String? coverImageURL;
  late final String? coverImageURLHD;
  late final List<dynamic>? genre;

  late final int? episodes;

  MediaEntry.fromMap(Map<String, dynamic> media) {
    id = media["id"];

    if (media.containsKey("title")) {
      preferredName = media["title"]["userPreferred"];
      nativeName = media["title"]["native"] ?? "";
    }

    if (media.containsKey("genres")) {
      genre = media["genres"] ?? "NaN";
    }

    if (media.containsKey("coverImage")) {
      coverImageColor = media["coverImage"]["color"] != null
          ? Color(
              int.parse(media["coverImage"]["color"].substring(1), radix: 16))
          : Colors.white;
      coverImageURL = media["coverImage"]["medium"] ?? "";
      coverImageURLHD = media["coverImage"]["extraLarge"] ?? "";
    }

    episodes = media['episodes'];
  }
}

class DetailedMediaEntry extends MediaEntry {
  final MediaType? type;
  final MediaFormat? format;
  final MediaStatus? status;
  final String? description;
  late final DateTime? startDate;
  late final DateTime? endDate;
  final Duration averageDuration;
  final String? ytTrailerId;
  final String? bannerImage;
  final List<String> genres = [];
  final int? averageScore;
  final int? meanScore;
  final int? popularity;
  final List<ScoreDistribution> scoreDistribution = [];
  final List<StatusDistribution> statusDistribution = [];

  DetailedMediaEntry.fromMap(Map<String, dynamic> media)
      : type = MediaType.from(media['type']),
        format = MediaFormat.from(media['format']),
        status = MediaStatus.from(media['status']),
        description = media['description'],
        averageDuration = Duration(minutes: media['duration']),
        ytTrailerId = media['trailer']['site'] == 'youtube'
            ? media['trailer']['id']
            : null,
        bannerImage = media['bannerImage'],
        averageScore = media['averageScore'],
        meanScore = media['meanScore'],
        popularity = media['popularity'],
        super.fromMap(media) {
    // initialize list values
    if (media['genres'] is List<String>) {
      for (String genre in media['genres']) {
        genres.add(genre);
      }
    }

    if (media['startDate']['year'] != null &&
        media['startDate']['month'] != null &&
        media['startDate']['day'] != null) {
      startDate = DateTime(media['startDate']['year'],
          media['startDate']['month'], media['startDate']['day']);
    } else {
      startDate = null;
    }

    if (media['endDate']['year'] != null &&
        media['endDate']['month'] != null &&
        media['endDate']['day'] != null) {
      endDate = DateTime(media['endDate']['year'], media['endDate']['month'],
          media['endDate']['day']);
    } else {
      endDate = null;
    }

    if (media['stats']['scoreDistribution'] is List) {
      for (var score in media['stats']['scoreDistribution']) {
        scoreDistribution.add(ScoreDistribution.fromMap(score));
      }
    }

    if (media['stats']['statusDistribution'] is List) {
      for (var status in media['stats']['statusDistribution']) {
        statusDistribution.add(StatusDistribution.fromMap(status));
      }
    }
  }
}

class ScoreDistribution {
  final int score;
  final int amount;

  ScoreDistribution({
    required this.score,
    required this.amount,
  });

  factory ScoreDistribution.fromMap(Map<String, dynamic> map) {
    return ScoreDistribution(
      score: map['score'] as int,
      amount: map['amount'] as int,
    );
  }
}

class StatusDistribution {
  final String status;
  final int amount;

  StatusDistribution({
    required this.status,
    required this.amount,
  });

  factory StatusDistribution.fromMap(Map<String, dynamic> map) {
    return StatusDistribution(
      status: map['status'] as String,
      amount: map['amount'] as int,
    );
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
      (e1.mediaEntry.preferredName?.toLowerCase() ?? '')
          .compareTo(e2.mediaEntry.preferredName?.toLowerCase() ?? '');
}

class UserIdentity {
  final int id;
  final String name;
  final UserRatingScheme ratingScheme;
  final UserRowOrder rowOrder;
  final List<String> animeSectionOrder = [];
  final String userimg;
  final String bannerimg;
  final String aboutme;
  final List<dynamic> favoriteanimesid;

  UserIdentity.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        userimg = data['avatar']['medium'] ?? "DEFAULT IMG",
        bannerimg = data['bannerImage'] ?? "DEFAULT BANNER",
        aboutme = data['about'] ?? "",
        favoriteanimesid = data['favourites']['anime']['nodes'] ?? [],
        ratingScheme =
            UserRatingScheme.from(data['mediaListOptions']['scoreFormat']),
        rowOrder = UserRowOrder.from(data['mediaListOptions']['rowOrder']) {
    for (String section in data['mediaListOptions']['animeList']
        ['sectionOrder']) {
      animeSectionOrder.add(section);
    }
  }
}
