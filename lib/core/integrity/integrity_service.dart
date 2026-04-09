/// IntegrityService
///
/// All anti-cheat / honest-logging logic lives here.
/// No UI imports — pure business logic that providers call.
library;

import '../../models/user_profile.dart';

// ══════════════════════════════════════════════════════
// RESULT TYPES
// ══════════════════════════════════════════════════════

/// Returned whenever an action passes or fails an integrity gate.
class IntegrityResult {
  final bool allowed;

  /// Short message shown in the UI (Ada/Chris/Wesker quote).
  final String? narrativeMessage;

  /// Character who speaks this message.
  final String? characterId; // ADA / CHRIS / WESKER / CLAIRE

  /// XP to award (may be reduced by violation factor).
  final int xpAward;

  /// Additional Wesker power delta (positive = gains power).
  final int weskerDelta;

  const IntegrityResult({
    required this.allowed,
    this.narrativeMessage,
    this.characterId,
    this.xpAward = 0,
    this.weskerDelta = 0,
  });

  factory IntegrityResult.blocked(String message, String character) =>
      IntegrityResult(
        allowed: false,
        narrativeMessage: message,
        characterId: character,
      );
}

// ══════════════════════════════════════════════════════
// INTEGRITY SERVICE
// ══════════════════════════════════════════════════════

class IntegrityService {
  // ── Constants ──────────────────────────────────────

  static const int _mealCooldownMinutes = 90;
  static const int _waterMaxPerHour = 2;
  static const int _maxWaterGlasses = 6;
  static const double _suspiciousSessionMinFraction = 0.5;
  static const int _rookiePhaseDays = 14;
  static const double _rookiePenaltyMultiplier = 0.5;
  static const int _comebackStreakThreshold = 3;
  static const int _weskerDecayPerAbsentDay = 2;
  static const int _credibilityDropPerAnomaly = 10;


  // ══════════════════════════════════════════════════
  // 1. MEAL COOLDOWN GATE
  // ══════════════════════════════════════════════════

  /// Returns whether a new meal can be logged right now.
  /// If not, returns a blocked result with Ada's message and remaining wait time.
  static IntegrityResult checkMealCooldown(UserProfile profile) {
    final lastLog = profile.lastMealLogTime;
    if (lastLog == null) return const IntegrityResult(allowed: true);

    final elapsed = DateTime.now().difference(lastLog);
    if (elapsed.inMinutes < _mealCooldownMinutes) {
      final remaining = _mealCooldownMinutes - elapsed.inMinutes;
      return IntegrityResult.blocked(
        'Ration cooldown active. Next log available in ${remaining}m.\n'
        '"Rushing intelligence reports degrades their accuracy, Kennedy."',
        'ADA',
      );
    }
    return const IntegrityResult(allowed: true);
  }

  // ══════════════════════════════════════════════════
  // 2. WATER RATE LIMITER
  // ══════════════════════════════════════════════════

  /// Checks if a water glass can be logged (max 2 per hour).
  static IntegrityResult checkWaterRateLimit(UserProfile profile) {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Filter timestamps from the last rolling hour
    final recentLogs = profile.waterLogTimestamps
        .where((t) => t.isAfter(oneHourAgo))
        .toList();

    if (profile.waterLogTimestamps
            .where((t) =>
                t.year == now.year &&
                t.month == now.month &&
                t.day == now.day)
            .length >=
        _maxWaterGlasses) {
      return IntegrityResult.blocked(
        'Hydration target already met.\n'
        '"More water does not equal more muscle, Kennedy."',
        'ADA',
      );
    }

    if (recentLogs.length >= _waterMaxPerHour) {
      return IntegrityResult.blocked(
        'Hydration protocol: pace your intake. Max 2 glasses per hour.\n'
        '"Ada is monitoring logging accuracy."',
        'ADA',
      );
    }

    return const IntegrityResult(allowed: true);
  }

  // ══════════════════════════════════════════════════
  // 3. SLEEP TIMESTAMP CROSS-CHECK
  // ══════════════════════════════════════════════════

