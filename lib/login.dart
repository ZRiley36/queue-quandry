
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'main.dart';
import 'credentials.dart';
const scope = 'user-read-private user-read-email';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Color backgroundColor = const Color(0xff8300E7);
  String loginMessage = 'Login to Spotify';
  String googleMessage = 'Continue with Google';
  String facebookMessage = 'Continue with Facebook';
  String appleMessage = 'Continue with Apple';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(loginMessage),
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
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Spotify green color
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, color: Colors.white), // Spotify music note icon
                    SizedBox(width: 10), // Spacer
                    Text('Log in with Spotify', style: TextStyle(color: Colors.white)),
                  ],
                ),
              )
        ]
      )));
  }
  void _login() async {

    Uri authUrl = Uri(
        scheme: 'https',
        host: 'accounts.spotify.com',
        path: '/authorize',
        queryParameters: {'client_id': spotifyClientId, 'redirect_uri': spotifyRedirectUri, 'scope': scope, 'response_type': 'code', 'show_dialog': 'true'});


    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl);
    } else {
      throw 'Could not launch $authUrl';
    }
  }
}


