import 'dart:async';
import 'package:queue_quandry/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:queue_quandry/spotify-api.dart';
import "../credentials.dart";
import 'package:flutter/material.dart';
import 'lobby.dart';
import 'package:queue_quandry/styles.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'dart:convert';

final int winningScore = 10;
bool musicPlaying = true;

class GuessingPage extends StatefulWidget {
  GuessingPage();

  @override
  _GuessingPageState createState() => _GuessingPageState();
}

class _GuessingPageState extends State<GuessingPage> {
  bool _trackDataLoaded = false;
  // Fields (to be mutated by Spotify API)
  late String songName;
  late String songArtist;
  late String albumArt;
  late int songLength;

  // Fields (to be mutated by our backend)
  MyPlayer guiltyPlayer = playerList[0];

  // Local fields
  bool correctGuess = false;
  int guessedPlayer = -1;

  List<bool> buttonsPressed = [];

  Future<void> getNewTrack() async {
    // await cleanSpotifyQueue();

    String new_song = songQueue.removeAt(0);

    var data = await getTrackInfo(new_song);
    await playTrack(new_song);

    songName = data['name'];

    songArtist = data['artists'][0]['name'];
    albumArt = data['album']['images'][0]['url'];
    songLength = (data['duration_ms'] / 1000).toInt();

    _trackDataLoaded = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < playerList.length; i++) {
      buttonsPressed.add(false);
    }

    getNewTrack();
  }

  void _navigateToNextPage() async {
    for (int i = 0; i < playerList.length; i++) {
      if (playerList[i].user_id == localUserID && correctGuess) {
        // Retrieve the current value and add 10 to it
        playerList[i].score += 10;
      }
    }

    for (int i = 0; i < playerList.length; i++) {
      if (playerList[i].score >= winningScore) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinishPage(
              playerWon: true,
            ),
          ),
        );

        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          isCorrect: correctGuess,
          guiltyPlayer: guiltyPlayer,
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

      if (buttonIndex == playerList.indexOf(guiltyPlayer)) {
        correctGuess = true;
      } else {
        correctGuess = false;
      }
    });
  }

  Future<void> _pause() async {
    musicPlaying = !musicPlaying;

    if (musicPlaying == false)
      while (await isPlaying() == true) {
        await pausePlayback();
      }
    else
      while (await isPlaying() == false) {
        await resumePlayback();
      }
  }

  @override
  Widget build(BuildContext context) {
    if (_trackDataLoaded) {
      return Scaffold(
          backgroundColor: const Color(0xFF8300e7),
          body: Center(
              child: Column(children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  const Text(
                    'Who queued it?',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    child: Builder(
                      builder: (context) {
                        if (_trackDataLoaded) {
                          return Column(
                            children: [
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
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  Container(
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                      shrinkWrap: true,
                      itemCount: playerList.length,
                      itemBuilder: (context, index) {
                        if (localUserID == playerList[index].user_id) {
                          return Container();
                        }
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _handleButtonPressed(index);
                              });
                            },
                            child: Text(
                              playerList[index].display_name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ButtonStyle(
                                minimumSize:
                                    MaterialStateProperty.all(Size(200, 70)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (buttonsPressed[index] == true) {
                                      return Color(0xFF5e03a6);
                                    } else {
                                      return Color(0xFF7202ca);
                                    }
                                  },
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TimerBar(
                          backgroundColor: Color(0xFF9d40e3),
                          progressColor: Colors.white,
                          period: Duration(seconds: songLength),
                          onComplete: _navigateToNextPage,
                        ), // Placeholder widget when songLength is not initialized
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _pause();
                            });
                          },
                          icon: musicPlaying
                              ? Icon(Icons.pause_rounded,
                                  color: Colors.white, size: 80)
                              : Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 80,
                                ),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ])));
    } else {
      return Scaffold(
        backgroundColor: spotifyPurple,
      );
    }
  }
}

class TimerBar extends StatefulWidget {
  final Color backgroundColor;
  final Color progressColor;
  final Duration period;
  final Function()? onComplete;

  TimerBar({
    required this.backgroundColor,
    required this.progressColor,
    required this.period,
    this.onComplete,
  });

  @override
  _TimerBarState createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar> {
  double _progressValue = 0.0;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  void _startTimer() {
    Duration duration = widget.period;
    const steps = 500;
    final stepDuration = duration ~/ steps;
    final increment = 1 / steps.toDouble();

    _timer = Timer.periodic(stepDuration, (Timer timer) {
      if (musicPlaying == false) return;

      setState(() {
        _progressValue += increment;
        _elapsed += stepDuration;
      });

      if (_progressValue >= 1.0) {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 6,
        width: MediaQuery.of(context).size.width * 0.6,
        child: LinearProgressIndicator(
          backgroundColor: widget.backgroundColor,
          value: _progressValue,
          valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final bool isCorrect;
  final MyPlayer guiltyPlayer;
  const ResultPage(
      {Key? key, required this.isCorrect, required this.guiltyPlayer})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final bool isCorrect;
  late String correctChoice;

  bool playerWon = false;

  @override
  void initState() {
    super.initState();
    isCorrect = widget.isCorrect;
    correctChoice = widget.guiltyPlayer.display_name;
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
          for (int i = 0; i < playerList.length; i++)
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    color: playerList[i].user_id == localUserID
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
                            playerList[i].display_name,
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
                            playerList[i].score.toString(),
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
          Expanded(
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    TimerBar(
                      backgroundColor: Color.fromARGB(255, 131, 0, 0),
                      progressColor: Colors.white,
                      period: Duration(seconds: 5),
                      onComplete: _navigateToNextPage,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1)
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                )),
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
          for (int i = 0; i < playerList.length; i++)
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 60,
                  decoration: BoxDecoration(
                    color: playerList[i].user_id == localUserID
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
                            playerList[i].display_name,
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
                            playerList[i].score.toString(),
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
                  SavePlaylistButton(),
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
                      builder: (context) => LobbyPage(
                        reset: true,
                      ),
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

class SavePlaylistButton extends StatefulWidget {
  final VoidCallback? onTap; // Callback function parameter

  SavePlaylistButton({this.onTap});

  @override
  _SavePlaylistButtonState createState() => _SavePlaylistButtonState();
}

class _SavePlaylistButtonState extends State<SavePlaylistButton> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
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
                    // Call the callback function if provided
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                  },
                  child: Container(
                    key: ValueKey<bool>(_isChecked),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
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
                    // Call the callback function if provided
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                  },
                  child: Container(
                    key: ValueKey<bool>(_isChecked),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
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
              ],
            ),
    );
  }
}
