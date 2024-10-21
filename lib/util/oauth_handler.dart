import 'dart:convert';

import 'package:anarchist/types/oauth_response.dart';
import 'package:anarchist/util/environment.dart';
import 'package:http/http.dart';

class OAuthHandler {
  static const String clientId = '21868';
  static const String redirectUri = 'world.snows.anarchist:///redirect';

  // first oauth endpoint - retrieve authorization code
  static final Uri anilistAuthCodeEndpoint = Uri(
    scheme: 'https',
    host: 'anilist.co',
    path: '/api/v2/oauth/authorize',
    queryParameters: {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
    },
  );

  // second oauth endpoint - exchange auth code for token
  static final Uri anilistTokenEndpoint = Uri(
    scheme: 'https',
    host: 'anilist.co',
    path: '/api/v2/oauth/token',
  );

  static Future<OAuthResponse?> retrieveToken(String authCode) async {
    Map<String, dynamic> resBody;
    Response res = await post(
      anilistTokenEndpoint,
      body: jsonEncode({
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': Environment.oauthSecret,
        'redirect_uri': redirectUri,
        'code': authCode,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      return null;
    }

    resBody = jsonDecode(res.body);
    // sanity check for server side
    // response must contain these keys
    if (!resBody.containsKey('access_token') ||
        !resBody.containsKey('refresh_token') ||
        !resBody.containsKey('token_type') ||
        !resBody.containsKey('expires_in')) {
      return null;
    }

    return OAuthResponse.fromJson(resBody);
  }
}
