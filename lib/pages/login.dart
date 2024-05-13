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

const scope = 'user-read-private user-read-email';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  String loginMessage = 'Login to Spotify';
  String debugMessage = 'Continue Offline';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: spotifyBlack,
        appBar: AppBar(
          backgroundColor: spotifyBlack,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              ElevatedButton(
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
                    Icon(Icons.music_note,
                        color: Colors.white), // Spotify music note icon
                    SizedBox(width: 10), // Spacer
                    Text(loginMessage, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              ElevatedButton(
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
                      spotifyPurple), // Spotify green color
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(debugMessage, style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
            ])));
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

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl);
    } else {
      throw 'Could not launch $authUrl';
    }
  }
}
