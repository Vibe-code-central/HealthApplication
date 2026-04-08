import 'package:hive/hive.dart';

part 'muscle_progress.g.dart';

@HiveType(typeId: 6)
class MuscleProgress {
  @HiveField(0)
  String muscleGroup; // chest/back/shoulders/arms/legs/core/conditioning

  @HiveField(1)
  double progressScore; // 0.0-100.0

  @HiveField(2)
  DateTime lastTrained;

  @HiveField(3)
  int totalSessions;

  @HiveField(4)
  double peakWeight;

  MuscleProgress({
    required this.muscleGroup,
    required this.progressScore,
    required this.lastTrained,
    required this.totalSessions,
    required this.peakWeight,
  });
}
