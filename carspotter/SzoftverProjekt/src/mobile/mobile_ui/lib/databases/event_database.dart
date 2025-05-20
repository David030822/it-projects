import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:mobile_ui/models/app_settings.dart';
import 'package:mobile_ui/models/event.dart';
import 'package:path_provider/path_provider.dart';

class EventDatabase extends ChangeNotifier {
  static late Isar isar;

  /*

  S E T U P

  */

  // I N I T I A L I Z E - D A T A B A S E
  static Future<void> initialize() async {
    try {
      // Check if the database is already initialized to avoid re-initialization
      if (Isar.instanceNames.contains('EventDatabase')) {
        return;
      }

      // Obtain the application documents directory
      final dir = await getApplicationDocumentsDirectory();

      // Open the Isar database with the provided schemas
      isar = await Isar.open(
        [EventSchema, AppSettingsSchema],
        directory: dir.path,
        name: 'EventDatabase'
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

  // list of events
  final List<Event> currentEvents = [];

  // C R E A T E - add new event
  Future<void> addEvent(String eventName, String eventType) async {
    // get current date
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    // create new event
    final newEvent = Event()
      ..name = eventName
      ..type = eventType
      ..date = normalizedDate;

    // save to db
    await isar.writeTxn(() => isar.events.put(newEvent));

    // re-read from db
    readEvents();
  }

  // R E A D - read saved events from db
  Future<void> readEvents() async {
    // fetch all events from db
    List<Event> fetchedEvents = await isar.events.where().findAll();

    // give to current events
    currentEvents.clear();
    currentEvents.addAll(fetchedEvents);

    // update UI
    notifyListeners();
  }

  // U P D A T E - edit event name
  Future<void> updateEvent(int id, String newName, String newType) async {
    // find the specific event
    final event = await isar.events.get(id);

    // update event name
    if (event != null) {
      // update name
      await isar.writeTxn(() async {
        event.name = newName;
        event.type = newType;
        // save updated event back to the db
        await isar.events.put(event);
      });
    }

    // re-read from db
    readEvents();
  }

  // D E L E T E - delete event
  Future<void> deleteEvent(int id) async {
    // perform the delete
    await isar.writeTxn(() async {
      await isar.events.delete(id);
    });

    // re-read from db
    readEvents();
  }
}