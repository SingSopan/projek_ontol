import 'package:hive/hive.dart';

part 'candidate.g.dart';

@HiveType(typeId: 0)
class Candidate extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int vote;

  Candidate({required this.name, required this.vote});
}
