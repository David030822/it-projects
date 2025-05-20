class SoldCar {
  final int id;
  final int cardId;
  final DateTime soldDate;
  final double soldPrice;

  SoldCar({
    required this.id,
    required this.cardId,
    required this.soldDate,
    required this.soldPrice,
  });

  factory SoldCar.fromJson(Map<String, dynamic> json) {
    return SoldCar(
      id: json['id'],
      cardId: json['card_id'],
      soldDate: DateTime.parse(json['sold_date']),
      soldPrice: json['sold_price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'sold_date': soldDate.toIso8601String(),
      'sold_price': soldPrice,
    };
  }
}
