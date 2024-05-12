import 'dart:async';

import 'package:flutter/material.dart';
import 'package:queue_quandry/pages/home.dart';
import 'package:queue_quandry/pages/lobby.dart';
import 'package:queue_quandry/styles.dart';

Map<String, int> players = {
  'Player_1': 0,
  'Player_2': 0,
  'Player_3': 0,
};

final String myName = 'Player_3';
final int winningScore = 10;

class GuessingPage extends StatefulWidget {
  const GuessingPage({Key? key}) : super(key: key);

  @override
  _GuessingPageState createState() => _GuessingPageState();
}

class _GuessingPageState extends State<GuessingPage> {
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
    if (correctGuess) {
      int idx = -1;
      for (int i = 0; i < players.entries.length; i++) {
        if (players.entries.elementAt(i).key == myName) {
          // Retrieve the current value and add 10 to it
          int currentValue = players.entries.elementAt(i).value;
          players[myName] = currentValue + 10;
          idx = i;

          if (players.entries.elementAt(idx).value >= winningScore) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinishPage(
                  playerWon: true,
                ),
              ),
            );
          }
        }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            isCorrect: correctGuess,
          ),
        ),
      );
    }
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

class ResultPage extends StatefulWidget {
  final bool isCorrect; // Step 1: Add the isCorrect parameter
  const ResultPage({Key? key, required this.isCorrect}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final bool isCorrect;
  final String correctChoice = 'Player_1';

  bool playerWon = false;

  double _progressValue = 0.0;

  void _startTimer() {
    const duration = Duration(seconds: 10);
    const steps = 500;
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
    isCorrect = widget.isCorrect;

    // Begin the timer
    _startTimer();
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuessingPage(),
      ),
    );
  }

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
                  'https://i.scdn.co/image/ab6761610000e5eba1b1a48354e9a91fef58f651',
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
            ),
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 6,
              width: MediaQuery.of(context).size.width * 0.6,
              child: LinearProgressIndicator(
                backgroundColor: myBoxColor,
                value: _progressValue,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        ],
      )),
    );
  }
}

class FinishPage extends StatefulWidget {
  final bool playerWon;
  const FinishPage({Key? key, required this.playerWon}) : super(key: key);

  @override
  _FinishPageState createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  // Remove late initialization of playerWon
  // late final bool playerWon;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        widget.playerWon ? const Color(0xFF1cb955) : const Color(0xFFfe3356);
    String playStatus = widget.playerWon ? 'You Win' : 'You Lost';
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
          SizedBox(height: 150),
          Text('Final Scores',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 35),
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
                SizedBox(
                  height: 10,
                )
              ],
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
                      builder: (context) => EndPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(150, 50) // Change button color to purple
                    ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      fontFamily: 'Gotham'),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class EndPage extends StatefulWidget {
  const EndPage({Key? key}) : super(key: key);

  @override
  _EndPageState createState() => _EndPageState();
}

class _EndPageState extends State<EndPage> {
  bool _isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isChecked = true;
  }

  @override
  Widget build(BuildContext context) {
    final String albumArt =
        "https://marketplace.canva.com/EAEdeiU-IeI/1/0/1600w/canva-purple-and-red-orange-tumblr-aesthetic-chill-acoustic-classical-lo-fi-playlist-cover-jGlDSM71rNM.jpg";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: <Widget>[
          Flexible(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 250,
                  ),
                  const Text(
                    "Relive your Game",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      albumArt,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: Duration(
                        milliseconds: 200), // Adjust duration as needed
                    child: _isChecked
                        ? Column(
                            key: ValueKey<bool>(_isChecked),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                                child: Container(
                                  key: ValueKey<bool>(_isChecked),
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white, // circle fill
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  "Empty",
                                  style: TextStyle(
                                      color: Colors.transparent, fontSize: 15),
                                ),
                              )
                            ],
                          )
                        : Column(
                            key: ValueKey<bool>(_isChecked),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                                child: Container(
                                  key: ValueKey<bool>(_isChecked),
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green, // circle fill
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  "Saved playlist to your profile.",
                                  style: TextStyle(
                                      color: Color.fromARGB(170, 201, 201, 201),
                                      fontSize: 15),
                                ),
                              )
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
// Add some space between the content and the button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 50), // Adjust this value as needed
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LobbyPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: spotifyGreen,
                    minimumSize: Size(70, 50) // Change button color to purple
                    ),
                child: const Text(
                  'Continue',
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
    );
  }
}
