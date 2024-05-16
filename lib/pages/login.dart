import 'package:flutter/material.dart';
import 'package:queue_quandry/styles.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../credentials.dart';
import 'lobby.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

const scope = 'user-read-private user-read-email';

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
                        onPressed: () {
                          _login(); // Handle Spotify login action
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 50,
                    child: Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LobbyPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(
                                  255, 255, 136, 0)), // Spotify green color
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(debugMessage,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
                  )
                ]))));
  }

  void _login() async {
    Uri authUrl = Uri(
        scheme: 'https',
        host: 'accounts.spotify.com',
        path: '/authorize',
        queryParameters: {
          'client_id': spotifyClientId,
          'redirect_uri': spotifyRedirectUri,
          'scope': scope,
          'response_type': 'code',
          'show_dialog': 'true'
        });

    final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(), callbackUrlScheme: "playlistpursuit");

    final code = Uri.parse(result).queryParameters['code'];

    print("Your code is: " + result.toString());

    // if (await canLaunchUrl(authUrl)) {
    //   await launchUrl(authUrl);
    // } else {
    //   throw 'Could not launch $authUrl';
    // }
  }
}
