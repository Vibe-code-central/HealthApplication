// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      startingWeight: fields[1] as double,
      currentWeight: fields[2] as double,
      heightCm: fields[3] as double,
      totalXP: fields[4] as int,
      level: fields[5] as int,
      weskerPower: fields[6] as int,
      avatarState: fields[7] as int,
      programmeStart: fields[8] as DateTime,
      currentStreak: fields[9] as int,
      longestStreak: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.startingWeight)
      ..writeByte(2)
      ..write(obj.currentWeight)
      ..writeByte(3)
      ..write(obj.heightCm)
      ..writeByte(4)
      ..write(obj.totalXP)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.weskerPower)
      ..writeByte(7)
      ..write(obj.avatarState)
      ..writeByte(8)
      ..write(obj.programmeStart)
      ..writeByte(9)
      ..write(obj.currentStreak)
      ..writeByte(10)
      ..write(obj.longestStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
