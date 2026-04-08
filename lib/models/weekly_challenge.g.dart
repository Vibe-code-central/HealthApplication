// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_challenge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyChallengeAdapter extends TypeAdapter<WeeklyChallenge> {
  @override
  final int typeId = 9;

  @override
  WeeklyChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyChallenge(
      challengeId: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      difficulty: fields[3] as String,
      requirements: (fields[4] as Map).cast<String, dynamic>(),
      progress: (fields[5] as Map).cast<String, dynamic>(),
      xpReward: fields[6] as int,
      completed: fields[7] as bool,
      expiresAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyChallenge obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.challengeId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.requirements)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.xpReward)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
