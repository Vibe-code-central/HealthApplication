import 'package:hive/hive.dart';

part 'nutrition_log.g.dart';

@HiveType(typeId: 5)
class MealEntry {
  @HiveField(0)
  String mealType; // BREAKFAST/SNACK/LUNCH/PRE_WORKOUT/POST_WORKOUT/DINNER

  @HiveField(1)
  String description;

  @HiveField(2)
  double proteinGrams;

  @HiveField(3)
  bool isJunkFood;

  @HiveField(4)
  bool isSugarDrink;

  @HiveField(5)
  String location; // HOME/OUTSIDE/CARRY_BAG

  MealEntry({
    required this.mealType,
    required this.description,
    required this.proteinGrams,
    required this.isJunkFood,
    required this.isSugarDrink,
    required this.location,
  });
}

@HiveType(typeId: 4)
class NutritionLog {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double proteinGrams;

  @HiveField(2)
  int waterGlasses; // target: 6

  @HiveField(3)
  List<MealEntry> meals;

  @HiveField(4)
  int junkFoodIncidents;

  @HiveField(5)
  int xpEarned;

  @HiveField(6)
  int weskerImpact;

  @HiveField(7)
  String adaWongSummary;

  NutritionLog({
    required this.date,
    required this.proteinGrams,
    required this.waterGlasses,
    required this.meals,
    required this.junkFoodIncidents,
    required this.xpEarned,
    required this.weskerImpact,
    required this.adaWongSummary,
  });
}
