import 'package:flutter/material.dart';
import 'package:queue_quandry/pages/home.dart';
import '../styles.dart';
import '../main.dart';
import 'game.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class LobbyPage extends StatefulWidget {
  final int numPlayers;
  final int songsPerPlayer;

  const LobbyPage({Key? key, this.numPlayers = 2, this.songsPerPlayer = 1})
      : super(key: key);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late int _numPlayers;
  late int _songsPerPlayer;

  @override
  void initState() {
    super.initState();
    _numPlayers = widget.numPlayers;
    _songsPerPlayer = widget.songsPerPlayer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: spotifyBlack,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        title: const Text(
          'Create Lobby',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: spotifyBlack,
      body: Padding(
        padding: EdgeInsets.only(left: 18, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Contribute anonymously to a playlist. Try to guess who queued each song after they play.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            const Text(
              'Manage players',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: spotifyGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 55,
              child: PlayerListing(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Songs Per Player",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(right: 150),
              child: _buildDropdown(
                'Songs Per Player',
                _songsPerPlayer,
                (value) {
                  setState(() {
                    _songsPerPlayer = value!;
                  });
                },
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QueuePage(
                            numPlayers: _numPlayers,
                            songsPerPlayer: _songsPerPlayer,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9d40e3),
                        minimumSize: Size(150, 50)),
                    child: const Text(
                      'Let\'s Play',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          fontFamily: 'Gotham'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _share();
                    },
                    child: Text('Share Link'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share() async {
    final result = await Share.share('check out my website https://example.com',
        subject: "Invite to Game");
  }
}

DropdownButtonFormField<int> _buildDropdown(
    String label, int currentValue, void Function(int?)? onChanged) {
  return DropdownButtonFormField<int>(
    decoration: InputDecoration(
      fillColor: Color.fromARGB(255, 41, 41, 41),
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          )),
    ),
    value: currentValue,
    dropdownColor: Color.fromARGB(255, 41, 41, 41),
    focusColor: Color.fromARGB(255, 41, 41, 41),
    iconEnabledColor: Color.fromARGB(255, 41, 41, 41),
    style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    items: List.generate(10, (index) => index + 1)
        .map((num) => DropdownMenuItem<int>(
              value: num,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 18), // Adjust the right padding as needed
                child: Text(num.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ),
            ))
        .toList(),
    onChanged: onChanged,
    isExpanded: true,
  );
}

class QueuePage extends StatefulWidget {
  final int numPlayers;
  final int songsPerPlayer;

  const QueuePage(
      {Key? key, required this.numPlayers, required this.songsPerPlayer})
      : super(key: key);

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  TextEditingController _controller = TextEditingController();
  int songsAdded = 0;
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add Some Songs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              onChanged: (value) {
                setState(() {
                  isSearching = value.isNotEmpty;
                });
                String searchTerm = value;
                print('Searching for song: $searchTerm');
              },
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                hintText: 'What do you want to listen to?',
                hintStyle: TextStyle(color: Colors.black),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 30),
            isSearching
                ? Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Search results",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Recent songs",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            isSearching ? Container() : SizedBox(height: 30),
            isSearching
                ? Container()
                : Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: SongListing(
                            onIncrement: incrementSongsAdded,
                            onDecrement: decrementSongsAdded,
                          ),
                        );
                      },
                    ),
                  ),
            isSearching ? Container() : SizedBox(height: 20),
            Center(
              child: Text(
                isSearching ? "" : "Songs added: " + songsAdded.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            isSearching
                ? Container()
                : Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GuessingPage()),
                        );
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void incrementSongsAdded() {
    setState(() {
      songsAdded++;
    });
  }

  void decrementSongsAdded() {
    setState(() {
      songsAdded--;
    });
  }
}

class SongListing extends StatefulWidget {
  final String imageUrl;
  final String name;
  final IconData iconData;
  final String artist;
  final Function()? onIncrement;
  final Function()? onDecrement;

  SongListing({
    this.imageUrl =
        "https://images.genius.com/69c8990d3a6b135efe69859e18287d1d.1000x1000x1.jpg",
    this.name = "What Once Was",
    this.iconData = Icons.favorite,
    this.artist = "Her's",
    this.onIncrement,
    this.onDecrement,
  });

  @override
  _SongListingState createState() => _SongListingState();
}

class _SongListingState extends State<SongListing> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Color.fromARGB(255, 41, 41, 41),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                isChecked = !isChecked;
                if (isChecked) {
                  widget.onIncrement?.call();
                } else {
                  widget.onDecrement?.call();
                }
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? Colors.green : Colors.white,
              ),
              child: Icon(
                isChecked ? Icons.check : Icons.add,
                color: isChecked ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3),
        ],
      ),
    );
  }
}

class PlayerListing extends StatefulWidget {
  final String imageUrl;
  final String name;
  final IconData iconData;
  final Function()? onIncrement;
  final Function()? onDecrement;

  PlayerListing({
    this.imageUrl =
        "https://images.genius.com/69c8990d3a6b135efe69859e18287d1d.1000x1000x1.jpg",
    this.name = "Billy",
    this.iconData = Icons.favorite,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  _PlayerListingState createState() => _PlayerListingState();
}

class _PlayerListingState extends State<PlayerListing> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Color.fromARGB(255, 41, 41, 41),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                isChecked = !isChecked;
                if (isChecked) {
                  widget.onIncrement?.call();
                } else {
                  widget.onDecrement?.call();
                }
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? Colors.green : Colors.white,
              ),
              child: Icon(
                isChecked ? Icons.check : Icons.add,
                color: isChecked ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3),
        ],
      ),
    );
  }
}
