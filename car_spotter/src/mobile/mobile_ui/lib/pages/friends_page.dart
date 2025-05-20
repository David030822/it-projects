import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/custom_button.dart';
import 'package:mobile_ui/components/friend_tile.dart';
import 'package:mobile_ui/components/my_text_field.dart';
import 'package:mobile_ui/models/user.dart';
import 'package:mobile_ui/services/api_service.dart';
import 'package:mobile_ui/services/auth_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isUsersLoading = true;
  List<User> _usersFound = [];
  List<User> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    try {
      setState(() {
        _isUsersLoading = true;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }
      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }

      _friendsList = await ApiService.getFollowing(userId); 

      setState(() {
        _isUsersLoading = false;
      });
    } catch (e) {
      setState(() {
        _isUsersLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: ${e.toString()}')),
      );
    }
  }

  // Keresési funkció
  void _searchUsers() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search query.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _usersFound = [];
    });

    try {
      _usersFound = await ApiService.searchUsers(query);

      setState(() {});

      if (_usersFound.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No users found with the given name.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: _searchController,
                    hintText: 'Enter a username',
                    obscureText: false,
                  ),
                ),
                const SizedBox(width: 10),
                CustomButton(
                  color: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).colorScheme.outline,
                  onPressed: _searchUsers,
                  label: 'Search',
                ),
              ],
            ),
          ),

          if (_isLoading)
            const CircularProgressIndicator()
          else if (_usersFound.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _usersFound.length,
                itemBuilder: (context, index) {
                  final user = _usersFound[index];
                  return FriendTile(friend: user);
                },
              ),
            )
          else if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No users found with name "${_searchController.text}".',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

          const Divider(height: 1, thickness: 1),


          if (_isUsersLoading)
            const CircularProgressIndicator()
          else
           Padding(
             padding: const EdgeInsets.only(top: 10, bottom: 10),
             child: Text(
                'Your friends will appear here',
                style: GoogleFonts.dmSerifText(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
           ),
            Expanded(
              child: ListView.builder(
                itemCount: _friendsList.length,
                itemBuilder: (context, index) {
                  final friend = _friendsList[index];
                  return FriendTile(friend: friend);
                },
              ),
            ),
        ],
      ),
    );
  }
}
