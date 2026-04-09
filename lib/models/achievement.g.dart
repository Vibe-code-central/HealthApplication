// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 10;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      narrativeQuote: fields[3] as String,
      character: fields[4] as String,
      xpReward: fields[5] as int,
      iconCode: fields[8] as String,
      tier: fields[9] as String,
      isUnlocked: fields[6] as bool,
      unlockedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.narrativeQuote)
      ..writeByte(4)
      ..write(obj.character)
      ..writeByte(5)
      ..write(obj.xpReward)
      ..writeByte(6)
      ..write(obj.isUnlocked)
      ..writeByte(7)
      ..write(obj.unlockedAt)
      ..writeByte(8)
      ..write(obj.iconCode)
      ..writeByte(9)
      ..write(obj.tier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
