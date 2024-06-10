import 'package:queue_quandry/credentials.dart';
import 'package:queue_quandry/pages/lobby.dart';
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

Future<void> skipTrack() async {
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
    print(response.body);
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

Future<Map<String, dynamic>> getCurrentTrack() async {
  await ensureTokenIsValid();

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  var body = json.decode(response.body);
  return body['item'];
  // print("Here is the track:" + body['item']);
}

Future<bool> isPlaying() async {
  await ensureTokenIsValid();

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/player'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  var body = json.decode(response.body);
  return body['is_playing'];
}

Future<List<String>> searchQuery(String query) async {
  await ensureTokenIsValid();

  final String url = 'https://api.spotify.com/v1/search';

  try {
    final response = await http.get(
      Uri.parse(
          '$url?q=${Uri.encodeComponent(query)}&type=track&market=US&limit=5'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> tracks = data['tracks']['items'];
      List<String> trackIds =
          tracks.map<String>((track) => track['id'] as String).toList();
      return trackIds;
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

Future<String?> getActiveDevice() async {
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/player/devices'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  if (response.statusCode == 200) {
    final devices = json.decode(response.body)['devices'];
    for (var device in devices) {
      if (device['is_active'] == true) {
        return device['id'];
      }
    }
    return null;
  } else {
    throw Exception('Failed to get devices: ${response.reasonPhrase}');
  }
}

Future<void> playTrack(String track_id) async {
  await ensureTokenIsValid();

  String? deviceId = await getActiveDevice();
  String track_uri = "spotify:track:" + track_id;

  final response = await http.put(
    Uri.parse('https://api.spotify.com/v1/me/player/play'),
    headers: {
      'Authorization': 'Bearer $myToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'device_id': deviceId,
      'uris': [track_uri],
    }),
  );

  if (response.statusCode == 204) {
  } else {
    throw Exception('Failed to play song: ${response.reasonPhrase}');
  }
}

Future<dynamic> getTrackInfo(String track_id) async {
  await ensureTokenIsValid();

  final String url = 'https://api.spotify.com/v1/tracks/$track_id';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load track');
  }
}

Future<void> cleanSpotifyQueue() async {
  bool queueNotEmpty = true;

  while (queueNotEmpty) {
    try {
      await skipTrack();
    } catch (e) {
      queueNotEmpty = false;
      print('Queue is now empty or there was an error: $e');
    }
  }
}

Future<void> createPlaylist(String playlistName) async {
  final response = await http.post(
    Uri.parse('https://api.spotify.com/v1/users/$localUserID/playlists'),
    headers: {
      'Authorization': 'Bearer $myToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'name': playlistName,
      'public': false, // Change to true if you want the playlist to be public
    }),
  );

  if (response.statusCode == 201) {
    final playlistData = json.decode(response.body);
    final playlistId = playlistData['id'];

    // Add tracks to the newly created playlist
    await addTracksToPlaylist(playlistId);

    print('Playlist created successfully.');
  } else {
    throw Exception('Failed to create playlist: ${response.reasonPhrase}');
  }
}

Future<void> addTracksToPlaylist(String playlistId) async {
  final response = await http.post(
    Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
    headers: {
      'Authorization': 'Bearer $myToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'uris': songQueue.map((id) => 'spotify:track:$id').toList(),
    }),
  );
}
