// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.deepPurple[200],
        appBar: AppBar(
          title: Text(
            "My App Bar",
            ),
          backgroundColor: Colors.deepPurple,
          leading: Icon(Icons.menu),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.logout),)
          ],
        ),
        body: Center(
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.all(25),
            // child: Text(
            //   'Hello Flutter',
            //   style: TextStyle(
            //     fontSize: 30,
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold),
            //   ),
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 64),
          ),
        ),
      ),
    );
  }
}