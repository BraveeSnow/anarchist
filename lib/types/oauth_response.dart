import 'dart:core';

class OAuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime expiresIn;

  OAuthResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        refreshToken = json['refresh_token'],
        tokenType = json['token_type'],
        expiresIn = DateTime.fromMillisecondsSinceEpoch(
            (DateTime.now().millisecondsSinceEpoch +
                (json['expires_in'] as int) * 1000));
}
