class OwnCar {
  int? id; // Optional ID field
  String name;
  String fuelType;
  int kilometers;
  int year;
  double price;
  String chassis;
  String gearbox;
  int engineSize;
  int horsepower;
  double buyPrice;
  double spent;
  double sellPrice;
  String imagePath;

  OwnCar({
    this.id, // Optional parameter
    required this.name,
    required this.fuelType,
    required this.kilometers,
    required this.year,
    this.price = 0,
    required this.chassis,
    required this.gearbox,
    required this.engineSize,
    required this.horsepower,
    required this.buyPrice,
    this.spent = 0,
    this.sellPrice = 0,
    this.imagePath = '',
  });

  factory OwnCar.fromJson(Map<String, dynamic> json) {
    return OwnCar(
      id: json['id'] as int?, // Map the ID if available
      name: json['model'] as String,
      kilometers: json['km'] as int,
      year: json['year'] as int,
      fuelType: json['combustible'] as String,
      gearbox: json['gearbox'] as String,
      chassis: json['body_type'] as String,
      engineSize: json['engine_size'] as int,
      horsepower: json['power'] as int,
      price: (json['selling_for'] as num).toDouble(),
      buyPrice: (json['bought_for'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (json['sold_for'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent_on'] as num?)?.toDouble() ?? 0.0,
      imagePath: json['img_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // Include ID only if it's set
      'model': name,
      'km': kilometers,
      'year': year,
      'combustible': fuelType,
      'gearbox': gearbox,
      'body_type': chassis,
      'engine_size': engineSize,
      'power': horsepower,
      'selling_for': price,
      'bought_for': buyPrice,
      'sold_for': sellPrice,
      'spent_on': spent,
      'img_url': imagePath,
    };
  }
}