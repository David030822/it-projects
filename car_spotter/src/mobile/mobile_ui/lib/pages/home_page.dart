import 'package:flutter/material.dart';
import 'package:mobile_ui/components/my_bottom_navbar.dart';
import 'package:mobile_ui/components/my_drawer.dart';
import 'package:mobile_ui/pages/favourites_page.dart';
import 'package:mobile_ui/pages/main_page.dart';
import 'package:mobile_ui/pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // this selected index is to control the bottom nav bar
  int _selectedIndex = 0;

  // this method will update our selected index
  // when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // pages to display
  final List<Widget> _pages = [
    // main page
    const MainPage(),

    // search page
    const SearchPage(),

    // favourites page
    const FavouritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, 
      ),
      drawer: const MyDrawer(),
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: _pages[_selectedIndex],
    );
  }
}