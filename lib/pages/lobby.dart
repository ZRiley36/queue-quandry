import 'package:flutter/material.dart';
import 'package:queue_quandry/pages/login.dart';
import 'package:queue_quandry/styles.dart';
import 'game.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../spotify-api.dart';

Map<String, int> players = {};

List<MyPlayer> playerList = [];

int songsPerPlayer = 3;
int songsAdded = 0;

String myName = 'LocalHost';

Future<String> getLocalUserID() async {
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me'),
    headers: {
      'Authorization': 'Bearer $myToken',
    },
  );

  return json.decode(response.body)['id'];
}

class LobbyPage extends StatefulWidget {
  final int numPlayers;
  final int songsPerPlayer;

  const LobbyPage({
    Key? key,
    this.numPlayers = 2,
    this.songsPerPlayer = 1,
  }) : super(key: key);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late int _numPlayers;
  String localUserID = "DefaultUser";

  Future<void> addLocalPlayer() async {
    localUserID = await getLocalUserID();
    myName = localUserID;

    var localPlayer = MyPlayer(localUserID);

    setState(() {
      playerList.add(localPlayer);
    });
  }

  Future<void> addHeadlessPlayer(String id) async {
    setState(() {
      playerList.add(MyPlayer(id));
    });
  }

  Future<void> addRemotePlayer(String incomingID) async {
    setState(() {
      playerList.add(MyPlayer(incomingID));
    });
  }

  @override
  void initState() {
    super.initState();
    _numPlayers = widget.numPlayers;

    // populate the lobby
    addLocalPlayer();
    // DEBUG: add more players
    addHeadlessPlayer('abrawolf');
    addHeadlessPlayer('tommyryan2002');
    addHeadlessPlayer('nickwaizenegger');
    addHeadlessPlayer('player0');
  }

  void removePlayer(String user_id) {
    setState(() {
      playerList.remove(user_id);
    });
  }

  Future<void> _initAllPlayers() async {
    await Future.forEach(playerList, (MyPlayer instance) async {
      await instance.initPlayer();
    });
  }

  Widget _createAllPlayerListings() {
    print("creating all player listings");

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemCount: playerList.length,
      itemBuilder: (BuildContext context, int index) {
        final playerInstance = playerList[index];

        return Padding(
          padding: EdgeInsets.only(top: 6, bottom: 6),
          child: PlayerListing(
            imageUrl: playerInstance.image,
            name: playerInstance.display_name,
            removePlayer: removePlayer,
            enableKicking: playerInstance.user_id != localUserID,
          ),
        );
      },
    );
  }

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
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: spotifyBlack,
      body: Padding(
          padding: EdgeInsets.only(left: 18, right: 18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            Container(
                child: FutureBuilder<void>(
              future:
                  _initAllPlayers(), // The future passed from the parent widget
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show a loading spinner
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else {
                  return _createAllPlayerListings();
                }
              },
            )

                // return Padding(
                //   padding: EdgeInsets.only(top: 6, bottom: 6),
                //   child: PlayerListing(
                //     imageUrl: player.image,
                //     name: player.display_name,
                //     removePlayer: removePlayer,
                //     enableKicking: player.user_id != localUserID,
                //   ),
                // );

                ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: () {
                _share();
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  children: [
                    Text(
                      "Invite",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      height: 30,
                      child: Icon(
                        Icons.ios_share_outlined,
                        color: Colors.black,
                      ),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
            ),
            const Spacer(),
            Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Songs Per Player",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 5, right: MediaQuery.of(context).size.width * 0.7),
                    child: _buildDropdown(
                      'Songs Per Player',
                      songsPerPlayer,
                      (value) {
                        setState(() {
                          songsPerPlayer = value!;
                        });
                      },
                    ),
                  ),
                  if (players.length > 1)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QueuePage(
                                    numPlayers: _numPlayers,
                                    songsPerPlayer: songsPerPlayer,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF9d40e3),
                                minimumSize: Size(150, 50)),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  fontFamily: 'Gotham'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  )
                ]),
          ])),
      // Container(
      //   decoration: BoxDecoration(color: Colors.red),
      //   height: MediaQuery.of(context).size.height * 0.2,
      // ),
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

  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    songsAdded = 0;
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
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add Some Songs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: spotifyBlack,
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
            isSearching
                ? Container()
                : SizedBox(height: MediaQuery.of(context).size.height * 0.005),
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
                isSearching
                    ? ""
                    : "Queue " +
                        (songsPerPlayer - songsAdded).toString() +
                        " more songs",
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
                if (songsAdded + 1 > songsPerPlayer && isChecked == false) {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text("Queue Limit Reached"),
                        content: Text(
                            "You can't add more than $songsPerPlayer songs."),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text(
                              "OK",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

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
  final Function(String)? removePlayer;
  final bool enableKicking;

  PlayerListing({
    this.imageUrl =
        "https://i.scdn.co/image/ab6761610000e5eba1b1a48354e9a91fef58f651",
    this.name = "DefaultName",
    this.iconData = Icons.remove_circle,
    this.removePlayer,
    this.enableKicking = true,
  });

  @override
  _PlayerListingState createState() => _PlayerListingState();
}

class _PlayerListingState extends State<PlayerListing> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
          ClipOval(
            child: Image.network(
              widget.imageUrl,
              width: 35,
              height: 35,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Enable the kicking option if it's allowed for the player

          widget.enableKicking
              ? GestureDetector(
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("Confirm"),
                          content: Text(
                              "Are you sure you want to kick ${widget.name} from the lobby?"),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Kick",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              onPressed: () {
                                setState(() {
                                  // players.remove(widget.name);
                                  widget.removePlayer?.call(widget.name);
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
