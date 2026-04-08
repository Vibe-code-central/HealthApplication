// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetLogAdapter extends TypeAdapter<SetLog> {
  @override
  final int typeId = 3;

  @override
  SetLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetLog(
      setNumber: fields[0] as int,
      weightKg: fields[1] as double,
      reps: fields[2] as int,
      restSeconds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SetLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.setNumber)
      ..writeByte(1)
      ..write(obj.weightKg)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.restSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseLogAdapter extends TypeAdapter<ExerciseLog> {
  @override
  final int typeId = 2;

  @override
  ExerciseLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseLog(
      exerciseName: fields[0] as String,
      muscleGroup: fields[1] as String,
      equipmentType: fields[2] as String,
      sets: (fields[3] as List).cast<SetLog>(),
      previousBest: fields[4] as double,
      newPersonalBest: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.muscleGroup)
      ..writeByte(2)
      ..write(obj.equipmentType)
      ..writeByte(3)
      ..write(obj.sets)
      ..writeByte(4)
      ..write(obj.previousBest)
      ..writeByte(5)
      ..write(obj.newPersonalBest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 1;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      date: fields[0] as DateTime,
      dayType: fields[1] as String,
      focus: fields[2] as String,
      exercises: (fields[3] as List).cast<ExerciseLog>(),
      durationMinutes: fields[4] as int,
      xpEarned: fields[5] as int,
      completed: fields[6] as bool,
      characterReaction: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.dayType)
      ..writeByte(2)
      ..write(obj.focus)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.xpEarned)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.characterReaction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
