import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  String name;

  @HiveField(1)
  double startingWeight;

  @HiveField(2)
  double currentWeight;

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  int totalXP;

  @HiveField(5)
  int level; // 1-50

  @HiveField(6)
  int weskerPower; // 0-100

  @HiveField(7)
  int avatarState; // 0-6

  @HiveField(8)
  DateTime programmeStart;

  @HiveField(9)
  int currentStreak;

  @HiveField(10)
  int longestStreak;

  // ── Integrity System Fields ──────────────────────

  /// Hidden 0–100 score. Low = suspicious logging pattern detected.
  @HiveField(11)
  int credibilityScore;

  /// Timestamp of the last meal that was logged (for meal cooldown gate).
  @HiveField(12)
  DateTime? lastMealLogTime;

  /// List of timestamps of today's water logs (for hourly rate-limit).
  @HiveField(13)
  List<DateTime> waterLogTimestamps;

  /// Today's count of logs across all categories (workout/meals/water).
  @HiveField(14)
  int consecutivePerfectDays; // triggers Wesker credibility comment at 14+

  /// Whether user is in the rookie 2-week grace period (reduced penalties).
  @HiveField(15)
  bool isRookiePhase;

  /// Days of consistent logging after returning from a gap (comeback protocol).
  @HiveField(16)
  int comebackStreakDays;

  /// Last time the app was opened — used to cross-check claimed sleep hrs.
  @HiveField(17)
  DateTime? lastAppCloseTime;

  /// Timestamp of when the last workout session was started.
  @HiveField(18)
  DateTime? lastWorkoutStartTime;

  /// Whether an active workout session is currently running.
  @HiveField(19)
  bool isSessionActive;

  /// The last claimed sleep hours (cross-checked against app timestamps).
  @HiveField(20)
  double? lastClaimedSleepHours;

  /// Count of junk-free days in rolling 7-day window (for Wesker commentary).
  @HiveField(21)
  int junkFreeDayStreak;

  UserProfile({
    required this.name,
    required this.startingWeight,
    required this.currentWeight,
    required this.heightCm,
    required this.totalXP,
    required this.level,
    required this.weskerPower,
    required this.avatarState,
    required this.programmeStart,
    required this.currentStreak,
    required this.longestStreak,
    this.credibilityScore = 100,
    this.lastMealLogTime,
    this.waterLogTimestamps = const [],
    this.consecutivePerfectDays = 0,
    this.isRookiePhase = true,
    this.comebackStreakDays = 0,
    this.lastAppCloseTime,
    this.lastWorkoutStartTime,
    this.isSessionActive = false,
    this.lastClaimedSleepHours,
    this.junkFreeDayStreak = 0,
  });
}
