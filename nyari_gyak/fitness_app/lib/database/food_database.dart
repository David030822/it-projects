import 'package:fitness_app/models/app_settings.dart';
import 'package:fitness_app/models/food.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class FoodDatabase extends ChangeNotifier {
  static late Isar isar;

  /*

  S E T U P

  */

  // I N I T I A L I Z E - D A T A B A S E
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [FoodSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  /*

  C R U D X O P E R A T I O N S

  */

  // list of goals
  final List<Food> currentFoods = [];

  // C R E A T E - add new meal
  Future<void> addFood(String foodName, double calories) async {
    // create new food
    final newFood = Food(
      foodName, calories
    );

    // save to db
    await isar.writeTxn(() => isar.foods.put(newFood));

    // re-read from db
    readFoods();
  }

  // R E A D - read saved foods from db
  Future<void> readFoods() async {
    // fetch all foods from db
    List<Food> fetchedFoods = await isar.foods.where().findAll();

    // give to current foods
    currentFoods.clear();
    currentFoods.addAll(fetchedFoods);

    // update UI
    notifyListeners();
  }

  // U P D A T E - edit food name & calories
  Future<void> updateFood(int id, String newName, double newCalories) async {
    // find the specific food
    final food = await isar.foods.get(id);

    // update food name & calories
    if(food != null) {
      // update name & calories
      await isar.writeTxn(() async {
        food.name = newName;
        food.calories = newCalories;
        // save updated goal back to the db
        await isar.foods.put(food);
      });
    }

    // re-read from db
    readFoods();
  }

  // D E L E T E - delete food
  Future<void> deleteFood(int id) async {
    // perform the delete
    await isar.writeTxn(() async {
      await isar.foods.delete(id);
    });

    // re-read from db
    readFoods();
  }
}