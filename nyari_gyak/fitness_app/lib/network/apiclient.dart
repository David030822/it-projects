import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:fitness_app/network/responses/splash_response.dart';
import 'package:fitness_app/providers/user_data.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
class ApiClient {
  ApiClient({required this.client});

  final http.Client client;
  final String url = 'https://nygy2024.aprdev.net';

  // API nevek
  final String _splashPath = '/splash.php';
  final String _loginPath = '/login.php';
  final String _scalesPath = '/scales.php';
  final String _updatePasswordPath = '/change_password.php';
  final String _ingredientsPath = '/ingredients.php';
  final String _editIngredientPath = '/edit_ingredient.php';
  final String _restaurantsPath = '/restaurants.php';
  final String _setRestaurantPath = '/set_restaurant.php';
  final String _createIngredientPath = '/create_ingredient.php';
  final String _setScaleIngredientPath = '/set_scale_ingredient.php';
  final String _setScaleLevelPath = '/set_scale_level.php';
  final String _getShoppingListPath = '/get_shoppinglist.php';
  final String _editShoppingListPath = '/edit_shoppinglist.php';
  final String _checkShoppingListPath = '/check_shoppinglist.php';


  // Field names
  final String _udidField = 'udid';
  final String _uidField = 'uid';
  final String _scaleIdField = 'scaleid';
  final String _ingredientIdField = 'ingredientid';
  final String _restaurantIdField = 'restaurantid';
  final String _nameField = 'name';
  final String _emailField = 'email';
  final String _passwordField = 'password';
  final String _oldPasswordField = 'oldpassword';
  final String _newPasswordField = 'newpassword';
  final String _iconIdField = 'iconid';
  final String _newIconField = 'newicon';
  final String _newNameField = 'newname';
  final String _dailyLevelField = 'dailylevel';
  final String _commentField = 'comment';

  Future<Map<String, dynamic>> _post(
      {required String path, required Map<String, dynamic> arguments}) async {
    http.Response response =
        await client.post(Uri.parse(url + path), body: arguments);

    return jsonDecode(response.body)['response'];
  }

  Future<Map<String, dynamic>> _postMultipart(
      {required String path,
      required Map<String, String> arguments,
      required List<http.MultipartFile> files}) async {
    final String urla = '$url$path';
    final http.MultipartRequest multipartRequest =
        http.MultipartRequest('POST', Uri.parse(urla))
          ..fields.addAll(arguments)
          ..files.addAll(files);
    final http.StreamedResponse response = await multipartRequest.send();
    final String responseJsonString =
        utf8.decode(await response.stream.toBytes());
    return jsonDecode(responseJsonString)['response'];
  }

  Future<List<http.MultipartFile>> _buildImageFiles(
      {required String key,
      required List<String> path,
      required MediaType contentType}) async {
    final List<http.MultipartFile> files = [];
    for (int i = 0; i < path.length; i++) {
      if (File.fromUri(Uri.parse(path[i])).existsSync()) {
        files.add(await http.MultipartFile.fromPath(
          key, //+ i.toString(),
          Uri.parse(path[i]).toFilePath(),
          contentType: contentType,
          filename: path[i].substring(path[i].lastIndexOf('/') + 1),
        ));
      }
    }
    return files;
  }

  // U S E R

  Future<SplashResponse> callSplash() async {
    return SplashResponse.fromJson(
        await _post(path: _splashPath, arguments: <String, String>{
      _udidField: UserData.udid,
    }));
  }

  Future<SplashResponse> callLogin({required String email, required String password}) async {
    return SplashResponse.fromJson(
        await _post(path: _loginPath, arguments: <String, String>{
      _udidField: UserData.udid,
      _emailField: email,
      // we convert password to md5 for security reasons
      _passwordField: md5.convert(utf8.encode(password)).toString(),
    }));
  }
  
}

Future<void> showCustomAlertDialog(
    BuildContext context, String message, String title) async {
  await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            message,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w200),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
