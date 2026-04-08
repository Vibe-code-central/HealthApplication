import 'package:hive/hive.dart';

part 'weekly_challenge.g.dart';

@HiveType(typeId: 9)
class WeeklyChallenge {
  @HiveField(0)
  String challengeId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String difficulty; // GREEN/AMBER/RED

  @HiveField(4)
  Map<String, dynamic> requirements;

  @HiveField(5)
  Map<String, dynamic> progress;

  @HiveField(6)
  int xpReward;

  @HiveField(7)
  bool completed;

  @HiveField(8)
  DateTime expiresAt;

  WeeklyChallenge({
    required this.challengeId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.requirements,
    required this.progress,
    required this.xpReward,
    required this.completed,
    required this.expiresAt,
  });
}
