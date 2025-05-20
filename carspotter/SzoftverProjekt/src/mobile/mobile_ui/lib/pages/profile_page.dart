import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_ui/components/my_drawer.dart';
import 'package:mobile_ui/models/user.dart';
import 'package:mobile_ui/services/api_service.dart';
import 'package:mobile_ui/services/auth_service.dart';
import 'dart:io';
import 'package:mobile_ui/pages/friends_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;
  File? _image;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }

      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }

      final user = await ApiService.getUserData(userId);

      setState(() {
        _user = user;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _phoneController.text = user.phoneNum;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _updateProfileImage(pickedFile);
    }
  }

  Future<void> _updateProfileImage(XFile pickedFile) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }

      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }

  
      await ApiService.updateProfileImage(userId, File(pickedFile.path)); 

      setState(() {
        _user!.profileImage = pickedFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () async {
              try {
                final token = await AuthService.getToken();
                if (token == null) {
                  throw Exception("User is not logged in");
                }

                final userId = await AuthService.getUserIdFromToken(token);
                if (userId == null) {
                  throw Exception("Invalid user ID");
                }

                // Call the API service to update the user data
                final result = await ApiService.updateUserData(
                  userId,
                  _firstNameController.text,
                  _lastNameController.text,
                  _phoneController.text,
                  _emailController.text,
                );

                if (result) {
                  setState(() {
                    _user!.firstName = _firstNameController.text;
                    _user!.lastName = _lastNameController.text;
                    _user!.phoneNum = _phoneController.text;
                    _user!.email = _emailController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully')),
                  );
                } else {
                  throw Exception("Failed to update profile");
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: const MyDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Center(
                    child: Text(
                      'Profile Page',
                      style: GoogleFonts.dmSerifText(
                        fontSize: 48,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    child: _image != null
                        ? ClipOval(
                            child: Image.file(
                              _image!,
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_user!.profileImage != null
                            ? ClipOval(
                                child: _user!.getDecodedProfileImage() != null
                                    ? Image.memory(
                                        _user!.getDecodedProfileImage()!,
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.person, size: 80),
                              )
                            : const Icon(Icons.person, size: 80)),
                  ),
                ),
                const SizedBox(height: 10),
                itemProfile('Name', '${_user!.firstName} ${_user!.lastName}', CupertinoIcons.person),
                const SizedBox(height: 10),
                itemProfile('Phone', _user!.phoneNum, CupertinoIcons.phone),
                const SizedBox(height: 10),
                itemProfile('Email', _user!.email, CupertinoIcons.mail),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _editProfile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: Theme.of(context).colorScheme.inversePrimary),
                      const SizedBox(width: 5),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.dmSerifText(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FriendsPage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Go to Friends Page ',
                        style: GoogleFonts.dmSerifText(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.inversePrimary),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.grey.withOpacity(.2),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Icon(iconData),
        ),
      ),
    );
  }
}