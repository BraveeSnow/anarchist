class AnarchistData {
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiry;

  AnarchistData({this.accessToken, this.refreshToken, this.tokenExpiry});

  AnarchistData.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        refreshToken = json['refreshToken'],
        tokenExpiry = DateTime.fromMillisecondsSinceEpoch(json['tokenExpiry']);

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiry': tokenExpiry!.millisecondsSinceEpoch,
    };
  }
}