import 'package:hive/hive.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 3)
class SetLog {
  @HiveField(0)
  int setNumber;

  @HiveField(1)
  double weightKg;

  @HiveField(2)
  int reps;

  @HiveField(3)
  int restSeconds;

  SetLog({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    required this.restSeconds,
  });
}

@HiveType(typeId: 2)
class ExerciseLog {
  @HiveField(0)
  String exerciseName;

  @HiveField(1)
  String muscleGroup;

  @HiveField(2)
  String equipmentType; // MACHINE/FREE_WEIGHT/CABLE/BODYWEIGHT

  @HiveField(3)
  List<SetLog> sets;

  @HiveField(4)
  double previousBest;

  @HiveField(5)
  bool newPersonalBest;

  ExerciseLog({
    required this.exerciseName,
    required this.muscleGroup,
    required this.equipmentType,
    required this.sets,
    required this.previousBest,
    required this.newPersonalBest,
  });
}

@HiveType(typeId: 1)
class WorkoutSession {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String dayType; // MON/TUE/WED/THU/FRI/HOME

  @HiveField(2)
  String focus; // "Chest + Triceps" etc

  @HiveField(3)
  List<ExerciseLog> exercises;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  int xpEarned;

  @HiveField(6)
  bool completed;

  @HiveField(7)
  String characterReaction; // Chris Redfield message

  WorkoutSession({
    required this.date,
    required this.dayType,
    required this.focus,
    required this.exercises,
    required this.durationMinutes,
    required this.xpEarned,
    required this.completed,
    required this.characterReaction,
  });
}
