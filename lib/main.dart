import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progressValue = 0.0;

  void _startTimer() {
    const duration = Duration(seconds: 10);
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

    // Begin the timer
    _startTimer();
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SecondPage()), // Replace SecondPage() with your desired page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9000FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Start Timer Bar'),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 4,
              width: MediaQuery.of(context).size.width -
                  40, // Adjust the width as needed
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                value: _progressValue,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: Text('This is the page where the queuer is listed'),
      ),
    );
  }
}
