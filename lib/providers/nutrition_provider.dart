import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/nutrition_log.dart';
import '../models/user_profile.dart'; // Just using standard imports

final nutritionProvider = StateNotifierProvider<NutritionNotifier, List<NutritionLog>>((ref) {
  return NutritionNotifier();
});

class NutritionNotifier extends StateNotifier<List<NutritionLog>> {
  NutritionNotifier() : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    final box = Hive.box<NutritionLog>('nutritionLogsBox');
    state = box.values.toList().cast<NutritionLog>();
  }

  NutritionLog getTodayLog() {
    final today = DateTime.now();
    try {
      return state.firstWhere((log) => 
        log.date.year == today.year && 
        log.date.month == today.month && 
        log.date.day == today.day);
    } catch (e) {
      // Create new if doesn't exist
      final newLog = NutritionLog(
        date: today,
        proteinGrams: 0,
        waterGlasses: 0,
        meals: [],
        junkFoodIncidents: 0,
        xpEarned: 0,
        weskerImpact: 0,
        adaWongSummary: 'Awaiting intelligence.',
      );
      final box = Hive.box<NutritionLog>('nutritionLogsBox');
      box.add(newLog);
      state = [...state, newLog];
      return newLog;
    }
  }

  Future<void> addWater() async {
    final todayLog = getTodayLog();
    if (todayLog.waterGlasses < 6) {
      todayLog.waterGlasses++;
      await _saveToday(todayLog);
    }
  }

  Future<void> logMeal(MealEntry meal) async {
    final todayLog = getTodayLog();
    todayLog.meals.add(meal);
    todayLog.proteinGrams += meal.proteinGrams;
    
    if (meal.isJunkFood) {
      todayLog.junkFoodIncidents++;
      todayLog.weskerImpact += 10;
    }
    
    await _saveToday(todayLog);
  }

  Future<void> _saveToday(NutritionLog updatedLog) async {
    final box = Hive.box<NutritionLog>('nutritionLogsBox');
    final index = box.values.toList().indexWhere((log) => 
        log.date.year == updatedLog.date.year && 
        log.date.month == updatedLog.date.month && 
        log.date.day == updatedLog.date.day);
        
    if (index != -1) {
      await box.putAt(index, updatedLog);
    }
    _loadLogs();
  }
}
