import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:queue_quandry/styles.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../main.dart';
import '../credentials.dart';
import 'lobby.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';

const scope = 'user-read-private user-read-email';

String? myToken;
String? myRefreshToken;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  String loginMessage = 'Login Using Spotify';
  String debugMessage = 'DEBUG';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: spotifyBlack,
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    height: 50,
                    child: Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          _login().then((value) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LobbyPage(),
                                ),
                              )); // Handle Spotify login action
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
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Container(
                  //   height: 50,
                  //   child: Expanded(
                  //     child: ElevatedButton(
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => LobbyPage(),
                  //           ),
                  //         );
                  //       },
                  //       style: ButtonStyle(
                  //         backgroundColor: MaterialStateProperty.all<Color>(
                  //             Color.fromARGB(
                  //                 255, 255, 136, 0)), // Spotify green color
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Text(debugMessage,
                  //               style: TextStyle(
                  //                   color: Colors.white,
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 18)),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.18,
                  // )
                ]))));
  }

  Future<void> _login() async {
    AccessTokenResponse accessToken;
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: 'queuequandary',
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

    print("Spotify Token: " + myToken.toString());
  }
}
