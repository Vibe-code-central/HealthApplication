import 'package:hive/hive.dart';

part 'character_event.g.dart';

@HiveType(typeId: 8)
class CharacterEvent {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  String characterId; // ADA/CHRIS/CLAIRE/HUNK/MERCHANT/WESKER/NEMESIS

  @HiveField(2)
  String eventType;

  @HiveField(3)
  String message;

  @HiveField(4)
  int xpImpact;

  CharacterEvent({
    required this.timestamp,
    required this.characterId,
    required this.eventType,
    required this.message,
    required this.xpImpact,
  });
}
