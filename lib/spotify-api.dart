import 'package:queue_quandry/credentials.dart';
import 'package:queue_quandry/pages/login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spotify_sdk/spotify_sdk.dart';

class Track {
  final String track_id;
  late String imageUrl = "";
  late String name = "";
  late String artist = "";

  Track(this.track_id);

  Future<void> fetchTrackData() async {
    final String url = 'https://api.spotify.com/v1/tracks/$track_id';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      name = data['name'];
      artist = data['artists'][0]['name'];
      imageUrl = data['album']['images'][0]['url'];
    } else {
      throw Exception('Failed to load track');
    }
  }
}

class MyPlayer {
  final String user_id;
  late String display_name;
  late String image;
  bool isInitialized;
  int score = 0;

  MyPlayer(this.user_id, {this.isInitialized = false});

  Future<void> initPlayer() async {
    await ensureTokenIsValid();

    display_name = await getDisplayName();
    image = await getUserPicture();

    isInitialized = true;
  }

  Future<String> getUserPicture() async {
    await ensureTokenIsValid();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/users/$user_id'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    var responseData = json.decode(response.body);
    return responseData['images'][0]['url'];
  }

  Future<String> getDisplayName() async {
    await ensureTokenIsValid();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/users/$user_id'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    return json.decode(response.body)['display_name'];
  }
}

Future<void> pausePlayback() async {
  await ensureTokenIsValid();

  await http.put(
    Uri.parse('https://api.spotify.com/v1/me/player/pause'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );
}

Future<void> resumePlayback() async {
  await ensureTokenIsValid();

  await http.put(
    Uri.parse('https://api.spotify.com/v1/me/player/play'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );
}

Future<void> addToQueue(String? trackUri, String? accessToken) async {
  await ensureTokenIsValid();

  final url =
      Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=$trackUri');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 204) {
    print('Track added to queue successfully');
  } else {
    print(
        'Failed to add track to queue: ${response.statusCode}, ${response.body}');
  }
}
