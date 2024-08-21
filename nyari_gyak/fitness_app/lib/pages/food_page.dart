import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Food Page',
          style: GoogleFonts.dmSerifText(
            fontSize: 48,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}