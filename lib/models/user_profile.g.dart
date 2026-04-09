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
      credibilityScore: fields[11] as int,
      lastMealLogTime: fields[12] as DateTime?,
      waterLogTimestamps: (fields[13] as List).cast<DateTime>(),
      consecutivePerfectDays: fields[14] as int,
      isRookiePhase: fields[15] as bool,
      comebackStreakDays: fields[16] as int,
      lastAppCloseTime: fields[17] as DateTime?,
      lastWorkoutStartTime: fields[18] as DateTime?,
      isSessionActive: fields[19] as bool,
      lastClaimedSleepHours: fields[20] as double?,
      junkFreeDayStreak: fields[21] == null ? 0 : fields[21] as int,
      gold: fields[22] == null ? 0 : fields[22] as int,
      unlockedBuffs: fields[23] == null
          ? {}
          : (fields[23] as Map).cast<String, DateTime?>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(24)
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
      ..write(obj.longestStreak)
      ..writeByte(11)
      ..write(obj.credibilityScore)
      ..writeByte(12)
      ..write(obj.lastMealLogTime)
      ..writeByte(13)
      ..write(obj.waterLogTimestamps)
      ..writeByte(14)
      ..write(obj.consecutivePerfectDays)
      ..writeByte(15)
      ..write(obj.isRookiePhase)
      ..writeByte(16)
      ..write(obj.comebackStreakDays)
      ..writeByte(17)
      ..write(obj.lastAppCloseTime)
      ..writeByte(18)
      ..write(obj.lastWorkoutStartTime)
      ..writeByte(19)
      ..write(obj.isSessionActive)
      ..writeByte(20)
      ..write(obj.lastClaimedSleepHours)
      ..writeByte(21)
      ..write(obj.junkFreeDayStreak)
      ..writeByte(22)
      ..write(obj.gold)
      ..writeByte(23)
      ..write(obj.unlockedBuffs);
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
