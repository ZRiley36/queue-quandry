import 'package:queue_quandry/pages/login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPlayer {
  final String user_id;
  late String display_name;
  late String image;

  MyPlayer(this.user_id);

  Future<void> initPlayer() async {
    display_name = await getDisplayName();
    image = await getUserPicture();

    print("🎵 Player $user_id initialized.");
  }

  Future<String> getUserPicture() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/users/$user_id'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    var responseData = json.decode(response.body);
    return responseData['images'][0]['url'];
  }

  // Gets a specified user's profile
  Future<String> getDisplayName() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/users/$user_id'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    return json.decode(response.body)['display_name'];
  }
}
