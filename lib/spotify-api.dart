import 'package:queue_quandry/pages/login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayerUtils {
  PlayerUtils._();

  static Future<String> getLocalUserID() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    return json.decode(response.body)['id'];
  }

  static Future<String> getUserPicture(String user_id) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/users/$user_id'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    var responseData = json.decode(response.body);
    return responseData['images'][0]['url'];
  }

  static Future<String> getLocalUserDisplayName() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    return json.decode(response.body)['display_name'];
  }

  // Gets a specified user's profile
  static Future<String> getRemoteUserDisplayName(String user_id) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/users/$user_id'),
      headers: {
        'Authorization': 'Bearer $myToken',
      },
    );

    return json.decode(response.body)['display_name'];
  }
}
