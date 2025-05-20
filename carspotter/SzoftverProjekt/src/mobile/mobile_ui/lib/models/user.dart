import 'dart:convert';
import 'dart:typed_data';

class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String phoneNum;
  String? profileImage; // Store the base64 string

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNum,
    this.profileImage,
  });

  // Convert from JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNum: json['phone'] ?? '',
      profileImage: json['profile_image'] ?? null, // Parse base64 string
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phoneNum,
    };

    if (profileImage != null) {
      map['profile_image'] = profileImage!; // Include base64 string
    }

    return map;
  }

  Uint8List? getDecodedProfileImage() {
    if (profileImage != null) {
      try {
        // If the base64 string contains the 'data:image/jpeg;base64,' prefix, remove it
        String base64String = profileImage!;
        if (base64String.startsWith('data:image')) {
          base64String = base64String.split(',').last;  // Remove the prefix
        }

        // Decode the base64 string into bytes
        Uint8List decodedBytes = base64Decode(base64String);

        // Return the decoded byte data
        return decodedBytes;
      } catch (e) {
        // Print error if there's an issue with decoding
        print("Error decoding profile image: $e");
        return null;
      }
    }
    return null;
  }
}
