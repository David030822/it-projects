// given a goal list of completion days
// is the goal completed today

import 'dart:ui';

import 'package:mobile_ui/models/event.dart';
import 'package:flutter/material.dart';

Map<String, String> parseEventName(String eventName) {
  final regex = RegExp(r'^(Sold|Bought) (.+) on (\d{4}-\d{2}-\d{2})$');
  final match = regex.firstMatch(eventName);

  if (match != null) {
    return {
      'type': match.group(1)!, // 'Sold' or 'Bought'
      'name': match.group(2)!, // 'Audi A6'
      'date': match.group(3)!, // '2024-12-08'
    };
  }

  throw const FormatException('Invalid event name format');
}

// prepare heat map dataset
Map<DateTime, int> prepHeatMapDataset(List<Event> events) {
  Map<DateTime, Set<String>> tempDataset = {};
  Map<DateTime, int> dataset = {};

  for (var event in events) {
    final normalizedDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );

    // Collect event types for each day
    if (!tempDataset.containsKey(normalizedDate)) {
      tempDataset[normalizedDate] = {};
    }
    tempDataset[normalizedDate]!.add(event.type);
  }

  // Determine the color code based on the types of events
  tempDataset.forEach((date, types) {
    if (types.contains('Sold') && types.contains('Bought')) {
      dataset[date] = 3; // Yellow for both Sold and Bought
    } else if (types.contains('Sold')) {
      dataset[date] = 1; // Green for Sold only
    } else if (types.contains('Bought')) {
      dataset[date] = 2; // Red for Bought only
    }
  });

  return dataset;
}

Map<int, Color> getColorSets() {
  return {
    1: Colors.green, // Sold
    2: Colors.red,   // Bought
    3: Colors.yellow // Both
  };
}