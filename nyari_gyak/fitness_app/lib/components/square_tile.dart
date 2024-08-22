import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final double height;
  const SquareTile({super.key, required this.imagePath, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Image.asset(imagePath, height: height),
    );
  }
}