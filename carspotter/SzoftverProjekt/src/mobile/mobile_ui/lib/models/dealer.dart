import 'package:mobile_ui/models/car.dart';

class Dealer {
  final int id;
  final String name;
  final String location;
  final int activeSince;
  final String imagePath;
  final List<Car> cars;
  bool isFavorited;

  Dealer({
    required this.id,
    required this.name,
    required this.location,
    required this.activeSince,
    required this.imagePath,
    required this.cars,
    required this.isFavorited,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    var carsJson = json['cars'];
    List<Car> carsList = carsJson != null
        ? List<Car>.from(carsJson.map((carJson) => Car.fromJson(carJson)))
        : [];

    return Dealer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      activeSince: int.tryParse(json['active_since'].toString()) ?? 0,
      imagePath: json['image_url'] ?? '',
      cars: carsList,
      isFavorited: json['is_favorited'] ?? false,
    );
  }
}
