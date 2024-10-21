class AnarchistData {
  String? accessToken;
  String? refreshToken;

  AnarchistData({this.accessToken, this.refreshToken});

  AnarchistData.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        refreshToken = json['refreshToken'];

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}