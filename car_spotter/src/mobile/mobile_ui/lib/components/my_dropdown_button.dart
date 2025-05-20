import 'package:flutter/material.dart';

const List<String> eventTypes = ['Sold', 'Bought'];

class MyDropdownButton extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const MyDropdownButton({
    super.key,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<MyDropdownButton> createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialValue; // Set initial value here
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Color(0xFFF15C2A), fontSize: 20),
      underline: Container(
        height: 2,
        color: const Color(0xFFF15C2A),
      ),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            dropdownValue = value;
          });
          // Notify the parent widget of the change.
          widget.onChanged?.call(value);
        }
      },
      items: eventTypes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}