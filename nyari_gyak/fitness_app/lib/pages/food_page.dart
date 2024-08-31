import 'package:fitness_app/components/food_tile.dart';
import 'package:fitness_app/components/my_text_field.dart';
import 'package:fitness_app/database/food_database.dart';
import 'package:fitness_app/models/food.dart';
import 'package:fitness_app/util/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // food name & calories controllers
  final _foodNameController = TextEditingController();
  final _foodCaloriesController = TextEditingController();

  // calories controller
  final _caloriesController = TextEditingController();
  String _calories = '';

  String _totalIntake = '';

  @override
  void initState() {
    // read existing foods on app startup
    Provider.of<FoodDatabase>(context, listen: false).readFoods();

    // Listen for changes to the text field
    _caloriesController.addListener(() {
      setState(() {
        if (_caloriesController.text.isNotEmpty){
          _calories = _caloriesController.text;
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _foodCaloriesController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  // create new food
  void createNewFood() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          children: [
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                hintText: 'Name of the new meal',
              ),
            ),
            TextField(
              controller: _foodCaloriesController,
              decoration: const InputDecoration(
                hintText: 'Number of calories',
              ),
            ),
          ],
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get the new food name & calories
              String newFoodName = _foodNameController.text;
              double newFoodCalories = double.parse(_foodCaloriesController.text);

              // save to db
              context.read<FoodDatabase>().addFood(newFoodName, newFoodCalories);

              // pop box
              Navigator.pop(context);

              // clear controllers
              _foodNameController.clear();
              _foodCaloriesController.clear();
            },
            child: const Text('Save'),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controllers
              _foodNameController.clear();
              _foodCaloriesController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // edit food box
  void editFoodBox(Food food) {
    // set the controller's text to the food's current name & calories
    _foodNameController.text = food.name;
    _foodCaloriesController.text = food.calories.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          children: [
            TextField(
              controller: _foodNameController,
            ),
            TextField(
              controller: _foodCaloriesController,
            ),
          ],
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get the new food name
              String newFoodName = _foodNameController.text;
              double newFoodCalories = double.parse(_foodCaloriesController.text);

              // save to db
              context.read<FoodDatabase>().updateFood(food.id, newFoodName, newFoodCalories);

              // pop box
              Navigator.pop(context);

              // clear controllers
              _foodNameController.clear();
              _foodCaloriesController.clear();
            },
            child: const Text('Save'),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controllers
              _foodNameController.clear();
              _foodCaloriesController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      )
    );
  }

  // delete food box
  void deleteFoodBox(Food food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete?'),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              // delete from db
              context.read<FoodDatabase>().deleteFood(food.id);

              // pop box
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: createNewFood,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          Center(
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

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total intake until now: ',
                      style: GoogleFonts.dmSerifText(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Text(
                      _totalIntake == '' ? 'Nothing yet' : _totalIntake,
                      style: GoogleFonts.dmSerifText(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  'My meals today:',
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),

          // food list
          _buildFoodList(),
        ],
      ),
    );
  }

  // build food list
  Widget _buildFoodList() {
    // food db
    final foodDatabase = context.watch<FoodDatabase>();

    // current foods
    List<Food> currentFoods = foodDatabase.currentFoods;

    // return list of foods UI
    return ListView.builder(
      itemCount: currentFoods.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual food
        final food = currentFoods[index];

        // return goal tile UI
        return FoodTile(
          food: food,
          editFood: (context) => editFoodBox(food),
          deleteFood: (context) => deleteFoodBox(food),
        );
      } 
    );
  }
}