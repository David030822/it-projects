import 'package:fitness_app/components/my_text_field.dart';
import 'package:fitness_app/util/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // calories controller
  final _caloriesController = TextEditingController();
  String _calories = '';

  @override
  void initState() {
    super.initState();

    // Listen for changes to the text field
    _caloriesController.addListener(() {
      setState(() {
        if (_caloriesController.text.isNotEmpty){
          _calories = _caloriesController.text;
        }
      });
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Food Page',
              style: GoogleFonts.dmSerifText(
                fontSize: 48,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the row contents
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: _caloriesController,
                      hintText: 'Enter desired daily intake',
                      obscureText: false,
                    ),
                  ),
                  CustomButton(
                    color: Theme.of(context).colorScheme.tertiary,
                    textColor: Theme.of(context).colorScheme.outline,
                    onPressed: () {
                      setState(() {
                        _calories = _caloriesController.text;
                        _caloriesController.clear(); // Clear the text field
                      });
                    },
                    label: 'Confirm',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Calories to reach today: ',
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(
                  _calories == '' ? 'No goal set' : _calories,
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}