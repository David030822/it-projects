// ignore_for_file: prefer_const_constructors

import 'package:fitness_app/responsive/constants.dart';
import 'package:fitness_app/util/my_box.dart';
import 'package:fitness_app/util/my_tile.dart';
import 'package:flutter/material.dart';

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar,
      backgroundColor: myDefaultBackgroundColor,
      drawer: myDrawer,
      body: Column(
        children: [
          // 4 boxes on the top
          AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: double.infinity,
              child: GridView.builder(
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return MyBox();
                }
              ),
            ),
          ),

          // tiles below
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return MyTile();
              },
            ),
          ),
        ],
      ),
    );
  }
}