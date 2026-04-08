// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecoveryLogAdapter extends TypeAdapter<RecoveryLog> {
  @override
  final int typeId = 7;

  @override
  RecoveryLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecoveryLog(
      date: fields[0] as DateTime,
      sleepHours: fields[1] as double,
      sleepQuality: fields[2] as int,
      soreness: (fields[3] as Map).cast<String, int>(),
      activityType: fields[4] as String,
      claireMessage: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecoveryLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.sleepHours)
      ..writeByte(2)
      ..write(obj.sleepQuality)
      ..writeByte(3)
      ..write(obj.soreness)
      ..writeByte(4)
      ..write(obj.activityType)
      ..writeByte(5)
      ..write(obj.claireMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
