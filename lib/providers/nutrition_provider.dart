import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/nutrition_log.dart';

import '../core/integrity/integrity_service.dart';
import 'user_provider.dart';

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, List<NutritionLog>>((ref) {
  return NutritionNotifier(ref);
});

class NutritionNotifier extends StateNotifier<List<NutritionLog>> {
  final Ref _ref;

  NutritionNotifier(this._ref) : super([]) {
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
    } catch (_) {
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

  // ── Water ──────────────────────────────────────────────

  /// Returns an [IntegrityResult]. If allowed = false, show the narrative
  /// message to the user. If allowed = true, water is logged.
  Future<IntegrityResult> addWater() async {
    final profile = _ref.read(userProvider);
    if (profile == null) return const IntegrityResult(allowed: false);

    // GATE: rate limiter
    final check = IntegrityService.checkWaterRateLimit(profile);
    if (!check.allowed) return check;

    // Record timestamp on profile
    final updatedTimestamps = [
      ...profile.waterLogTimestamps,
      DateTime.now(),
    ];
    await _ref.read(userProvider.notifier).updateWaterTimestamps(updatedTimestamps);

    final todayLog = getTodayLog();
    todayLog.waterGlasses++;
    await _saveToday(todayLog);

    // XP for hitting daily target
    if (todayLog.waterGlasses == 6) {
      await _ref.read(userProvider.notifier).addXP(20);
      return const IntegrityResult(
        allowed: true,
        xpAward: 20,
        narrativeMessage:
            '"Hydration optimal. Metabolic rate uncompromised."',
        characterId: 'ADA',
      );
    }

    return const IntegrityResult(allowed: true);
  }

  // ── Meals ──────────────────────────────────────────────

  /// Returns an [IntegrityResult]. If allowed = false, cooldown is still active.
  Future<IntegrityResult> logMeal(MealEntry meal) async {
    final profile = _ref.read(userProvider);
    if (profile == null) return const IntegrityResult(allowed: false);

    // GATE: meal cooldown
    final cooldownCheck = IntegrityService.checkMealCooldown(profile);
    if (!cooldownCheck.allowed) return cooldownCheck;

    // Record meal time on profile
    await _ref.read(userProvider.notifier).updateLastMealTime(DateTime.now());

    final todayLog = getTodayLog();
    todayLog.meals.add(meal);
    todayLog.proteinGrams += meal.proteinGrams;

    int weskerDelta = 0;
    int xpDelta = 0;
    String? narrativeMessage;
    String characterId = 'ADA';

    if (meal.isJunkFood) {
      // Count junk incidents in the rolling 7-day window
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyJunkCount = state
          .where((log) => log.date.isAfter(weekAgo))
          .fold<int>(0, (sum, log) => sum + log.junkFoodIncidents);

      final penaltyMultiplier =
          IntegrityService.junkPenaltyMultiplier(weeklyJunkCount);
      final basePenalty = meal.isSugarDrink ? 40 : 30;
      final baseWesker = meal.isSugarDrink ? 15 : 10;

      final actualPenalty = (basePenalty * penaltyMultiplier).round();
      final actualWesker = (baseWesker * penaltyMultiplier).round();

      // Apply rookie reduction
      final multiplier =
          IntegrityService.penaltyMultiplier(profile);
      weskerDelta = (actualWesker * multiplier).round();
      xpDelta = -(actualPenalty * multiplier).round();

      todayLog.junkFoodIncidents++;
      todayLog.weskerImpact += weskerDelta;

      if (weeklyJunkCount == 0) {
        // First incident of the week — grace message
        narrativeMessage =
            '"One incident logged. The first costs less. The second will not." — Ada';
      } else {
        narrativeMessage =
            '"You\'ve compromised your integrity. Wesker gains $weskerDelta points. This was avoidable."';
      }

      await _ref.read(userProvider.notifier).addWeskerPower(weskerDelta);
      if (xpDelta < 0) {
        await _ref.read(userProvider.notifier).removeXP(-xpDelta);
      }
    } else {
      // Check protein target hit
      if (todayLog.proteinGrams >= 160 &&
          todayLog.proteinGrams - meal.proteinGrams < 160) {
        xpDelta = 40;
        await _ref.read(userProvider.notifier).addXP(40);
        narrativeMessage =
            '"Target acquired. Muscle synthesis confirmed. Proceed."';
        characterId = 'ADA';
      }
    }

    await _saveToday(todayLog);

    // Update junk free day tracking
    if (!meal.isJunkFood) {
      await _ref.read(userProvider.notifier).incrementJunkFreeDays();
    } else {
      await _ref.read(userProvider.notifier).resetJunkFreeDays();
    }

    return IntegrityResult(
      allowed: true,
      xpAward: xpDelta,
      weskerDelta: weskerDelta,
      narrativeMessage: narrativeMessage,
      characterId: characterId,
    );
  }

  // ── Save ────────────────────────────────────────────────

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
