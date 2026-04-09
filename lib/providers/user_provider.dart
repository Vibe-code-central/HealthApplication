import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../core/integrity/integrity_service.dart';

final userProvider =
    StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null) {
    _loadProfile();
    // Defer startup mutations — direct state writes during
    // provider construction cause "tree building" errors in Riverpod.
    Future.microtask(_runStartupChecks);
  }

  // ── Boot ─────────────────────────────────────────────────

  void _loadProfile() {
    final box = Hive.box<UserProfile>('userProfileBox');
    if (box.isNotEmpty) {
      state = box.getAt(0);
    }
  }

  /// Called every time the app starts. Handles:
  ///  - Wesker decay for absent days
  ///  - Rookie phase expiry
  ///  - Recording last app-close time (for sleep cross-check)
  Future<void> _runStartupChecks() async {
    if (state == null) return;
    final now = DateTime.now();
    var s = state!;

    // 1. Wesker passive decay during absence
    final decay = IntegrityService.calculateWeskerDecay(
      currentPower: s.weskerPower,
      lastActivityDate: s.lastAppCloseTime,
    );
    if (decay > 0) {
      s.weskerPower = (s.weskerPower - decay).clamp(0, 100);
    }

    // 2. Rookie phase check
    s.isRookiePhase = IntegrityService.isRookiePhase(s);

    // 3. Record this open time so when we check sleep tomorrow, we have it
    s.lastAppCloseTime = now;

    await _persist(s);
  }

  // ── Profile Creation ────────────────────────────────────

  Future<void> createProfile(
      String name, double height, double weight) async {
    final newProfile = UserProfile(
      name: name,
      startingWeight: weight,
      currentWeight: weight,
      heightCm: height,
      totalXP: 0,
      level: 1,
      weskerPower: 0,
      avatarState: 0,
      programmeStart: DateTime.now(),
      currentStreak: 0,
      longestStreak: 0,
      credibilityScore: 100,
      waterLogTimestamps: [],
      consecutivePerfectDays: 0,
      isRookiePhase: true,
      comebackStreakDays: 0,
      isSessionActive: false,
      junkFreeDayStreak: 0,
    );
    final box = Hive.box<UserProfile>('userProfileBox');
    await box.add(newProfile);
    state = newProfile;
  }

  // ── XP ──────────────────────────────────────────────────

  Future<void> addXP(int amount) async {
    if (state == null) return;
    final s = state!;
    s.totalXP = (s.totalXP + amount).clamp(0, 999999);
    s.level = _calculateLevel(s.totalXP);
    await _persist(s);
    await _calculateAvatarState();
  }

  Future<void> addGold(int amount) async {
    if (state == null) return;
    var s = state!;
    s.gold = (s.gold + amount).clamp(0, 999999);
    await _persist(s);
  }

  Future<void> updateBuffs(Map<String, DateTime?> buffs) async {
    if (state == null) return;
    var s = state!;
    s.unlockedBuffs = buffs;
    await _persist(s);
  }

  Future<void> removeXP(int amount) async {
    if (state == null) return;
    final s = state!;
    // Apply rookie multiplier to penalty
    final multiplier = IntegrityService.penaltyMultiplier(s);
    final reducedAmount = (amount * multiplier).round();
    s.totalXP = (s.totalXP - reducedAmount).clamp(0, 999999);
    s.level = _calculateLevel(s.totalXP);
    await _persist(s);
  }

  // ── Wesker ──────────────────────────────────────────────

  Future<void> addWeskerPower(int amount) async {
    if (state == null) return;
    final s = state!;
    s.weskerPower = (s.weskerPower + amount).clamp(0, 100);
    await _persist(s);
  }

  Future<void> reduceWeskerPower(int amount) async {
    if (state == null) return;
    final s = state!;
    s.weskerPower = (s.weskerPower - amount).clamp(0, 100);
    await _persist(s);
  }

  // ── Workout Session ──────────────────────────────────────

  Future<void> startWorkoutSession() async {
    if (state == null) return;
    final s = state!;
    s.lastWorkoutStartTime = DateTime.now();
    s.isSessionActive = true;
    await _persist(s);
  }

  /// Returns an IntegrityResult. If the session was suspiciously fast,
  /// XP is reduced. Caller should use result.xpAward for the actual award.
  Future<IntegrityResult> completeWorkoutSession({
    required int expectedMinutes,
    required int baseXP,
  }) async {
    if (state == null) return const IntegrityResult(allowed: false);
    final s = state!;
    final start = s.lastWorkoutStartTime;
    final elapsed = start != null
        ? DateTime.now().difference(start).inMinutes
        : expectedMinutes; // if no timestamp, assume fine

    final result = IntegrityService.checkSessionSpeed(
      elapsedMinutes: elapsed,
      expectedMinutes: expectedMinutes,
      baseXP: baseXP,
    );

    if (result.weskerDelta > 0) {
      await addWeskerPower(result.weskerDelta);
    }

    // Anomaly detected: penalise credibility
    if (result.narrativeMessage != null) {
      s.credibilityScore =
          IntegrityService.penaliseCredibility(s.credibilityScore);
    }

    s.isSessionActive = false;
    s.lastWorkoutStartTime = null;
    await _persist(s);
    await addXP(result.xpAward);

    return result;
  }

  // ── Sleep ────────────────────────────────────────────────

  /// Cross-checks claimed sleep against app close/open gap.
  Future<IntegrityResult> logSleep(double hours) async {
    if (state == null) return const IntegrityResult(allowed: false);
    final s = state!;
    const baseXP = 30;

    final result = IntegrityService.checkSleepValidity(
      claimedHours: hours,
      lastAppCloseTime: s.lastAppCloseTime,
      baseXP: baseXP,
    );

    s.lastClaimedSleepHours = hours;
    await _persist(s);
    await addXP(result.xpAward);

    // Penalty for < 6 hrs sleep
    if (hours < 6) {
      final penalty =
          (20 * IntegrityService.penaltyMultiplier(s)).round();
      await removeXP(penalty);
      await addWeskerPower(
          (8 * IntegrityService.penaltyMultiplier(s)).round());
    }

    return result;
  }

  // ── Integrity Helpers ────────────────────────────────────

  Future<void> updateLastMealTime(DateTime time) async {
    if (state == null) return;
    state!.lastMealLogTime = time;
    await _persist(state!);
  }

  Future<void> updateWaterTimestamps(List<DateTime> stamps) async {
    if (state == null) return;
    state!.waterLogTimestamps = stamps;
    await _persist(state!);
  }

  Future<void> incrementJunkFreeDays() async {
    if (state == null) return;
    final s = state!;
    s.junkFreeDayStreak++;

    // Check for Wesker comment triggers
    final comment = IntegrityService.weskerPatternComment(
      junkFreeDays: s.junkFreeDayStreak,
      consecutivePerfectDays: s.consecutivePerfectDays,
      credibilityScore: s.credibilityScore,
    );
    // Comment is surfaced via state; UI reads it from weskerComment provider
    if (comment != null) {
      s.credibilityScore =
          IntegrityService.penaliseCredibility(s.credibilityScore, drop: 5);
    }

    await _persist(s);
  }

  Future<void> resetJunkFreeDays() async {
    if (state == null) return;
    state!.junkFreeDayStreak = 0;
    await _persist(state!);
  }

  // ── Weekly Debrief ───────────────────────────────────────

  Future<IntegrityResult> submitWeeklyDebrief(int rating) async {
    if (state == null) return const IntegrityResult(allowed: false);
    final s = state!;

    final (:xpBonus, :credibilityChange) =
        IntegrityService.weeklyDebriefXP(rating);

    s.credibilityScore =
        (s.credibilityScore + credibilityChange).clamp(0, 100);
    await _persist(s);
    if (xpBonus > 0) await addXP(xpBonus);

    String message;
    if (rating <= 2) {
      message =
          '"Acknowledged. Ghost respects honesty more than perfection."';
    } else if (rating == 5) {
      message = '"Good. I trust this data." — Chris Redfield';
    } else {
      message = '"Partial compliance noted. Improve the log next week."';
    }

    return IntegrityResult(
      allowed: true,
      xpAward: xpBonus,
      narrativeMessage: message,
      characterId: rating <= 2 ? 'HUNK' : 'CHRIS',
    );
  }

  // ── Comeback Protocol ────────────────────────────────────

  Future<IntegrityResult?> recordDailyLog() async {
    if (state == null) return null;
    final s = state!;

    s.comebackStreakDays++;
    s.consecutivePerfectDays++;

    // Recover credibility on clean days
    s.credibilityScore = IntegrityService.recoverCredibility(s.credibilityScore);

    if (IntegrityService.shouldAwardComeback(s.comebackStreakDays)) {
      await addXP(IntegrityService.comebackXPBonus);
      s.weskerPower =
          (s.weskerPower - IntegrityService.comebackWeskerReduction)
              .clamp(0, 100);
      await _persist(s);
      return const IntegrityResult(
        allowed: true,
        xpAward: IntegrityService.comebackXPBonus,
        weskerDelta: -IntegrityService.comebackWeskerReduction,
        narrativeMessage:
            '"Took you long enough. But you came back. That\'s something." — Chris',
        characterId: 'CHRIS',
      );
    }

    await _persist(s);
    return null;
  }

  Future<void> resetComeback() async {
    if (state == null) return;
    state!.comebackStreakDays = 0;
    state!.consecutivePerfectDays = 0;
    await _persist(state!);
  }

  // ── Wesker comment accessor ───────────────────────────────

  /// Returns the current Wesker pattern commentary if triggered, else null.
  String? get weskerPatternComment {
    if (state == null) return null;
    return IntegrityService.weskerPatternComment(
      junkFreeDays: state!.junkFreeDayStreak,
      consecutivePerfectDays: state!.consecutivePerfectDays,
      credibilityScore: state!.credibilityScore,
    );
  }

  // ── Private helpers ──────────────────────────────────────

  int _calculateLevel(int xp) {
    return (1 + (xp / 500).floor()).clamp(1, 50);
  }

  Future<void> _calculateAvatarState() async {
    if (state == null) return;
    final s = state!;
    int newState = s.avatarState;
    if (s.level >= 47) {
      newState = 6;
    } else if (s.level >= 38) {
      newState = 5;
    } else if (s.level >= 29) {
      newState = 4;
    } else if (s.level >= 21) {
      newState = 3;
    } else if (s.level >= 13) {
      newState = 2;
    } else if (s.level >= 6) {
      newState = 1;
    }
    // Avatar state never decreases
    if (newState > s.avatarState) {
      s.avatarState = newState;
      await _persist(s);
    }
  }

  Future<void> _persist(UserProfile s) async {
    final box = Hive.box<UserProfile>('userProfileBox');
    await box.putAt(0, s);
    // Emit a new object so Riverpod detects the state change
    state = UserProfile(
      name: s.name,
      startingWeight: s.startingWeight,
      currentWeight: s.currentWeight,
      heightCm: s.heightCm,
      totalXP: s.totalXP,
      level: s.level,
      weskerPower: s.weskerPower,
      avatarState: s.avatarState,
      programmeStart: s.programmeStart,
      currentStreak: s.currentStreak,
      longestStreak: s.longestStreak,
      credibilityScore: s.credibilityScore,
      lastMealLogTime: s.lastMealLogTime,
      waterLogTimestamps: s.waterLogTimestamps,
      consecutivePerfectDays: s.consecutivePerfectDays,
      isRookiePhase: s.isRookiePhase,
      comebackStreakDays: s.comebackStreakDays,
      lastAppCloseTime: s.lastAppCloseTime,
      lastWorkoutStartTime: s.lastWorkoutStartTime,
      isSessionActive: s.isSessionActive,
      lastClaimedSleepHours: s.lastClaimedSleepHours,
      junkFreeDayStreak: s.junkFreeDayStreak,
      gold: s.gold,
      unlockedBuffs: Map.from(s.unlockedBuffs),
    );
  }
}
