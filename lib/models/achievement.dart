import 'package:hive/hive.dart';

part 'achievement.g.dart';

/// The full catalogue of achievements in Project Requiem.
enum AchievementId {
  firstBlood,         // First workout logged
  ironWill,           // 7-day streak
  biohazardProtocol,  // 14-day streak
  requiemOperative,   // 30-day streak
  cleanSlate,         // 7 days zero junk
  doubleAgent,        // 14 days zero junk
  proteinMachine,     // Hit 160g protein 3 days in a row
  zeroCompromise,     // Perfect day (100% score)
  fieldCommander,     // 3 perfect days in one week
  hydrationProtocol,  // 6 glasses 5 days in a row
  nemesisHunter,      // Wesker @ 0
  rookieGrad,         // Finish rookie phase (14 days)
  comebackKid,        // Comeback protocol triggered
  centurion,          // Reach level 10
  legend,             // Reach level 25
}

@HiveType(typeId: 10)
class Achievement {
  @HiveField(0)
  final String id; // AchievementId.name

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String narrativeQuote; // in-universe unlock flavour text

  @HiveField(4)
  final String character; // WHO delivers the quote

  @HiveField(5)
  final int xpReward;

  @HiveField(6)
  bool isUnlocked;

  @HiveField(7)
  DateTime? unlockedAt;

  @HiveField(8)
  final String iconCode; // Material Icons codepoint as hex string

  @HiveField(9)
  final String tier; // BRONZE / SILVER / GOLD / REQUIEM

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.narrativeQuote,
    required this.character,
    required this.xpReward,
    required this.iconCode,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

/// Returns the full catalogue of achievements with default (locked) state.
List<Achievement> buildAchievementCatalogue() => [
      Achievement(
        id: AchievementId.firstBlood.name,
        title: 'FIRST BLOOD',
        description: 'Complete your first workout session.',
        narrativeQuote: '"Everyone starts somewhere, Kennedy. Don\'t stop now." — Chris',
        character: 'CHRIS',
        xpReward: 50,
        iconCode: 'e838', // fitness_center
        tier: 'BRONZE',
      ),
      Achievement(
        id: AchievementId.ironWill.name,
        title: 'IRON WILL',
        description: 'Maintain a 7-day logging streak.',
        narrativeQuote: '"Seven days. The virus doesn\'t take breaks either." — Chris',
        character: 'CHRIS',
        xpReward: 100,
        iconCode: 'e1b2', // security
        tier: 'SILVER',
      ),
      Achievement(
        id: AchievementId.biohazardProtocol.name,
        title: 'BIOHAZARD PROTOCOL',
        description: 'Maintain a 14-day logging streak.',
        narrativeQuote: '"Two weeks without deviation. You\'re starting to believe." — Ada',
        character: 'ADA',
        xpReward: 200,
        iconCode: 'e3f1', // warning_amber
        tier: 'SILVER',
      ),
      Achievement(
        id: AchievementId.requiemOperative.name,
        title: 'REQUIEM OPERATIVE',
        description: 'Maintain a 30-day logging streak.',
        narrativeQuote: '"Thirty days. Even I\'m impressed, Mr. Kennedy." — Ada',
        character: 'ADA',
        xpReward: 500,
        iconCode: 'e153', // star
        tier: 'GOLD',
      ),
      Achievement(
        id: AchievementId.cleanSlate.name,
        title: 'CLEAN SLATE',
        description: 'Log zero junk food for 7 consecutive days.',
        narrativeQuote: '"Discipline over appetite. The virus feeds on weakness." — Ada',
        character: 'ADA',
        xpReward: 150,
        iconCode: 'e86c', // check_circle
        tier: 'SILVER',
      ),
      Achievement(
        id: AchievementId.doubleAgent.name,
        title: 'DOUBLE AGENT',
        description: 'Zero junk food for 14 consecutive days.',
        narrativeQuote: '"Fourteen days. Wesker didn\'t think you had it in you." — Ada',
        character: 'ADA',
        xpReward: 300,
        iconCode: 'e8bf', // verified
        tier: 'GOLD',
      ),
      Achievement(
        id: AchievementId.proteinMachine.name,
        title: 'PROTEIN MACHINE',
        description: 'Hit 160g protein target 3 days in a row.',
        narrativeQuote: '"Muscle memory. Muscle mass. Both earned." — Chris',
        character: 'CHRIS',
        xpReward: 100,
        iconCode: 'e838', // fitness_center
        tier: 'BRONZE',
      ),
      Achievement(
        id: AchievementId.zeroCompromise.name,
        title: 'ZERO COMPROMISE',
        description: 'Score 100% on a single day.',
        narrativeQuote: '"A perfect mission. File it under \'impossible.\'" — HUNK',
        character: 'HUNK',
        xpReward: 150,
        iconCode: 'e153', // star
        tier: 'SILVER',
      ),
      Achievement(
        id: AchievementId.fieldCommander.name,
        title: 'FIELD COMMANDER',
        description: 'Achieve 3 perfect days in a single week.',
        narrativeQuote: '"Three consecutive clean days. Command is watching." — Chris',
        character: 'CHRIS',
        xpReward: 250,
        iconCode: 'e0e0', // military_tech
        tier: 'GOLD',
      ),
      Achievement(
        id: AchievementId.hydrationProtocol.name,
        title: 'HYDRATION PROTOCOL',
        description: 'Log 6 glasses of water for 5 days.',
        narrativeQuote: '"The human body is 60% water. Protect your asset." — Ada',
        character: 'ADA',
        xpReward: 75,
        iconCode: 'e798', // water_drop
        tier: 'BRONZE',
      ),
      Achievement(
        id: AchievementId.nemesisHunter.name,
        title: 'NEMESIS HUNTER',
        description: 'Reduce Wesker\'s power to 0%.',
        narrativeQuote: '"Wesker... neutralised. This is what discipline looks like." — Chris',
        character: 'CHRIS',
        xpReward: 300,
        iconCode: 'e645', // visibility_off
        tier: 'GOLD',
      ),
      Achievement(
        id: AchievementId.rookieGrad.name,
        title: 'ROOKIE GRADUATION',
        description: 'Complete the 14-day rookie phase.',
        narrativeQuote: '"You\'ve graduated. No more training wheels, Kennedy." — Chris',
        character: 'CHRIS',
        xpReward: 100,
        iconCode: 'e5c8', // school
        tier: 'BRONZE',
      ),
      Achievement(
        id: AchievementId.comebackKid.name,
        title: 'COMEBACK KID',
        description: 'Return after a missed day and log 3 consecutive days.',
        narrativeQuote: '"You came back. That counts for more than you know." — Chris',
        character: 'CHRIS',
        xpReward: 80,
        iconCode: 'e8b4', // replay
        tier: 'BRONZE',
      ),
      Achievement(
        id: AchievementId.centurion.name,
        title: 'CENTURION',
        description: 'Reach Level 10.',
        narrativeQuote: '"Level 10. You\'re no longer a liability." — Chris',
        character: 'CHRIS',
        xpReward: 200,
        iconCode: 'e153', // star
        tier: 'SILVER',
      ),
      Achievement(
        id: AchievementId.legend.name,
        title: 'REQUIEM LEGEND',
        description: 'Reach Level 25.',
        narrativeQuote: '"Level 25. I\'m running out of reasons to doubt you." — Wesker',
        character: 'WESKER',
        xpReward: 500,
        iconCode: 'e3f0', // bolt
        tier: 'REQUIEM',
      ),
    ];