  /// Cross-checks claimed sleep hours against the actual app-close → app-open gap.
  /// If the gap is less than half the claimed sleep, XP is reduced to 50%.
  ///
  /// Returns a result with full XP, reduced XP, or a narrative warning.
  static IntegrityResult checkSleepValidity({
    required double claimedHours,
    required DateTime? lastAppCloseTime,
    required int baseXP,
  }) {
    if (lastAppCloseTime == null) {
      // No timestamp to cross-check — trust the log, full XP
      return IntegrityResult(allowed: true, xpAward: baseXP);
    }

    final gapHours =
        DateTime.now().difference(lastAppCloseTime).inMinutes / 60.0;

    // If claimed sleep is more than 2× the measured gap, flag it
    if (claimedHours > gapHours * 2 && gapHours < 5) {
      return IntegrityResult(
        allowed: true, // still logged, never blocked
        xpAward: (baseXP * 0.5).round(),
        narrativeMessage:
            'Sleep data conflicts with field observation.\n'
            '"These numbers don\'t match field observation, Leon. Log more carefully."',
        characterId: 'CLAIRE',
      );
    }

    return IntegrityResult(allowed: true, xpAward: baseXP);
  }

  // ══════════════════════════════════════════════════
  // 4. SESSION SPEED ANOMALY DETECTION
  // ══════════════════════════════════════════════════

  /// Called when a workout session is completed.
  /// [elapsedMinutes] = minutes since session was started.
  /// [expectedMinutes] = expected session duration.
  ///
  /// If completed in < 50% expected time → suspicious, XP reduced to 70%.
  static IntegrityResult checkSessionSpeed({
    required int elapsedMinutes,
    required int expectedMinutes,
    required int baseXP,
  }) {
    if (elapsedMinutes < (expectedMinutes * _suspiciousSessionMinFraction)) {
      return IntegrityResult(
        allowed: true,
        xpAward: (baseXP * 0.7).round(),
        narrativeMessage:
            'That was fast, Kennedy. Suspiciously fast. Full debrief required.\n'
            '— Mission logged as [UNVERIFIED].',
        characterId: 'CHRIS',
        weskerDelta: 5, // Wesker gains a little — something smells off
      );
    }
    return IntegrityResult(allowed: true, xpAward: baseXP);
  }

  // ══════════════════════════════════════════════════
  // 5. PROGRESSIVE OVERLOAD VALIDATOR
  // ══════════════════════════════════════════════════

  /// Checks if a new logged weight is a realistic progression.
  /// A jump of >20% above previous best triggers a flag.
  ///
  /// Returns: allow (no PB XP if unrealistic), with narrative.
  static IntegrityResult checkProgressiveOverload({
    required double previousBestKg,
    required double newKg,
    required int pbXP,
  }) {
    if (previousBestKg <= 0) {
      // First-ever log — always valid
      return IntegrityResult(allowed: true, xpAward: pbXP);
    }

    final percentageIncrease = (newKg - previousBestKg) / previousBestKg;

    if (percentageIncrease > 0.20) {
      return IntegrityResult(
        allowed: true, // log it, but no PB XP
        xpAward: 0,
        narrativeMessage:
            'Intel conflict detected. Last record: ${previousBestKg}kg. '
            'Current claim: ${newKg}kg.\n'
            '"Those numbers don\'t compute. Prove it next time." — Chris',
        characterId: 'CHRIS',
      );
    }

    return IntegrityResult(allowed: true, xpAward: pbXP);
  }

  // ══════════════════════════════════════════════════
  // 6. STREAK INTEGRITY (Triple-lock)
  // ══════════════════════════════════════════════════

  /// A streak day requires: 1 workout log + 2+ meals + 3+ waters.
  /// Returns true = full streak credit, false = partial (no streak count).
  static bool validateStreakDay({
    required bool hasWorkoutLog, // gym OR home OR rest_day logged
    required int mealCount,
    required int waterGlasses,
  }) {
    return hasWorkoutLog && mealCount >= 2 && waterGlasses >= 3;
  }

  // ══════════════════════════════════════════════════
  // 7. WESKER DECAY (passive, called on app open)
  // ══════════════════════════════════════════════════

  /// Reduces Wesker power when user has been absent (no logging).
  /// Decay: −2 per absent day, capped at current power.
  static int calculateWeskerDecay({
    required int currentPower,
    required DateTime? lastActivityDate,
  }) {
    if (lastActivityDate == null) return 0;

    final absentDays =
        DateTime.now().difference(lastActivityDate).inDays;

    // Decay only kicks in after 1 day of absence
    if (absentDays < 1) return 0;

    final decay = (absentDays * _weskerDecayPerAbsentDay).clamp(0, currentPower);
    return decay;
  }

