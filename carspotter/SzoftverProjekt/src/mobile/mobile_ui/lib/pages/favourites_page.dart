import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/dealer_tile.dart';
import 'package:mobile_ui/models/dealer.dart';
import 'package:mobile_ui/models/car.dart';
import 'package:mobile_ui/services/auth_service.dart';
import 'package:mobile_ui/services/api_service.dart';
import 'package:mobile_ui/pages/dealer_cars_page.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<Dealer> favoriteDealers = []; // List to store the favorite dealers

  @override
  void initState() {
    super.initState();
    loadFavorites();
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
      final dealers = await ApiService.getFavoriteDealers(userId);
      setState(() {
        favoriteDealers = dealers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Don't have any favourite dealer yet")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Favourite dealers',
                style: GoogleFonts.dmSerifText(
                  fontSize: 36,
                  color: Theme.of(context).colorScheme.inversePrimary,
                )),
            Expanded(
              child: ListView.builder(
                itemCount: favoriteDealers.length,
                itemBuilder: (context, index) {
                  final dealer = favoriteDealers[index];
                  dealer.isFavorited = true;

                  return FutureBuilder<List<List<Car>>>(
                    future: Future.wait([
                      ApiService.getCarsByDealerId(
                          dealer.id), // Ez Future<List<Car>>
                      ApiService.getSoldCarsByDealerId(
                          dealer.id), // Ez Future<List<Car>>
                    ]),
                    
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load cars for ${dealer.name} - $snapshot',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final cars = snapshot.data![
                            0]; 
                        final soldCars = snapshot.data![
                            1]; 
                  
                        return DealerTile(
                          dealer: dealer,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerCarsPage(
                                  cars: cars,
                                  name: dealer.name,
                                  dealerId: dealer.id,
                                  soldCars: soldCars,
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
            ),
          ],
        ),
      ),
    );
  }
}