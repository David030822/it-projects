// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      appBar: AppBar(title: Text('Fitness App')),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  DrawerHeader(child: Icon(Icons.home)),
                  Icon(Icons.settings),
                ],
              ),
              Icon(Icons.logout),
            ],
          ),
        ),
      ),
    );
  }
}