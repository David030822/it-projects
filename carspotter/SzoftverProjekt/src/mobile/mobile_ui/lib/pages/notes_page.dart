import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_ui/components/note_tile.dart';
import 'package:mobile_ui/databases/note_database.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {

  @override
  void initState() {
    // read existing notes on app startup
    Provider.of<NoteDatabase>(context, listen: false).readNotes();

    super.initState();
  }

  // text controller
  final TextEditingController _textController = TextEditingController();

  // create new note
  void createNewNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Create a new note',
          ),
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get the new note name
              String newNoteName = _textController.text;

              // save to db
              context.read<NoteDatabase>().addNote(newNoteName);

              // pop box
              Navigator.pop(context);

              // clear controller
              _textController.clear();
            },
            child: const Text('Save'),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controller
              _textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // check note on & off
  void checkNoteOnOff(bool? value, Note note) {
    // update note completion status
    if (value != null) {
      context.read<NoteDatabase>().updateNoteCompletion(note.id, value);
    }
  }

  // edit note box
  void editNoteBox(Note note) {
    // set the controller's text to the note's current name
    _textController.text = note.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textController,
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get the new note name
              String newNoteName = _textController.text;

              // save to db
              context.read<NoteDatabase>().updateNoteName(note.id, newNoteName);

              // pop box
              Navigator.pop(context);

              // clear controller
              _textController.clear();
            },
            child: const Text('Save'),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controller
              _textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      )
    );
  }

  // delete note box
  void deleteNoteBox(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete?'),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              // delete from db
              context.read<NoteDatabase>().deleteNote(note.id);

              // pop box
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),

          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notes page',
          style: GoogleFonts.dmSerifText(
            fontSize: 24,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewNote,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          // note list
          _buildNoteList(),
        ],
      )
    );
  }

  // build note list
  Widget _buildNoteList() {
    // note db
    final noteDatabase = context.watch<NoteDatabase>();

    // current notes
    List<Note> currentNotes = noteDatabase.currentNotes;

    // return list of notes UI
    return ListView.builder(
      itemCount: currentNotes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual note
        final note = currentNotes[index];

        // return note tile UI
        return NoteTile(
          note: note,
          onChanged: (value) => checkNoteOnOff(value, note),
          editNote: (context) => editNoteBox(note),
          deleteNote: (context) => deleteNoteBox(note),
        );
      } 
    );
  }
}