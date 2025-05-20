import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/custom_button.dart';
import 'package:mobile_ui/components/dealer_tile.dart';
import 'package:mobile_ui/models/car.dart';
import 'package:mobile_ui/models/user.dart';
import 'package:mobile_ui/models/dealer.dart';
import 'package:mobile_ui/pages/dealer_cars_page.dart';
import 'dart:io';
import 'package:mobile_ui/services/api_service.dart';
import 'package:mobile_ui/services/auth_service.dart';

class FriendPage extends StatefulWidget {
  final User user;
  const FriendPage({super.key, required this.user});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  bool _isFollowing = false;
  bool _isLoading = true;
  File? _image;
  List<Dealer> favoriteDealers = [];
  List<Dealer> myFavoriteDealers = [];

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  void loadFavorites() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }
      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }
      final dealers = await ApiService.getFavoriteDealers(widget.user.id);
      final myFavDealers = await ApiService.getFavoriteDealers(userId);
      setState(() {
        favoriteDealers = dealers;
        myFavoriteDealers = myFavDealers;
      });

      for (var favorite in favoriteDealers) {
        for (var myFavorite in myFavoriteDealers) {
          if (favorite.id == myFavorite.id) {
            favorite.isFavorited = true; 
          }
        }
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No favorite dealers yet.")));
    }
  }

  void _checkFollowingStatus() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }
      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }

      bool isFollowing = await ApiService.isFollowing(userId, widget.user.id);
      setState(() {
        _isFollowing = isFollowing;
        _isLoading = false;
      });
      if (_isFollowing) {
        loadFavorites();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking following status: $e')),
      );
    }
  }

  void _followUser() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }
      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }

      await ApiService.addFollowing(userId, widget.user.id);
      setState(() {
        _isFollowing = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User followed successfully!')),
      );
      loadFavorites();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _unfollowUser() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }
      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }

      await ApiService.deleteFollowing(userId, widget.user.id);
      setState(() {
        _isFollowing = false;
        favoriteDealers = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unfollowed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  'User Profile Page',
                  style: GoogleFonts.dmSerifText(
                    fontSize: 36,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            CircleAvatar(
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
                  : (widget.user.profileImage != null
                      ? ClipOval(
                          child: widget.user.getDecodedProfileImage() != null
                              ? Image.memory(
                                  widget.user.getDecodedProfileImage()!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.person, size: 80),
                        )
                      : const Icon(Icons.person, size: 80)),
            ),
            const SizedBox(height: 10),
            if (!_isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CustomButton(
                      color: Theme.of(context).colorScheme.tertiary,
                      textColor: Theme.of(context).colorScheme.outline,
                      onPressed: _isFollowing ? _unfollowUser : _followUser,
                      label: _isFollowing ? 'Unfollow' : '+ Follow',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            itemProfile('Name', '${widget.user.firstName} ${widget.user.lastName}', CupertinoIcons.person),
            itemProfile('Phone', widget.user.phoneNum, CupertinoIcons.phone),
            itemProfile('Email', widget.user.email, CupertinoIcons.mail),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  '${widget.user.firstName}\'s Favourite Dealers',
                  style: GoogleFonts.dmSerifText(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ),
            if (favoriteDealers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favoriteDealers.length,
                itemBuilder: (context, index) {
                  final dealer = favoriteDealers[index];
                  return FutureBuilder<List<Car>>(
                    future: ApiService.getCarsByDealerId(dealer.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load cars for ${dealer.name}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final cars = snapshot.data!;
                        return DealerTile(
                          dealer: dealer,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerCarsPage(
                                  cars: cars,
                                  name: dealer.name,
                                  soldCars: [],
                                  dealerId: dealer.id,
                                ),
                              ),
                            );
                          },
                          onButtonTap: () {
                            setState(() {
                              dealer.isFavorited = !dealer.isFavorited;
                            });
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
          ],
        ),
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
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
      ),
    );
  }
}