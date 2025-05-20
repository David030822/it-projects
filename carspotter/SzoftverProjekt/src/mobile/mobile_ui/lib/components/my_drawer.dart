import 'package:flutter/material.dart';
import 'package:mobile_ui/components/drawer_tile.dart';
import 'package:mobile_ui/pages/about_page.dart';
import 'package:mobile_ui/pages/event_page.dart';
import 'package:mobile_ui/pages/home_page.dart';
import 'package:mobile_ui/pages/login_page.dart';
import 'package:mobile_ui/pages/profile_page.dart';
import 'package:mobile_ui/pages/settings_page.dart';
import 'package:mobile_ui/pages/statistics_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // header
                DrawerHeader(
                  child: Icon(Icons.directions_car),
                ),

                // home tile
                DrawerTile(
                  title: 'H O M E',
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),

                // profile tile
                DrawerTile(
                  title: 'P R O F I L E',
                  leading: const Icon(Icons.person),
                  onTap: () {
                    // Itt most statikus adatokat jelenítünk meg, nem kérjük le az adatokat
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(), // Ne adjunk át user adatot
                      ),
                    );
                  },
                ),

                DrawerTile(
                  title: 'S T A T I S T I C S',
                  leading: const Icon(Icons.show_chart),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsPage(isUser: true, dealerId: 0),
                      ),
                    );
                  },
                ),

                // events tile - heatmap for sold and bought cars
                DrawerTile(
                  title: 'E V E N T S',
                  leading: const Icon(Icons.calendar_month),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventsPage(),
                      ),
                    );
                  },
                ),

                // settings tile
                DrawerTile(
                  title: 'S E T T I N G S',
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),

                // about tile
                DrawerTile(
                  title: 'A B O U T',
                  leading: const Icon(Icons.info),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),
              ],
            ),

            // logout tile
            DrawerTile(
              title: 'L O G O U T',
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
