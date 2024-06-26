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
import '../main.dart';
import 'package:logger/logger.dart';

ValueNotifier<List<MyPlayer>> playerList = ValueNotifier<List<MyPlayer>>([]);
List<String> songQueue = [];

int songsPerPlayer = 3;
ValueNotifier<int> songsAdded = ValueNotifier<int>(0);
List<String> playbackQueue = [];

String localUserID = "DefaultUser";

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
  final int songsPerPlayer;
  final bool reset;

  const LobbyPage({
    Key? key,
    this.songsPerPlayer = 1,
    required this.reset,
  }) : super(key: key);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  Future<void> addLocalPlayer() async {
    localUserID = await getLocalUserID();

    playerList.value.add(MyPlayer(localUserID));
  }

  void addHeadlessPlayer(String id) {
    playerList.value.add(MyPlayer(id));
  }

  void addRemotePlayer(String incomingID) {
    playerList.value.add(MyPlayer(incomingID));
  }

  void resetLobby() {
    playerList.value.clear();
  }

  @override
  void initState() {
    super.initState();

    // reset the lobby
    if (widget.reset) resetLobby();

    _initAllPlayers();
  }

  void removePlayer(MyPlayer playerInstance) {
    String display_name = playerInstance.display_name;

    playerList.value.remove(playerInstance);

    print("🔴 Removed player $display_name from lobby.");

    playerList.notifyListeners();
  }

  Future<void> _initAllPlayers() async {
    print("init all players");

    // populate the lobby
    await addLocalPlayer();
    addHeadlessPlayer('abrawolf');
    addHeadlessPlayer('tommyryan2002');
    addHeadlessPlayer('nickwaizenegger');

    await Future.forEach(playerList.value, (MyPlayer instance) async {
      if (!instance.isInitialized) {
        await instance.initPlayer();
        String display_name = instance.display_name;
        print("🟢 Player $display_name joined lobby.");

        playerList.notifyListeners();
      }
    });

    setState(() {});
  }

  Widget _createAllPlayerListings() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemCount: playerList.value.length,
      itemBuilder: (BuildContext context, int index) {
        final playerInstance = playerList.value[index];

        if (playerInstance.isInitialized == false) {
          return Container();
        }

        return Padding(
          padding: EdgeInsets.only(top: 6, bottom: 6),
          child: PlayerListing(
            playerInstance: playerInstance,
            onRemove: removePlayer,
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
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                child: ValueListenableBuilder<List<MyPlayer>>(
                  valueListenable: playerList,
                  builder: (context, value, child) {
                    if (value.length < 1) {
                      return Text(
                        'Loading players...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      );
                    }

                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final playerInstance = playerList.value[index];

                        if (playerInstance.isInitialized == false) {
                          return Container();
                        }

                        return Padding(
                          padding: EdgeInsets.only(top: 6, bottom: 6),
                          child: PlayerListing(
                            playerInstance: playerInstance,
                            onRemove: removePlayer,
                          ),
                        );
                      },
                    );
                  },
                )),
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
                  if (playerList.value.length > 1)
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
  final int songsPerPlayer;

  const QueuePage({Key? key, required this.songsPerPlayer}) : super(key: key);

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  TextEditingController _controller = TextEditingController();

  bool isSearching = false;
  Future<List<String>>? _fetchTopSongsFuture;
  Future<List<String>>? _searchedSongs;

  Future<List<String>> fetchTopSongs() async {
    return await getTopTracks(myToken);
  }

  @override
  void initState() {
    super.initState();

    songsAdded.value = 0;
    songQueue = [];
    playbackQueue = [];
    _fetchTopSongsFuture = fetchTopSongs();
  }

  Future<void> _search(String query) async {
    _searchedSongs = searchQuery(query);
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
                _search(searchTerm);
              },
              decoration: const InputDecoration(
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
            const SizedBox(height: 30),
            isSearching
                ? const Padding(
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
                : const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Your top songs",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            isSearching
                ? Expanded(
                    child: FutureBuilder(
                        future: _searchedSongs,
                        builder:
                            (context, AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Loading...',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error searching query'));
                          } else {
                            return ListView.builder(
                                itemCount: 5,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: SongListing(
                                      track: Track(snapshot.data![index]),
                                      onIncrement: incrementSongsAdded,
                                      onDecrement: decrementSongsAdded,
                                    ),
                                  );
                                });
                          }
                        }))
                : Expanded(
                    child: FutureBuilder(
                      future: _fetchTopSongsFuture,
                      builder: (context, AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Loading tracks...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        } else {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error fetching top songs'));
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: SongListing(
                                    track: Track(snapshot.data![index]),
                                    onIncrement: incrementSongsAdded,
                                    onDecrement: decrementSongsAdded,
                                  ),
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            ValueListenableBuilder(
                valueListenable: songsAdded,
                builder: (context, value, child) {
                  return Builder(builder: (BuildContext context) {
                    bool _enableButton = false; // true jsut for debug

                    if (widget.songsPerPlayer - songsAdded.value <= 0) {
                      _enableButton = true;
                    }

                    if (_enableButton) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            playbackQueue = [...songQueue];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GuessingPage()),
                            );
                          },
                          child: Text(
                            "Start Game",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: spotifyGreen,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                          child: Text(
                        "Add " +
                            (widget.songsPerPlayer - songsAdded.value)
                                .toString() +
                            " more songs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ));
                    }
                  });
                }),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void incrementSongsAdded() {
    songsAdded.value++;
  }

  void decrementSongsAdded() {
    songsAdded.value--;
  }
}

