import 'package:isar/isar.dart';

part 'note.g.dart';

@Collection()
class Note {
  // note id
  Id id = Isar.autoIncrement;

  // note name
  late String name;
  late bool isCompleted;
}