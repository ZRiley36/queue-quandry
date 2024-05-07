import 'package:flutter/material.dart';
import 'package:queue_quandry/pages/login.dart';
import '../styles.dart';
import 'package:queue_quandry/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spotifyBlack,
      body: Center(
        // Wrap the Column with Center widget
        child: Padding(
          padding: EdgeInsets.only(left: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .center, // Align children vertically in the center
            children: [
              const Text('PlaylistPursuit',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 20), // Add space between text and button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: spotifyGreen,
                  minimumSize: Size(150, 50),
                ),
                child: const Text(
                  'Let\'s Go',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    fontFamily: 'Gotham',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
