import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:queue_quandry/styles.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'dart:async';
import '../credentials.dart';
import 'lobby.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const scope = 'user-read-private user-read-email';

String? myToken;
String? myRefreshToken;
DateTime? tokenExpiration;

Future<void> ensureTokenIsValid() async {
  if (myToken == null ||
      tokenExpiration == null ||
      DateTime.now().isAfter(tokenExpiration!)) {
    bool refreshed = await refreshAccessToken();
    if (!refreshed) {
      throw Exception("Unable to refresh token");
    }
  }
}

Future<bool> refreshAccessToken() async {
  if (myRefreshToken == null) {
    return false;
  }

  SpotifyOAuth2Client client = SpotifyOAuth2Client(
    customUriScheme: 'playlistpursuit',
    redirectUri: spotifyRedirectUri,
  );

  try {
    AccessTokenResponse accessToken = await client.refreshToken(
      myRefreshToken!,
      clientId: spotifyClientId,
      clientSecret: spotifyClientSecret,
    );

    // Update global variables with the new token details
    myToken = accessToken.accessToken;
    myRefreshToken = accessToken.refreshToken ??
        myRefreshToken; // Refresh token may not change
    tokenExpiration = accessToken.expirationDate;

    // Save new tokens to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', myToken!);
    await prefs.setString('refreshToken', myRefreshToken!);
    await prefs.setString('expirationDate', tokenExpiration!.toIso8601String());

    print("Token refreshed successfully ✅ -> " + myToken.toString());
    return true;
  } catch (error) {
    print("Failed to refresh token [ERROR: ${error.toString()}]");
    return false;
  }
}

Future<void> loadToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myToken = prefs.getString('accessToken');
  myRefreshToken = prefs.getString('refreshToken');
  String? expirationString = prefs.getString('expirationDate');

  if (expirationString != null) {
    tokenExpiration = DateTime.parse(expirationString);
  }

  if (myToken != null) {
    print("Loaded Spotify Token ✅ -> " + myToken.toString());
  } else {
    print("No token found, user needs to log in.");
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String loginMessage = 'Login';
  String debugMessage = 'DEBUG';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: spotifyBlack,
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // alternativeAuth();
                          authenticateUser().then(
                              (value) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LobbyPage(
                                        reset: true,
                                      ),
                                    ),
                                  ), onError: (error) {
                            print(
                                "Serious login failure. Aborting [ERROR: ${error.toString()}]");
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(loginMessage,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      )
                    ]))));
  }

  Future<void> alternativeAuth() async {
    await SpotifySdk.connectToSpotifyRemote(
        clientId: spotifyClientId, redirectUrl: spotifyRedirectUri);
  }

  Future<void> authenticateUser() async {
    await loadToken();

    // Check if token is not null and not expired
    if (myToken != null && tokenExpiration != null) {
      if (DateTime.now().isBefore(tokenExpiration!)) {
        print(
            "Token is valid and not expired. Proceeding without re-authentication.");
        return;
      } else {
        // Token is expired, attempt to refresh it
        bool refreshed = await refreshAccessToken();
        if (refreshed) {
          print(
              "Token successfully refreshed. Proceeding without re-authentication.");
          return;
        }
      }
    }

    // Proceed with re-authentication if no valid token or refresh failed
    AccessTokenResponse? accessToken;
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: 'playlistpursuit',
      redirectUri: spotifyRedirectUri,
    );

    var authResp = await client
        .requestAuthorization(clientId: spotifyClientId, customParams: {
      'show_dialog': 'true'
    }, scopes: [
      'user-read-private',
      'user-read-playback-state',
      'user-modify-playback-state',
      'user-read-currently-playing',
      'user-read-email'
    ]);
    var authCode = authResp.code;

    accessToken = await client.requestAccessToken(
        code: authCode.toString(),
        clientId: spotifyClientId,
        clientSecret: spotifyClientSecret);

    // Global variables
    myToken = accessToken.accessToken;
    myRefreshToken = accessToken.refreshToken;
    tokenExpiration = accessToken.expirationDate;

    // Save tokens to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', myToken!);
    await prefs.setString('refreshToken', myRefreshToken!);
    await prefs.setString('expirationDate', tokenExpiration!.toIso8601String());

    print("Acquired Spotify Token ✅ -> " + myToken.toString());
  }
}
