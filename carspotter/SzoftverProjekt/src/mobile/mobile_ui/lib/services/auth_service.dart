import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _key = 'access_token';

  // Get the token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // Get userId from the token
  static Future<int?> getUserIdFromToken(String? token) async {
    if (token == null || token.isEmpty) {
      return null; 
    }

    // Decode the JWT token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Extract the userId from the payload
    int? userId = decodedToken['sub'];

    return userId;
  }

  // Check if the user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  // Remove token (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
