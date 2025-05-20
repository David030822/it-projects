import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/models/bar_data.dart';
import 'package:mobile_ui/models/monthly_sales.dart';
import 'package:mobile_ui/models/pie_data.dart';
import 'package:mobile_ui/models/weekly_sales.dart';
import 'package:mobile_ui/services/auth_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mobile_ui/services/api_service.dart';

class StatisticsPage extends StatefulWidget {
  final bool isUser;
  final int dealerId;

  const StatisticsPage(
      {super.key, required this.isUser, required this.dealerId});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<BarData> weeklySalesData = [];
  List<PieData> monthlySalesData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isUser) {
      fetchData();
    } else {
      fetchDataForDealer();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchData() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User is not logged in");
      }
      final userId = await AuthService.getUserIdFromToken(token);
      if (userId == null) {
        throw Exception("Invalid user ID");
      }
      final salesData = await ApiService.fetchSalesData(userId);
      setState(() {
        weeklySalesData = (salesData['weekly_sales'] as List<WeeklySales>)
            .map((item) => BarData(item.day, item.sales))
            .toList();

        monthlySalesData = (salesData['monthly_sales'] as List<MonthlySales>)
            .map((item) => PieData(item.month, item.sales))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchDataForDealer() async {
    try {
      final salesData = await ApiService.fetchSalesDataForDealer(widget.dealerId);
      setState(() {
        weeklySalesData = (salesData['weekly_sales'] as List<WeeklySales>)
            .map((item) => BarData(item.day, item.sales))
            .toList();

        monthlySalesData = (salesData['monthly_sales'] as List<MonthlySales>)
            .map((item) => PieData(item.month, item.sales))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Car Sales Statistics'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Car Sales Statistics',
          style: GoogleFonts.dmSerifText(fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Weekly Sales',
                    style: GoogleFonts.dmSerifText(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
                if (weeklySalesData.isNotEmpty)
                  Container(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <ChartSeries<BarData, String>>[
                        ColumnSeries<BarData, String>(
                          dataSource: weeklySalesData,
                          xValueMapper: (BarData data, _) => data.xData,
                          yValueMapper: (BarData data, _) => data.yData,
                          color: Colors.blue,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Monthly Sales',
                    style: GoogleFonts.dmSerifText(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
                if (monthlySalesData.isNotEmpty)
                  Container(
                    height: 300,
                    child: SfCircularChart(
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      series: <PieSeries<PieData, String>>[
                        PieSeries<PieData, String>(
                          dataSource: monthlySalesData,
                          xValueMapper: (PieData data, _) => data.xData,
                          yValueMapper: (PieData data, _) => data.yData,
                          dataLabelMapper: (PieData data, _) =>
                              '${data.yData} cars',
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
