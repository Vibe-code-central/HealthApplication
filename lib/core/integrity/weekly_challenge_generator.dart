import '../../models/weekly_challenge.dart';

class WeeklyChallengeGenerator {
  /// Generates a structured WeeklyChallenge expiring on the upcoming Sunday.
  static WeeklyChallenge generateFor(DateTime now) {
    // Expires next Sunday at 23:59
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final nextSunday = now.add(Duration(days: daysUntilSunday));
    final expiresAt = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 23, 59, 59);

    return WeeklyChallenge(
      challengeId: 'wk_${now.millisecondsSinceEpoch}',
      title: 'OPERATION: RELENTLESS',
      description: 'Log 4 Combat Sessions this week.',
      difficulty: 'AMBER',
      requirements: {'combat_sessions': 4},
      progress: {'combat_sessions': 0},
      xpReward: 300,
      completed: false,
      expiresAt: expiresAt,
    );
  }
}
