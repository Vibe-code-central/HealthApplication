/// ScoreService — calculates daily score, grade, and rank from app state.
/// Pure functions — no state, no side effects.
library;

class DailyScore {
  final int score;      // 0–100
  final String grade;   // S / A / B / C / D / F
  final int xpMultiplier; // streak bonus multiplier (100 = 1×, 125 = 1.25×)
  final Map<String, int> breakdown; // label → points contributed

  const DailyScore({
    required this.score,
    required this.grade,
    required this.xpMultiplier,
    required this.breakdown,
  });
}

class ScoreService {
  // ── Score Calculation ────────────────────────────────

  /// Calculates today's score from:
  ///  - Task completion ratio         (max 50 pts)
  ///  - Workout session completed       (15 pts)
  ///  - Protein target hit              (10 pts)
  ///  - Zero junk today                 (10 pts)
  ///  - Water target (6 glasses)         (8 pts)
  ///  - Sleep logged                     (7 pts)
  ///                                   ─────────────
  ///                                   Total: 100 pts
  static DailyScore calculate({
    required int tasksCompleted,
    required int tasksTotal,
    required bool workoutDone,
    required bool proteinTargetHit,
    required bool zeroJunkToday,
    required bool waterTargetHit,
    required bool sleepLogged,
    required int streakDays,
  }) {
    final breakdown = <String, int>{};

    // Task ratio
    final taskPercent =
        tasksTotal == 0 ? 0 : (tasksCompleted / tasksTotal * 50).round();
    breakdown['TASK COMPLETION'] = taskPercent;

    // Workout bonus
    final workoutBonus = workoutDone ? 15 : 0;
    breakdown['SESSION LOGGED'] = workoutBonus;

    // Protein bonus
    final proteinBonus = proteinTargetHit ? 10 : 0;
    breakdown['PROTEIN TARGET'] = proteinBonus;

    // Junk-free bonus
    final junkBonus = zeroJunkToday ? 10 : 0;
    breakdown['ZERO JUNK'] = junkBonus;

    // Water bonus
    final waterBonus = waterTargetHit ? 8 : 0;
    breakdown['HYDRATION'] = waterBonus;

    // Sleep bonus
    final sleepBonus = sleepLogged ? 7 : 0;
    breakdown['SLEEP LOGGED'] = sleepBonus;

    final raw = taskPercent +
        workoutBonus +
        proteinBonus +
        junkBonus +
        waterBonus +
        sleepBonus;
    final capped = raw.clamp(0, 100);

    return DailyScore(
      score: capped,
      grade: _grade(capped),
      xpMultiplier: _xpMultiplier(streakDays),
      breakdown: breakdown,
    );
  }

  // ── Grade ─────────────────────────────────────────────

  static String _grade(int score) => switch (score) {
        >= 95 => 'S',
        >= 80 => 'A',
        >= 65 => 'B',
        >= 50 => 'C',
        >= 35 => 'D',
        _ => 'F',
      };

  static String gradeColor(String grade) => switch (grade) {
        'S' => 'REQUIEM',
        'A' => 'OPERATIVE',
        'B' => 'GOLD',
        'C' => 'INTEL',
        'D' => 'EMBER',
        _ => 'RED',
      };

  static String gradeQuote(String grade) => switch (grade) {
        'S' => '"Outstanding. File this under \'reference performance.\'" — Chris',
        'A' => '"Strong showing today, Kennedy. Repeat it." — Chris',
        'B' => '"Adequate. There\'s room. Use it." — Ada',
        'C' => '"Mediocre. Wesker noticed." — Wesker',
        'D' => '"Below standard. Unacceptable." — Chris',
        _ => '"You\'ve given Wesker exactly what he wanted." — Ada',
      };

  // ── Streak multiplier ─────────────────────────────────

  /// Returns XP multiplier as integer percentage (100 = 1×).
  ///  7 days  → 110 (1.1×)
  /// 14 days  → 125 (1.25×)
  /// 30 days  → 150 (1.5×)
  static int _xpMultiplier(int streakDays) {
    if (streakDays >= 30) return 150;
    if (streakDays >= 14) return 125;
    if (streakDays >= 7) return 110;
    return 100;
  }

  static String multiplierLabel(int multiplier) {
    if (multiplier <= 100) return '1×';
    final pct = multiplier - 100;
    return '1.${(pct).toString().padLeft(2, '0').replaceAll(RegExp(r'0+$'), '')}×';
  }

  // ── Rank ──────────────────────────────────────────────

  static String rankName(int level) => switch (level) {
        >= 47 => 'REQUIEM',
        >= 38 => 'ELITE OPERATIVE',
        >= 29 => 'VETERAN OPERATIVE',
        >= 21 => 'GOV. OPERATIVE',
        >= 13 => 'FIELD AGENT',
        >= 6 => 'RECRUIT',
        _ => 'RACCOON ROOKIE',
      };

  static String rankColor(int level) => switch (level) {
        >= 47 => 'REQUIEM',
        >= 29 => 'GOLD',
        >= 13 => 'OPERATIVE',
        _ => 'RED',
      };
}
