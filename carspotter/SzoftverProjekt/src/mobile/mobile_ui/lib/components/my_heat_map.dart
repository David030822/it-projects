import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:mobile_ui/util/event_util.dart';

class MyHeatMap extends StatelessWidget {
  final Map<DateTime, int>? datasets;
  final DateTime startDate;

  const MyHeatMap({
    super.key,
    required this.datasets,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: startDate,
      endDate: DateTime.now(),
      datasets: datasets,
      colorMode: ColorMode.color,
      defaultColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.tertiary,
      showColorTip: false,
      showText: true,
      scrollable: true,
      size: 30,
      colorsets: getColorSets(),
    );
  }
}