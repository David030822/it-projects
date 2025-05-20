import 'package:isar/isar.dart';

part 'event.g.dart';

@Collection()
class Event {
  // event id
  Id id = Isar.autoIncrement;

  // event name
  late String name;
  late String type;
  late DateTime date;
}