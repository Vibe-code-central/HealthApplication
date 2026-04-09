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
    // Load existing logs synchronously (safe — super() is already set).
    _loadLogs();
    // Ensure today's log exists, but defer state mutation to avoid
    // modifying state while the widget tree is still building.
    Future.microtask(_ensureTodayLog);
  }

  // ── Internal helpers ────────────────────────────────────

  void _loadLogs() {
    final box = Hive.box<NutritionLog>('nutritionLogsBox');
    state = box.values.toList().cast<NutritionLog>();
  }

  /// Creates today's log in Hive + state if one doesn't exist yet.
  /// Always called via [Future.microtask] — never directly from build.
  Future<void> _ensureTodayLog() async {
    final today = DateTime.now();
    final exists = state.any((log) =>
        log.date.year == today.year &&
        log.date.month == today.month &&
        log.date.day == today.day);
    if (exists) return;

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
    await box.add(newLog);
    // Safe now — we are outside the build phase
    state = [...state, newLog];
  }

  // ── Public read-only accessor ───────────────────────────

  /// Returns today's log if it exists, or a blank sentinel.
  /// NEVER modifies state — safe to call from build().
  NutritionLog getTodayLog() {
    final today = DateTime.now();
    return state.firstWhere(
      (log) =>
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day,
      orElse: () => NutritionLog(
        date: today,
        proteinGrams: 0,
        waterGlasses: 0,
        meals: [],
        junkFoodIncidents: 0,
        xpEarned: 0,
        weskerImpact: 0,
        adaWongSummary: 'Awaiting intelligence.',
      ),
    );
  }

  // ── Water ───────────────────────────────────────────────

  Future<IntegrityResult> addWater() async {
    final profile = _ref.read(userProvider);
    if (profile == null) return const IntegrityResult(allowed: false);

    // GATE: rate limiter
    final check = IntegrityService.checkWaterRateLimit(profile);
    if (!check.allowed) return check;

    // Record timestamp on profile
    final updatedTimestamps = [...profile.waterLogTimestamps, DateTime.now()];
    await _ref.read(userProvider.notifier).updateWaterTimestamps(updatedTimestamps);

    // Ensure log exists before mutating (may not have been created yet)
    await _ensureTodayLog();
    final todayLog = getTodayLog();
    todayLog.waterGlasses++;
    await _saveToday(todayLog);

    // XP for hitting daily target
    if (todayLog.waterGlasses == 6) {
      await _ref.read(userProvider.notifier).addXP(20);
      return const IntegrityResult(
        allowed: true,
        xpAward: 20,
        narrativeMessage: '"Hydration optimal. Metabolic rate uncompromised."',
        characterId: 'ADA',
      );
    }

    return const IntegrityResult(allowed: true);
  }

  // ── Meals ───────────────────────────────────────────────

  Future<IntegrityResult> logMeal(MealEntry meal) async {
    final profile = _ref.read(userProvider);
    if (profile == null) return const IntegrityResult(allowed: false);

    // GATE: meal cooldown
    final cooldownCheck = IntegrityService.checkMealCooldown(profile);
    if (!cooldownCheck.allowed) return cooldownCheck;

    // Record meal time on profile
    await _ref.read(userProvider.notifier).updateLastMealTime(DateTime.now());

    // Ensure today's log is persisted
    await _ensureTodayLog();
    final todayLog = getTodayLog();
    todayLog.meals.add(meal);
    todayLog.proteinGrams += meal.proteinGrams;

    int weskerDelta = 0;
    int xpDelta = 0;
    String? narrativeMessage;
    String characterId = 'ADA';

    if (meal.isJunkFood) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyJunkCount = state
          .where((log) => log.date.isAfter(weekAgo))
          .fold<int>(0, (sum, log) => sum + log.junkFoodIncidents);

      final penaltyMultiplier = IntegrityService.junkPenaltyMultiplier(weeklyJunkCount);
      final basePenalty = meal.isSugarDrink ? 40 : 30;
      final baseWesker = meal.isSugarDrink ? 15 : 10;
      final multiplier = IntegrityService.penaltyMultiplier(profile);

      weskerDelta = ((baseWesker * penaltyMultiplier) * multiplier).round();
      xpDelta = -((basePenalty * penaltyMultiplier) * multiplier).round();

      todayLog.junkFoodIncidents++;
      todayLog.weskerImpact += weskerDelta;

      narrativeMessage = weeklyJunkCount == 0
          ? '"One incident logged. The first costs less. The second will not." — Ada'
          : '"You\'ve compromised your integrity. Wesker gains $weskerDelta points. This was avoidable."';

      await _ref.read(userProvider.notifier).addWeskerPower(weskerDelta);
      if (xpDelta < 0) {
        await _ref.read(userProvider.notifier).removeXP(-xpDelta);
      }
    } else {
      // Protein target hit check
      if (todayLog.proteinGrams >= 160 &&
          todayLog.proteinGrams - meal.proteinGrams < 160) {
        xpDelta = 40;
        await _ref.read(userProvider.notifier).addXP(40);
        narrativeMessage = '"Target acquired. Muscle synthesis confirmed. Proceed."';
      }
    }

    await _saveToday(todayLog);

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

  // ── Remove Meal (undo wrong log) ────────────────────────

  /// Removes a meal at [index] from today's log and fully reverses its effects:
  /// protein, junk count, Wesker power, and XP are all rolled back.
  Future<IntegrityResult> removeMeal(int mealIndex) async {
    await _ensureTodayLog();
    final todayLog = getTodayLog();

    if (mealIndex < 0 || mealIndex >= todayLog.meals.length) {
      return const IntegrityResult(allowed: false);
    }

    final meal = todayLog.meals[mealIndex];

    // Reverse protein
    todayLog.proteinGrams =
        (todayLog.proteinGrams - meal.proteinGrams).clamp(0, double.infinity);

    // Reverse junk effects
    if (meal.isJunkFood && todayLog.junkFoodIncidents > 0) {
      todayLog.junkFoodIncidents--;

      // Recalculate what penalty was applied and reverse it
      final profile = _ref.read(userProvider);
      if (profile != null) {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        final weeklyJunkCount = state
            .where((log) => log.date.isAfter(weekAgo))
            .fold<int>(0, (sum, log) => sum + log.junkFoodIncidents);

        final penaltyMultiplier =
            IntegrityService.junkPenaltyMultiplier(weeklyJunkCount);
        final multiplier = IntegrityService.penaltyMultiplier(profile);
        final basePenalty = meal.isSugarDrink ? 40 : 30;
        final baseWesker = meal.isSugarDrink ? 15 : 10;

        final xpRestored =
            ((basePenalty * penaltyMultiplier) * multiplier).round();
        final weskerRestored =
            ((baseWesker * penaltyMultiplier) * multiplier).round();

        todayLog.weskerImpact =
            (todayLog.weskerImpact - weskerRestored).clamp(0, 9999);

        // Restore XP and reduce Wesker
        await _ref.read(userProvider.notifier).addXP(xpRestored);
        await _ref.read(userProvider.notifier).reduceWeskerPower(weskerRestored);
      }
    } else if (!meal.isJunkFood) {
      // If removing a clean meal caused protein to drop below target,
      // reverse any protein-target XP bonus that was awarded
      final wasAboveTarget =
          todayLog.proteinGrams + meal.proteinGrams >= 160;
      final nowBelowTarget = todayLog.proteinGrams < 160;
      if (wasAboveTarget && nowBelowTarget) {
        await _ref.read(userProvider.notifier).removeXP(40);
      }
    }

    todayLog.meals.removeAt(mealIndex);
    await _saveToday(todayLog);

    return const IntegrityResult(
      allowed: true,
      narrativeMessage:
          '"Log corrected. Integrity restored. Don\'t make a habit of it." — Ada',
      characterId: 'ADA',
    );
  }

  // ── Persist ─────────────────────────────────────────────

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