class SongListing extends StatefulWidget {
  final Track track;
  final Function()? onIncrement;
  final Function()? onDecrement;

  SongListing({
    required this.track,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  _SongListingState createState() => _SongListingState();
}

class _SongListingState extends State<SongListing> {
  ValueNotifier<bool> isChecked = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    if (songQueue.contains(widget.track.track_id)) {
      isChecked.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: widget.track.fetchTrackData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
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
                    widget.track.imageUrl,
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
                        widget.track.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.track.artist,
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
                      if (!isChecked.value &&
                          songsAdded.value + 1 > songsPerPlayer) {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text("Queue Limit Reached"),
                              content: Text(
                                  "You can't add more than $songsPerPlayer songs."),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text("OK",
                                      style:
                                          TextStyle(color: Colors.redAccent)),
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

                      isChecked.value = !isChecked.value;
                      if (isChecked.value) {
                        songQueue.add(widget.track.track_id);
                        widget.onIncrement?.call();
                      } else {
                        songQueue.remove(widget.track.track_id);
                        widget.onDecrement?.call();
                      }
                    },
                    child: ValueListenableBuilder<bool>(
                        valueListenable: isChecked,
                        builder: (context, value, child) {
                          return Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isChecked.value ? Colors.green : Colors.white,
                            ),
                            child: Icon(
                              isChecked.value ? Icons.check : Icons.add,
                              color:
                                  isChecked.value ? Colors.white : Colors.black,
                              size: 20,
                            ),
                          );
                        })),
                SizedBox(width: 3),
              ],
            ),
          );
        }
      },
    );
  }
}

class PlayerListing extends StatefulWidget {
  final MyPlayer playerInstance;
  final Function(MyPlayer)? onRemove;

  PlayerListing({
    required this.playerInstance,
    this.onRemove,
  });

  @override
  _PlayerListingState createState() => _PlayerListingState();
}

class _PlayerListingState extends State<PlayerListing> {
  bool enableKicking = false;

  @override
  void initState() {
    super.initState();

    bool isRemote = (localUserID != widget.playerInstance.user_id);

    setState(() {
      if (isRemote) {
        enableKicking = true;
      } else {
        enableKicking = false;
      }
    });
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
              widget.playerInstance.image,
              width: 35,
              height: 35,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.playerInstance.display_name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Enable the kicking option if it's allowed for the player

          enableKicking
              ? GestureDetector(
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("Confirm"),
                          content: Text(
                              "Are you sure you want to kick ${widget.playerInstance.display_name} from the lobby?"),
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
                                  widget.onRemove?.call(widget.playerInstance);
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
