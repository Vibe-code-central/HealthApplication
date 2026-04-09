import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement.dart';
import 'user_provider.dart';

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  return AchievementNotifier(ref);
});

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  final Ref _ref;

  AchievementNotifier(this._ref) : super([]) {
    Future.microtask(_init);
  }

  Future<void> _init() async {
    final box = Hive.box<Achievement>('achievementsBox');

    if (box.isEmpty) {
      // Seed the catalogue on first launch
      final catalogue = buildAchievementCatalogue();
      await box.addAll(catalogue);
      state = catalogue;
    } else {
      state = box.values.toList();
    }
  }

  // ── Unlock ───────────────────────────────────────────────

  /// Attempts to unlock an achievement by id. Returns the unlocked achievement
  /// if it was newly unlocked, null if already unlocked or not found.
  Future<Achievement?> tryUnlock(String achievementId) async {
    final index = state.indexWhere((a) => a.id == achievementId);
    if (index == -1 || state[index].isUnlocked) return null;

    final achievement = state[index];
    achievement.isUnlocked = true;
    achievement.unlockedAt = DateTime.now();

    // Persist
    final box = Hive.box<Achievement>('achievementsBox');
    await box.putAt(index, achievement);

    // Reload state
    final updated = List<Achievement>.from(state);
    updated[index] = achievement;
    state = updated;

    // Award XP
    await _ref.read(userProvider.notifier).addXP(achievement.xpReward);

    return achievement;
  }

  // ── Auto-check triggers ──────────────────────────────────

  /// Call this after any notable action to check if new achievements fire.
  Future<List<Achievement>> checkAll() async {
    final user = _ref.read(userProvider);
    if (user == null) return [];

    final unlocked = <Achievement>[];

    // Level-based
    if (user.level >= 10) {
      final a = await tryUnlock(AchievementId.centurion.name);
      if (a != null) unlocked.add(a);
    }
    if (user.level >= 25) {
      final a = await tryUnlock(AchievementId.legend.name);
      if (a != null) unlocked.add(a);
    }

    // Streak-based
    if (user.currentStreak >= 7) {
      final a = await tryUnlock(AchievementId.ironWill.name);
      if (a != null) unlocked.add(a);
    }
    if (user.currentStreak >= 14) {
      final a = await tryUnlock(AchievementId.biohazardProtocol.name);
      if (a != null) unlocked.add(a);
    }
    if (user.currentStreak >= 30) {
      final a = await tryUnlock(AchievementId.requiemOperative.name);
      if (a != null) unlocked.add(a);
    }

    // Wesker
    if (user.weskerPower == 0) {
      final a = await tryUnlock(AchievementId.nemesisHunter.name);
      if (a != null) unlocked.add(a);
    }

    // Junk-free
    if (user.junkFreeDayStreak >= 7) {
      final a = await tryUnlock(AchievementId.cleanSlate.name);
      if (a != null) unlocked.add(a);
    }
    if (user.junkFreeDayStreak >= 14) {
      final a = await tryUnlock(AchievementId.doubleAgent.name);
      if (a != null) unlocked.add(a);
    }

    // Rookie phase completion
    if (!user.isRookiePhase) {
      final a = await tryUnlock(AchievementId.rookieGrad.name);
      if (a != null) unlocked.add(a);
    }

    // Comeback protocol
    if (user.comebackStreakDays >= 3) {
      final a = await tryUnlock(AchievementId.comebackKid.name);
      if (a != null) unlocked.add(a);
    }

    return unlocked;
  }

  // ── Helpers ──────────────────────────────────────────────

  List<Achievement> get unlocked => state.where((a) => a.isUnlocked).toList();
  List<Achievement> get locked => state.where((a) => !a.isUnlocked).toList();
  int get unlockedCount => state.where((a) => a.isUnlocked).length;
  int get totalXPFromAchievements =>
      unlocked.fold(0, (sum, a) => sum + a.xpReward);

  List<Achievement> byTier(String tier) =>
      state.where((a) => a.tier == tier).toList();
}
