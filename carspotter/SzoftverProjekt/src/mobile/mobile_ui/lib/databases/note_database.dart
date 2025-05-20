import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:mobile_ui/models/app_settings.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  /*

  S E T U P

  */

  // I N I T I A L I Z E - D A T A B A S E
  static Future<void> initialize() async {
    try {
      // Check if the database is already initialized to avoid re-initialization
      if (Isar.instanceNames.contains('NoteDatabase')) {
        return;
      }

      // Obtain the application documents directory
      final dir = await getApplicationDocumentsDirectory();

      // Open the Isar database with the provided schemas
      isar = await Isar.open(
        [NoteSchema, AppSettingsSchema],
        directory: dir.path,
        name: 'NoteDatabase',
      );
    } catch (e) {
      // Handle any errors during initialization
      debugPrint('Failed to initialize the database: $e');
      rethrow;
    }
  }

  // save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*

  C R U D X O P E R A T I O N S

  */

  // list of notes
  final List<Note> currentNotes = [];

  // C R E A T E - add new note
  Future<void> addNote(String noteName) async {
    // create new note
    final newNote = Note()..name = noteName;
    newNote.isCompleted = false;

    // save to db
    await isar.writeTxn(() => isar.notes.put(newNote));

    // re-read from db
    readNotes();
  }

  // R E A D - read saved notes from db
  Future<void> readNotes() async {
    // fetch all notes from db
    List<Note> fetchedNotes = await isar.notes.where().findAll();

    // give to current notes
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);

    // update UI
    notifyListeners();
  }

  // U P D A T E - check note on and off
  Future<void> updateNoteCompletion(int id, bool newStatus) async {
    // find the specific note
    final note = await isar.notes.get(id);

    // update completion status
    if (note != null) {
      await isar.writeTxn(() async {
        note.isCompleted = newStatus;

        // save the updated notes back to the db
        await isar.notes.put(note);
      });
    }

    // re-read from db
    readNotes();
  }

  // U P D A T E - edit note name
  Future<void> updateNoteName(int id, String newName) async {
    // find the specific note
    final note = await isar.notes.get(id);

    // update note name
    if (note != null) {
      // update name
      await isar.writeTxn(() async {
        note.name = newName;
        // save updated note back to the db
        await isar.notes.put(note);
      });
    }

    // re-read from db
    readNotes();
  }

  // D E L E T E - delete note
  Future<void> deleteNote(int id) async {
    // perform the delete
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });

    // re-read from db
    readNotes();
  }
}