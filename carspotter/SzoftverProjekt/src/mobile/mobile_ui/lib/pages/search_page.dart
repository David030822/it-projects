import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/custom_button.dart';
import 'package:mobile_ui/components/my_text_field.dart';
import 'package:mobile_ui/components/dealer_tile.dart';
import 'package:mobile_ui/models/car.dart';
import 'package:mobile_ui/models/dealer.dart';
import 'package:mobile_ui/pages/dealer_cars_page.dart';
import 'package:mobile_ui/services/api_service.dart';
import 'package:mobile_ui/services/auth_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Car> _dealerCars = [];
  List<Car> _dealerSoldCars = [];
  Dealer? _dealer;
  List<Dealer> favoriteDealers = [];

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
          SnackBar(content: Text("Failed to load favorites: $e")));
    }
  }

  void _searchDealerCars() async {
    setState(() {
      _isLoading = true;
      _dealerCars = [];
      _dealerSoldCars = [];
      _dealer = null;
      loadFavorites();
    });

    try {
      final response =
          await ApiService.getCarsByDealer(_searchController.text.trim());

      final dealerJson = response['dealer'];
      final carsJson = response['cars'];

      _dealer = Dealer.fromJson(dealerJson);

      if (_dealer != null) {
        for (var favorite in favoriteDealers) {
          if (favorite.id == _dealer!.id) {
            _dealer!.isFavorited = true;
            break;
          }
        }
      }
      final dealerSoldCars = await ApiService.getSoldCarsByDealerId(_dealer!.id);

      final dealerCars = carsJson.map<Car>((json) => Car.fromJson(json)).toList();

    setState(() {
      _dealerCars = dealerCars;
      _dealerSoldCars = dealerSoldCars;
    });

      if (_dealerCars.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cars found for the dealer.')),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  children: [
                    Text('Search for registered dealers\nand see their cars',
                      style: GoogleFonts.dmSerifText(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                            child: MyTextField(
                              controller: _searchController,
                              hintText: 'Enter a dealer name',
                              obscureText: false,
                            ),
                          ),
                        ),
                        CustomButton(
                          color: Theme.of(context).colorScheme.tertiary,
                          textColor: Theme.of(context).colorScheme.outline,
                          onPressed: _searchDealerCars,
                          label: 'Search',
                        ),
                      ],
                    ),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (!_isLoading &&
                        _dealerCars.isEmpty &&
                        _searchController.text.isNotEmpty)
                      Text(
                        'No cars found for "${_searchController.text}".',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _dealer != null ? 1 : 0,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    Dealer dealer = _dealer!;

                    return DealerTile(
                      dealer: dealer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DealerCarsPage(
                              cars: _dealerCars,
                              soldCars: _dealerSoldCars,
                              name: dealer.name,
                              dealerId: dealer.id,
                            ),
                          ),
                        );
                      },
                      onButtonTap: () {
                        setState(() {
                          dealer.isFavorited = !dealer.isFavorited;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(dealer.isFavorited
                                ? '${dealer.name} added to favorites'
                                : '${dealer.name} removed from favorites'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
