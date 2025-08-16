// lib/models/score.dart
import 'package:hive/hive.dart';

part 'score.g.dart';

@HiveType(typeId: 0)
class Score extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int score;

  Score(this.name, this.score);
}