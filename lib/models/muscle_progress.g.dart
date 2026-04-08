// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MuscleProgressAdapter extends TypeAdapter<MuscleProgress> {
  @override
  final int typeId = 6;

  @override
  MuscleProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MuscleProgress(
      muscleGroup: fields[0] as String,
      progressScore: fields[1] as double,
      lastTrained: fields[2] as DateTime,
      totalSessions: fields[3] as int,
      peakWeight: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MuscleProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.muscleGroup)
      ..writeByte(1)
      ..write(obj.progressScore)
      ..writeByte(2)
      ..write(obj.lastTrained)
      ..writeByte(3)
      ..write(obj.totalSessions)
      ..writeByte(4)
      ..write(obj.peakWeight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
