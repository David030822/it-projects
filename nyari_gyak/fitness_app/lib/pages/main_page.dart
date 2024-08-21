import 'package:fitness_app/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // heading
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'Fitness App',
              style: GoogleFonts.dmSerifText(
                fontSize: 36,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          )
        ],
      ),
    );
  }
}