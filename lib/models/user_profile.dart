import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  String name;

  @HiveField(1)
  double startingWeight;

  @HiveField(2)
  double currentWeight;

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  int totalXP;

  @HiveField(5)
  int level; // 1-50

  @HiveField(6)
  int weskerPower; // 0-100

  @HiveField(7)
  int avatarState; // 0-6

  @HiveField(8)
  DateTime programmeStart;

  @HiveField(9)
  int currentStreak;

  @HiveField(10)
  int longestStreak;

  UserProfile({
    required this.name,
    required this.startingWeight,
    required this.currentWeight,
    required this.heightCm,
    required this.totalXP,
    required this.level,
    required this.weskerPower,
    required this.avatarState,
    required this.programmeStart,
    required this.currentStreak,
    required this.longestStreak,
  });
}
