class WeeklySales {
  final String day;
  final int sales;

  WeeklySales({required this.day, required this.sales});

  // A factory method a JSON deszerializálásához
  factory WeeklySales.fromJson(Map<String, dynamic> json) {
    return WeeklySales(
      day: json['day'],
      sales: json['sold_count'],
    );
  }
}
