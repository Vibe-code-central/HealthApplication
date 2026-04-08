import 'package:hive/hive.dart';

part 'recovery_log.g.dart';

@HiveType(typeId: 7)
class RecoveryLog {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double sleepHours;

  @HiveField(2)
  int sleepQuality; // 1-5

  @HiveField(3)
  Map<String, int> soreness; // muscle: 1-5

  @HiveField(4)
  String activityType; // GYM/HOME/REST

  @HiveField(5)
  String claireMessage;

  RecoveryLog({
    required this.date,
    required this.sleepHours,
    required this.sleepQuality,
    required this.soreness,
    required this.activityType,
    required this.claireMessage,
  });
}
