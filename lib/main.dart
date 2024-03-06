import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';

const Color spotifyGreen = Color(0xFF1cb955);

Map<String, int> players = {
  'Kate': 10,
  'Max': 20,
  'Peter': 15,
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Gotham'),
      home: const LobbyPage(),
    );
  }
}

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            // Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Create Lobby',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color(0xFF121212),
      body: Padding(
        padding: EdgeInsets.only(left: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Queue Quandary',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'contribute anonymously to a playlist. try to guess who queued each song after they play.',
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 50),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9d40e3),
                      minimumSize:
                          Size(150, 50) // Change button color to purple
                      ),
                  child: const Text(
                    'Let\'s Play',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        fontFamily: 'Gotham'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Fields (to be mutated by Spotify API)
  String songName = "Purple Haze";
  String songArtist = "Jimi Hendrix";
  String albumArt =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Are_You_Experienced_-_US_cover-edit.jpg/1200px-Are_You_Experienced_-_US_cover-edit.jpg';

  // Fields (to be mutated by our backend)
  int guiltyPlayer = 0;

  // Local fields
  double _progressValue = 0.0;
  bool correctGuess = false;
  String playerName = 'Billy';
  int guessedPlayer = -1;

  List<bool> buttonsPressed = [];

  void _startTimer() {
    const duration = Duration(seconds: 5);
    const steps = 500; // Number of steps for smoother animation
    final stepDuration = duration ~/ steps;
    final increment = 1 / steps.toDouble();

    Timer.periodic(stepDuration, (Timer timer) {
      setState(() {
        _progressValue += increment;
      });
      if (_progressValue >= 1.0) {
        timer.cancel();
        _navigateToNextPage();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < players.entries.length; i++) {
      buttonsPressed.add(false);
    }

    // Begin the timer
    _startTimer();
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondPage(
          isCorrect: correctGuess,
        ),
      ),
    );
  }

  void _handleButtonPressed(int buttonIndex) {
    setState(() {
      for (int i = 0; i < buttonsPressed.length; i++) {
        buttonsPressed[i] = false;
      }

      buttonsPressed[buttonIndex] = true;

      if (buttonIndex == guiltyPlayer) {
        correctGuess = true;
      } else {
        correctGuess = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8300e7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Who queued it?',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                albumArt,
                height: 200,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              songName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(songArtist,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.normal)),
            const SizedBox(height: 20),
            for (int i = 0; i < players.entries.length; i++)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10), // Add vertical space between buttons
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _handleButtonPressed(i);
                        });
                      },
                      child: Text(
                        players.entries.elementAt(i).key,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(200, 70)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (buttonsPressed[i] == true) {
                                return Color(0xFF5e03a6);
                              } else {
                                return Color(0xFF7202ca);
                              }
                            },
                          )),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 6,
                width: MediaQuery.of(context).size.width * 0.6,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFF9d40e3),
                  value: _progressValue,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final bool isCorrect;
  final String correctChoice = 'Kate';
  final String myName = 'Max';

  const SecondPage({Key? key, required this.isCorrect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isCorrect ? const Color(0xFF1cb955) : const Color(0xFFfe3356);
    String playStatus = isCorrect ? 'Correct' : 'Wrong';
    Color boxColor = backgroundColor == const Color(0xFF1cb955)
        ? const Color(0xFF0d943f)
        : const Color(0xFFdb2948);
    Color myBoxColor;
    if (boxColor == const Color(0xFFdb2948))
      myBoxColor = const Color(0xFFa11b32);
    else
      myBoxColor = const Color(0xFF096129);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 80,
          ),
          Text(
            playStatus,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ClipOval(
              child: Image.network(
                  'https://i.ytimg.com/vi/fAcW5O4sSRY/hq720.jpg?sqp=-oaymwEYCJUDENAFSFryq4qpAwoIARUAAIhC0AEB&rs=AOn4CLC5Rxef_pzu80w7hkFhSN62J91k-g',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover)),
          Text(correctChoice,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 30),
          Text('Current Scores',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 20),
          for (int i = 0; i < players.entries.length; i++)
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 60,
                  decoration: BoxDecoration(
                    color: players.entries.elementAt(i).key == myName
                        ? myBoxColor
                        : boxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left-aligned text
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            players.entries.elementAt(i).key,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Right-aligned text
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            players[players.entries.elementAt(i).key]
                                .toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            )

          // ElevatedButton(
          //     onPressed: () {
          //       // Navigator.push(
          //       //     context,
          //       //     MaterialPageRoute(
          //       //         builder: (context) => const MyHomePage()));

          //       Share.share('hello');
          //     },
          //     child: Text('DEBUG: share')))
        ],
      )),
    );
  }
}
