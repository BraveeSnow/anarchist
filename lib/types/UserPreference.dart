class UserPreference {
  final int userId;
  final String aboutMe;
  final bool adultContent;
  final String timezone;

  UserPreference({
    required this.userId,
    required this.aboutMe,
    required this.adultContent,
    required this.timezone,
  });

  factory UserPreference.fromFirestore(Map<String, dynamic> data) {
    return UserPreference(
      userId: data['userId'] as int,
      aboutMe: data['aboutMe'] as String,
      adultContent: data['adultContent'] as bool,
      timezone: data['timezone'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'aboutMe': aboutMe,
      'adultContent': adultContent,
      'timezone': timezone,
    };
  }
}
