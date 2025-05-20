class MonthlySales {
  final String month;
  final int sales;

  MonthlySales({required this.month, required this.sales});

  // A factory method a JSON deszerializálásához
  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      month: json['month'],
      sales: json['sold_count'],
    );
  }
}
