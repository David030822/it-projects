class Car {
  final String name;
  final String fuelType;
  final int kilometers;
  final int year;
  final double price;
  final String chassis;
  final String gearbox;
  final int engineSize;
  final int horsepower;
  final String imagePath;

  Car({
    required this.name,
    required this.fuelType,
    required this.kilometers,
    required this.year,
    required this.price,
    required this.chassis,
    required this.gearbox,
    required this.engineSize,
    required this.horsepower,
    required this.imagePath,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      name: json['model'] ?? '',
      fuelType: json['combustible'] ?? '',
      kilometers: json['km'] ?? 0,
      year: json['year'] ?? 0,
      price: json['price'] ?? 0.0,
      chassis: json['body_type'] ?? '',
      gearbox: json['gearbox'] ?? '',
      engineSize: json['cylinder_capacity'] ?? 0.0,
      horsepower: json['power'] ?? 0,
      imagePath: json['img_url'] ?? 'https://via.placeholder.com/150',
    );
  }
}