  // ══════════════════════════════════════════════════
  // 8. ROOKIE PHASE PENALTY MODIFIER
  // ══════════════════════════════════════════════════

  /// Returns penalty multiplier. First 14 days = 0.5× (half penalties).
  static double penaltyMultiplier(UserProfile profile) {
    final daysSinceStart =
        DateTime.now().difference(profile.programmeStart).inDays;
    if (daysSinceStart < _rookiePhaseDays) return _rookiePenaltyMultiplier;
    return 1.0;
  }

  /// Returns whether the rookie phase is still active.
  static bool isRookiePhase(UserProfile profile) {
    final daysSinceStart =
        DateTime.now().difference(profile.programmeStart).inDays;
    return daysSinceStart < _rookiePhaseDays;
  }

  // ══════════════════════════════════════════════════
  // 9. COMEBACK PROTOCOL
  // ══════════════════════════════════════════════════

  /// Call after each logged day. If this is day 3+ of consecutive logging
  /// after a gap of 3+ days, trigger the Comeback Protocol bonus.
  static bool shouldAwardComeback(int comebackStreakDays) {
    return comebackStreakDays == _comebackStreakThreshold;
  }

  static const int comebackXPBonus = 150;
  static const int comebackWeskerReduction = 20;

  // ══════════════════════════════════════════════════
  // 10. FIRST JUNK GRACE (weekly)
  // ══════════════════════════════════════════════════

  /// Returns the junk penalty multiplier for today's Nth junk incident.
  /// 1st incident this week = 50% penalty. 2nd = 100%. 3rd+ = 130%.
  static double junkPenaltyMultiplier(int junkIncidentsThisWeek) {
    if (junkIncidentsThisWeek == 0) return 0.5; // first one this week = grace
    if (junkIncidentsThisWeek == 1) return 1.0;
    return 1.3; // escalating cost
  }

  // ══════════════════════════════════════════════════
  // 11. CREDIBILITY SCORE UPDATES
  // ══════════════════════════════════════════════════

  /// Drops credibility when an anomaly is detected.
  static int penaliseCredibility(int current, {int drop = _credibilityDropPerAnomaly}) {
    return (current - drop).clamp(0, 100);
  }

  /// Slowly recovers credibility on clean days.
  static int recoverCredibility(int current, {int gain = 3}) {
    return (current + gain).clamp(0, 100);
  }

  // ══════════════════════════════════════════════════
  // 12. WESKER COMMENTARY TRIGGERS
  // ══════════════════════════════════════════════════

  /// Returns a Wesker narrative comment triggered by suspicious patterns,
  /// or null if nothing to say.
  static String? weskerPatternComment({
    required int junkFreeDays,
    required int consecutivePerfectDays,
    required int credibilityScore,
  }) {
    // 7 days of zero junk
    if (junkFreeDays == 7) {
      return '"Zero incidents logged... for a full week. I find that improbable, Kennedy."';
    }
    // 14 "perfect" logging days
    if (consecutivePerfectDays == 14) {
      return '"Either you have the discipline of a machine… or you\'re lying to yourself. I suspect the latter."';
    }
    // 21 days
    if (junkFreeDays == 21) {
      return '"You\'re either lying, or you deserve to win. We\'ll see which."';
    }
    // 28 days — genuine acknowledgement
    if (junkFreeDays == 28) {
      return '"Remarkable. You\'ve either broken the pattern… or I\'ve underestimated you, Kennedy."';
    }
    // Low credibility score generic warning
    if (credibilityScore < 50) {
      return '"Your data has… inconsistencies. I\'m watching more closely now, Mr. Kennedy."';
    }
    return null;
  }

  // ══════════════════════════════════════════════════
  // 13. WEEKLY DEBRIEF SELF-RATING XP
  // ══════════════════════════════════════════════════

  /// Maps self-rating (1–5) to XP bonus and credibility change.
  static ({int xpBonus, int credibilityChange}) weeklyDebriefXP(int rating) {
    return switch (rating) {
      1 => (xpBonus: 0, credibilityChange: 5),    // honest = small credibility gain
      2 => (xpBonus: 10, credibilityChange: 8),
      3 => (xpBonus: 20, credibilityChange: 10),
      4 => (xpBonus: 30, credibilityChange: 5),
      5 => (xpBonus: 25, credibilityChange: 0),   // claiming perfect on imperfable week = no bonus
      _ => (xpBonus: 0, credibilityChange: 0),
    };
  }
}
