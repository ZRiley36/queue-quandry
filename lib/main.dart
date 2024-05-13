import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'styles.dart';



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
      home: const HomePage(),
    );
  }
}

