import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_ui/models/event.dart';

class EventTile extends StatelessWidget {
  final Event event;
  final void Function(BuildContext)? editEvent;
  final void Function(BuildContext)? deleteEvent;

  const EventTile({
    super.key,
    required this.event,
    required this.editEvent,
    required this.deleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // edit option
            SlidableAction(
              onPressed: editEvent,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
            ),

            // delete option
            SlidableAction(
              onPressed: deleteEvent,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: event.type == 'Sold'
                ? Colors.green
                : Colors.red[400],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: ListTile(
            title: Text(event.name),
          ),
        ),
      ),
    );
  }
}