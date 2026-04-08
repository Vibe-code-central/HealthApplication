// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterEventAdapter extends TypeAdapter<CharacterEvent> {
  @override
  final int typeId = 8;

  @override
  CharacterEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharacterEvent(
      timestamp: fields[0] as DateTime,
      characterId: fields[1] as String,
      eventType: fields[2] as String,
      message: fields[3] as String,
      xpImpact: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CharacterEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.characterId)
      ..writeByte(2)
      ..write(obj.eventType)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.xpImpact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
