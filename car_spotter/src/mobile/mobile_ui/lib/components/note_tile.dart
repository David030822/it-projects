import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_ui/models/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editNote;
  final void Function(BuildContext)? deleteNote;

  const NoteTile({
    super.key,
    required this.note,
    required this.onChanged,
    required this.editNote,
    required this.deleteNote,
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
              onPressed: editNote,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
            ),
      
            // delete option
            SlidableAction(
              onPressed: deleteNote,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if(onChanged != null) {
              // toggle completion status
              onChanged!(!note.isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: note.isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(note.name),
              leading: Checkbox(
                value: note.isCompleted,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}