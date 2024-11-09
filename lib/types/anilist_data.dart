//ToDo: Actually use this
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

class UserIdentity {
  final int id;

  UserIdentity.fromMap(Map<String, dynamic> data) : id = data['id'];
}
