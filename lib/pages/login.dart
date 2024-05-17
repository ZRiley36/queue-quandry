import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:queue_quandry/styles.dart';
import 'dart:async';
import '../credentials.dart';
import 'lobby.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const scope = 'user-read-private user-read-email';

String? myToken;
String? myRefreshToken;

Future<void> loadToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myToken = prefs.getString('accessToken');
  myRefreshToken = prefs.getString('refreshToken');

  if (myToken != null) {
    print("Loaded Spotify Token ✅ -> " + myToken.toString());
  } else {
    print("No token found, user needs to log in.");
    // Optionally, you can call _login() here if you want to prompt the user to log in
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
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
                          _login().then(
                              (value) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LobbyPage(),
                                    ),
                                  ), onError: (error) {
                            print(
                                "Serious login failure. Aborting [ERROR: ${error.toString()}]");
                          }); // Handle Spotify login action
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.green), // Spotify green color
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

  Future<void> _login() async {
    await loadToken();

    if (myToken != null && myToken != '') return;

    AccessTokenResponse? accessToken;
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: 'playlistpursuit',
      //Must correspond to the AndroidManifest's "android:scheme" attribute
      redirectUri:
          spotifyRedirectUri, //Can be any URI, but the scheme part must correspond to the customeUriScheme
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

    // Save tokens to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', myToken ?? '');
    await prefs.setString('refreshToken', myRefreshToken ?? '');

    print("Acquired Spotify Token ✅ -> " + myToken.toString());
  }
}
