// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealEntryAdapter extends TypeAdapter<MealEntry> {
  @override
  final int typeId = 5;

  @override
  MealEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealEntry(
      mealType: fields[0] as String,
      description: fields[1] as String,
      proteinGrams: fields[2] as double,
      isJunkFood: fields[3] as bool,
      isSugarDrink: fields[4] as bool,
      location: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MealEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.mealType)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.proteinGrams)
      ..writeByte(3)
      ..write(obj.isJunkFood)
      ..writeByte(4)
      ..write(obj.isSugarDrink)
      ..writeByte(5)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionLogAdapter extends TypeAdapter<NutritionLog> {
  @override
  final int typeId = 4;

  @override
  NutritionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionLog(
      date: fields[0] as DateTime,
      proteinGrams: fields[1] as double,
      waterGlasses: fields[2] as int,
      meals: (fields[3] as List).cast<MealEntry>(),
      junkFoodIncidents: fields[4] as int,
      xpEarned: fields[5] as int,
      weskerImpact: fields[6] as int,
      adaWongSummary: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.proteinGrams)
      ..writeByte(2)
      ..write(obj.waterGlasses)
      ..writeByte(3)
      ..write(obj.meals)
      ..writeByte(4)
      ..write(obj.junkFoodIncidents)
      ..writeByte(5)
      ..write(obj.xpEarned)
      ..writeByte(6)
      ..write(obj.weskerImpact)
      ..writeByte(7)
      ..write(obj.adaWongSummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
