import 'dart:convert';
import 'dart:io';
import 'package:mobile_ui/models/monthly_sales.dart';
import 'package:mobile_ui/models/own_car.dart';
import 'package:mobile_ui/models/weekly_sales.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_ui/services/auth_service.dart';
import 'package:mobile_ui/models/dealer.dart';
import 'package:mobile_ui/models/car.dart';
import 'package:mobile_ui/models/user.dart';

// ngrok http http://localhost:8000
// uvicorn api.main:app --host 0.0.0.0 --port 8000

class ApiService {
  static const String baseUrl = "https://988f-212-93-150-81.ngrok-free.app";
  // Dealer API hívás
  static Future<Map<String, dynamic>> getCarsByDealer(String dealerName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dealer/$dealerName/cars'),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load cars: ${response.body}');
    }
  }

  static Future<List<Car>> getCarsByDealerId(int dealerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dealer_id/$dealerId/cars'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars: ${response.body}');
    }
  }

  static Future<List<OwnCar>> getOwnCarsByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/owncars'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> ownCarsJson = jsonResponse['own_cars'];
      return ownCarsJson.map((json) => OwnCar.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load own cars: ${response.body}');
    }
  }

  static Future<int?> getCarIdFromResponse(
      Map<String, dynamic> response) async {
    if (response.isEmpty) {
      return null; // Return null if the response is empty
    }

    // Extract the car ID from the response payload
    int? carId = response['id'];

    return carId;
  }

  // Regisztrációs API hívás
  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? dealerInventoryName,
    File? profileImage,
  }) async {
    var uri = Uri.parse('$baseUrl/register');

    var request = http.MultipartRequest('POST', uri)
      ..fields['first_name'] = firstName
      ..fields['last_name'] = lastName
      ..fields['email'] = email
      ..fields['phone'] = phone
      ..fields['password'] = password;

    if (dealerInventoryName != null && dealerInventoryName.isNotEmpty) {
      request.fields['dealer_inventory_name'] = dealerInventoryName;
    }

    if (profileImage != null) {
      // A fájl típusának kezelése (például jpeg, png stb.)
      var stream = http.ByteStream(profileImage.openRead());
      var length = await profileImage.length();

      // Feltöltési fájl létrehozása
      var multipartFile = http.MultipartFile(
        'profile_image',
        stream,
        length,
        filename: profileImage.path.split('/').last,
        contentType:
            MediaType('image', 'jpeg'), // Ellenőrizd a megfelelő fájltípust!
      );
      request.files.add(multipartFile);
    }

    // Az API hívás elküldése
    var response = await request.send();

    // Ha a válasz sikeres (200 OK)
    if (response.statusCode == 200) {
      // Válasz JSON kódolása
      var responseData = await response.stream.bytesToString();
      return jsonDecode(
          responseData); // Feltételezzük, hogy a backend JSON választ küld
    } else {
      throw Exception("Failed to register user: ${response.statusCode}");
    }
  }

  static Future<bool> loginUser(String email, String password) async {
    final String url = "$baseUrl/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AuthService.saveToken(data['access_token']);
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['detail'] ?? "Invalid credentials");
      }
    } catch (e) {
      throw Exception("Error during login: $e");
    }
  }

  // Add or remove a dealer from favorites
  static Future<void> toggleFavorite(
      int userId, int dealerId, bool isFavorited) async {
    final String url = "$baseUrl/user/$userId/favorite/$dealerId";

    final response = !isFavorited
        ? await http.delete(Uri.parse(url))
        : await http.post(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite status');
    }
  }

  // Get favorite dealers for a user by their userId
  static Future<List<Dealer>> getFavoriteDealers(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/favorites');
    final response = await http
        .get(url, headers: {"Authorization": "Bearer your_token_here"});

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> dealersJson = jsonResponse['favorites'];
      return dealersJson.map((json) => Dealer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorite dealers');
    }
  }

  static Future<List<OwnCar>> getOwnCars(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId/owncars'));

    if (response.statusCode == 200) {
      final List<dynamic> carList = jsonDecode(response.body);
      return carList.map((json) => OwnCar.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars: ${response.body}');
    }
  }

  static Future<User> getUserData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> user_data = jsonDecode(response.body);
      return User.fromJson(user_data);
    } else {
      throw Exception('Failed to load user data: ${response.body}');
    }
  }

  static Future<bool> updateUserData(
    int userId,
    String firstName,
    String lastName,
    String phone,
    String email,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Successfully updated
      } else {
        return false; // Failed to update
      }
    } catch (e) {
      print("Error updating user: $e");
      return false;
    }
  }

  static Future<void> updateProfileImage(int userId, File profileImage) async {
    try {
      var uri = Uri.parse('$baseUrl/user-image/$userId');
      var request = http.MultipartRequest('PUT', uri);

      // Add the image file to the request
      var stream = http.ByteStream(profileImage.openRead());
      var length = await profileImage.length();
      var multipartFile = http.MultipartFile(
        'profile_image',
        stream,
        length,
        filename: profileImage.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Failed to upload image');
    }
  }

  static Future<void> addNewOwnCar(int userId, OwnCar newCar) async {
    final url = Uri.parse('$baseUrl/user/$userId/newcar');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }

    final newCarRequest = {
      'model': newCar.name,
      'km': newCar.kilometers,
      'year': newCar.year,
      'combustible': newCar.fuelType,
      'gearbox': newCar.gearbox,
      'body_type': newCar.chassis,
      'engine_size': newCar.engineSize,
      'power': newCar.horsepower,
      'selling_for': newCar.price,
      'bought_for': newCar.buyPrice,
      'sold_for': newCar.sellPrice,
      'spent_on': newCar.spent,
      'img_url': newCar.imagePath,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(newCarRequest),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add car: ${response.body}');
    }
  }

  static Future<void> editOwnCar(
      int userId, int carId, OwnCar updatedCar) async {
    final url = Uri.parse('$baseUrl/user/$userId/owncar/$carId');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }

    final updatedCarRequest = {
      'model': updatedCar.name,
      'km': updatedCar.kilometers,
      'year': updatedCar.year,
      'combustible': updatedCar.fuelType,
      'gearbox': updatedCar.gearbox,
      'body_type': updatedCar.chassis,
      'engine_size': updatedCar.engineSize,
      'power': updatedCar.horsepower,
      'selling_for': updatedCar.price,
      'bought_for': updatedCar.buyPrice,
      'sold_for': updatedCar.sellPrice,
      'spent_on': updatedCar.spent,
      'img_url': updatedCar.imagePath,
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedCarRequest),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit car: ${response.body}');
    }
  }

  static Future<void> deleteOwnCar(int userId, int carId) async {
    final url = Uri.parse('$baseUrl/user/$userId/owncar/$carId');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete car: ${response.body}');
    }
  }

  static Future<List<User>> searchUsers(String query) async {
    final url = Uri.parse('$baseUrl/search_users?query=$query');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users: ${response.statusCode}');
    }
  }

  static Future<void> addFollowing(int userId, int followingId) async {
    final url = Uri.parse('$baseUrl/user/$userId/following/$followingId');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to add following: ${response.statusCode}');
    }
  }

  static Future<List<User>> getFollowing(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/following');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch following users: ${response.statusCode}');
    }
  }

  static Future<void> deleteFollowing(int userId, int followingId) async {
    final url = Uri.parse('$baseUrl/user/$userId/following/$followingId');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not authenticated");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete following: ${response.statusCode}');
    }
  }

  static Future<bool> isFollowing(int userId, int targetUserId) async {
    final url = Uri.parse('$baseUrl/following/$userId/$targetUserId');
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("User is not logged in");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return response.body == 'true';
    } else {
      throw Exception(
          'Failed to check following status: ${response.statusCode}');
    }
  }

  static Future<List<Car>> getSoldCarsByDealerId(int dealerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sold_cars/$dealerId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars: ${response.body}');
    }
  }

  static Future<List<OwnCar>> getOwnSoldCars(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/sold_owncars/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> carList = jsonDecode(response.body);
      return carList.map((json) => OwnCar.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars: ${response.body}');
    }
  }

  static Future<void> sellOwnCar(int userId, int ownCarId, double sellFor) async {
    final url = Uri.parse('$baseUrl/sell_owncar/$userId');
    final body = json.encode({
      'own_car_id': ownCarId,
      'sell_for': sellFor,
    });

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Car sold successfully.');
    } else {
      throw Exception('Failed to sell car: ${response.body}');
    }
  }

  static Future<Map<String, List<dynamic>>> fetchSalesData(int userId) async {
    final url = Uri.parse('$baseUrl/statistics/$userId');

    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception("User is not logged in");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final weeklySales = (data['weekly_sales'] as List<dynamic>)
          .map((item) => WeeklySales.fromJson(item))
          .toList();

      final monthlySales = (data['monthly_sales'] as List<dynamic>)
          .map((item) => MonthlySales.fromJson(item))
          .toList();

      return {
        'weekly_sales': weeklySales,
        'monthly_sales': monthlySales,
      };
    } else {
      throw Exception('Failed to load sales data');
    }
  }

  static Future<Map<String, List<dynamic>>> fetchSalesDataForDealer(int dealerId) async {
    final url = Uri.parse('$baseUrl/dealer_statistics/$dealerId');

    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception("User is not logged in");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final weeklySales = (data['weekly_sales'] as List<dynamic>)
          .map((item) => WeeklySales.fromJson(item))
          .toList();

      final monthlySales = (data['monthly_sales'] as List<dynamic>)
          .map((item) => MonthlySales.fromJson(item))
          .toList();

      return {
        'weekly_sales': weeklySales,
        'monthly_sales': monthlySales,
      };
    } else {
      throw Exception('Failed to load sales data');
    }
  }
}