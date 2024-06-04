import 'package:queue_quandry/credentials.dart';
import 'package:queue_quandry/pages/login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spotify_sdk/spotify_sdk.dart';

class Track {
  final String track_id;
  late String track_uri;
  late String imageUrl = "";
  late String name = "";
  late String artist = "";
  late int duration_ms = 0;

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
      track_uri = data['uri'];
      duration_ms = data['duration_ms'];
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
    // print('Track added to queue successfully');
  } else {
    print(
        'Failed to add track to queue: ${response.statusCode}, ${response.body}');
  }
}

Future<void> startNextTrack() async {
  await ensureTokenIsValid();

  final url = Uri.parse('https://api.spotify.com/v1/me/player/next');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $myToken',
    },
  );

  if (response.statusCode == 204) {
    print("next track");
  } else {
    print("failed to skip track");
  }
}

Future<List<String>> getTopTracks(String? accessToken) async {
  await ensureTokenIsValid();

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/top/tracks'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  if (response.statusCode == 200) {
    var temp = json.decode(response.body);

    List<String> topSongs = [];

    for (int i = 0; i < 5; i++) {
      topSongs.add(temp['items'][i]['id']);
    }

    // print(topSongs);
    return topSongs;
  } else {
    print('Failed to fetch top tracks.');
    return [];
  }
}

Future<int> getCurrentlyPlayingTrackDuration() async {
  await ensureTokenIsValid();

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  var body = json.decode(response.body);
  return body['item']['duration_ms'];
  // print("Here is the track:" + body['item']);
}
