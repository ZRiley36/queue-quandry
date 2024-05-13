// game_settings.dart
import 'package:flutter/material.dart';
import 'lobby.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({Key? key}) : super(key: key);

  @override
  _GameSettingsPageState createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  int _numPlayers = 2;
  int _songsPerPlayer = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Settings'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select Number of Players',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            DropdownButton<int>(
              value: _numPlayers,
              items: List.generate(10, (index) => index + 1)
                  .map((num) => DropdownMenuItem<int>(
                        value: num,
                        child: Text(num.toString(), style: TextStyle(color: Colors.black)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _numPlayers = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select Number of Songs per Player',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            DropdownButton<int>(
              value: _songsPerPlayer,
              items: List.generate(10, (index) => index + 1)
                  .map((num) => DropdownMenuItem<int>(
                        value: num,
                        child: Text(num.toString(), style: TextStyle(color: Colors.black)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _songsPerPlayer = value!;
                });
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LobbyPage(
                      numPlayers: _numPlayers,
                      songsPerPlayer: _songsPerPlayer,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text('Start Game', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
