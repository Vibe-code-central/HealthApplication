/// DailyTask — a single checklist item for the day.
/// Not Hive-persisted; generated fresh each day from [DailyTaskGenerator].
class DailyTask {
  final String id;
  final String title;
  final String? subtitle;
  final DailyTaskCategory category;
  final int xpReward;
  final int weskerPenalty; // if not completed by end of day
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.xpReward,
    this.weskerPenalty = 0,
    this.isCompleted = false,
  });

  DailyTask copyWith({bool? isCompleted}) => DailyTask(
        id: id,
        title: title,
        subtitle: subtitle,
        category: category,
        xpReward: xpReward,
        weskerPenalty: weskerPenalty,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

enum DailyTaskCategory {
  workout,
  nutrition,
  hydration,
  recovery,
  mission,
  nemesis,
}

extension DailyTaskCategoryX on DailyTaskCategory {
  String get label {
    switch (this) {
      case DailyTaskCategory.workout:
        return 'COMBAT';
      case DailyTaskCategory.nutrition:
        return 'NUTRITION';
      case DailyTaskCategory.hydration:
        return 'HYDRATION';
      case DailyTaskCategory.recovery:
        return 'RECOVERY';
      case DailyTaskCategory.mission:
        return 'MISSION';
      case DailyTaskCategory.nemesis:
        return 'NEMESIS PURSUIT';
    }
  }
}

// ──────────────────────────────────────────────────────────

/// Workout programme — day-of-week mapped to exercises.
class DailyTaskGenerator {
  static List<DailyTask> generateFor(DateTime date, {int weskerPower = 0}) {
    final tasks = <DailyTask>[];

    // ── Workout tasks (day-specific) ────────────────────
    tasks.addAll(_workoutTasks(date));

    // ── Nutrition tasks (same every day) ───────────────
    tasks.addAll(_nutritionTasks());

    // ── Recovery tasks (same every day) ────────────────
    tasks.addAll(_recoveryTasks());

    // ── Nemesis Pursuit ────────────────────────────────
    if (weskerPower >= 60) {
      tasks.add(_generateNemesis(date));
    }

    return tasks;
  }

  static List<DailyTask> _workoutTasks(DateTime date) {
    final day = date.weekday; // 1=Mon … 7=Sun

    switch (day) {
      case DateTime.monday: // Chest + Triceps
        return [
          _exercise('wk_bench', 'Barbell Bench Press', '3 sets × 10–12 reps', 25),
          _exercise('wk_incline', 'Incline DB Press', '3 sets × 10–12 reps', 25),
          _exercise('wk_flys', 'Cable Flys', '3 sets × 12–15 reps', 20),
          _exercise('wk_pushdown', 'Tricep Pushdown', '3 sets × 12–15 reps', 20),
          _exercise('wk_overhead', 'Overhead Tricep Extension', '3 sets × 12–15 reps', 20),
          _missionTask('wk_session', 'Complete Chest + Triceps Session',
              'Monday — Gym Day', 40, weskerPenalty: 15),
        ];
      case DateTime.tuesday: // Back + Biceps
        return [
          _exercise('wk_pulldown', 'Lat Pulldown', '3 sets × 10–12 reps', 25),
          _exercise('wk_row', 'Seated Cable Row', '3 sets × 10–12 reps', 25),
          _exercise('wk_deadlift', 'Romanian Deadlift', '3 sets × 8–10 reps', 30),
          _exercise('wk_curl', 'Barbell Curl', '3 sets × 10–12 reps', 20),
          _exercise('wk_hammer', 'Hammer Curl', '3 sets × 12–15 reps', 20),
          _missionTask('wk_session', 'Complete Back + Biceps Session',
              'Tuesday — Gym Day', 40, weskerPenalty: 15),
        ];
      case DateTime.wednesday: // Home Active Recovery
        return [
          _exercise('wk_pushup', 'Push-ups', '3 sets × 15–20 reps', 15),
          _exercise('wk_plank', 'Plank', '3 sets × 45–60 sec', 15),
          _exercise('wk_squat', 'Bodyweight Squats', '3 sets × 20 reps', 15),
          _exercise('wk_lunge', 'Walking Lunges', '3 sets × 10 each leg', 15),
          _exercise('wk_walk', '30-min Walk or Light Cardio', 'Keep heart rate lower', 20),
          _missionTask('wk_session', 'Complete Home Recovery Session',
              'Wednesday — Active Rest', 30, weskerPenalty: 10),
        ];
      case DateTime.thursday: // Legs + Core
        return [
          _exercise('wk_squat_bar', 'Barbell Squat', '3 sets × 8–10 reps', 30),
          _exercise('wk_legpress', 'Leg Press', '3 sets × 10–12 reps', 25),
          _exercise('wk_legcurl', 'Lying Leg Curl', '3 sets × 12–15 reps', 20),
          _exercise('wk_calf', 'Standing Calf Raise', '4 sets × 15–20 reps', 15),
          _exercise('wk_core', 'Ab Wheel Rollout / Crunches', '3 sets × 15 reps', 15),
          _missionTask('wk_session', 'Complete Legs + Core Session',
              'Thursday — Gym Day', 40, weskerPenalty: 15),
        ];
      case DateTime.friday: // Shoulders + Finisher
        return [
          _exercise('wk_ohp', 'Overhead Press (BB or DB)', '3 sets × 10–12 reps', 25),
          _exercise('wk_lateral', 'Lateral Raises', '4 sets × 15 reps', 20),
          _exercise('wk_face', 'Face Pulls', '3 sets × 15–20 reps', 20),
          _exercise('wk_shrug', 'Dumbbell Shrugs', '3 sets × 15 reps', 15),
          _exercise('wk_finisher', 'Finisher — 5-min AMRAP Burpees', 'Go all out', 30),
          _missionTask('wk_session', 'Complete Shoulders + Finisher',
              'Friday — Gym Day', 40, weskerPenalty: 15),
        ];
      case DateTime.saturday: //  Rest / Optional Cardio
        return [
          _missionTask('wk_rest', 'Rest Day — No Training Required',
              'Saturday — Recovery', 10),
          _exercise('wk_optional', 'Optional: 20-min Walk or Stretch',
              'Bonus recovery activity', 15),
        ];
      case DateTime.sunday: // Rest
        return [
          _missionTask('wk_rest', 'Rest Day — Full Recovery',
              'Sunday — Rest', 10),
          _exercise('wk_mobility', 'Optional: Mobility / Foam Rolling',
              '15–20 mins', 15),
        ];
      default:
        return [];
    }
  }

  static List<DailyTask> _nutritionTasks() => [
        DailyTask(
          id: 'nut_protein',
          title: 'Hit 160g Protein',
          subtitle: 'Log all meals to track progress',
          category: DailyTaskCategory.nutrition,
          xpReward: 40,
          weskerPenalty: 10,
        ),
        DailyTask(
          id: 'nut_meal1',
          title: 'Log Breakfast',
          subtitle: 'Eggs, milk, oats — start strong',
          category: DailyTaskCategory.nutrition,
          xpReward: 10,
        ),
        DailyTask(
          id: 'nut_meal2',
          title: 'Log Lunch',
          subtitle: 'Chicken / dal / rice — main protein hit',
          category: DailyTaskCategory.nutrition,
          xpReward: 10,
        ),
        DailyTask(
          id: 'nut_meal3',
          title: 'Log Dinner',
          subtitle: 'Balanced — no skipping',
          category: DailyTaskCategory.nutrition,
          xpReward: 10,
        ),
        DailyTask(
          id: 'nut_snack',
          title: 'Log Pre/Post-Workout Snack',
          subtitle: 'Banana, chana, protein source',
          category: DailyTaskCategory.nutrition,
          xpReward: 10,
        ),
        DailyTask(
          id: 'nut_nojunk',
          title: 'Zero Junk / Sugar Drinks Today',
          subtitle: 'No cold drinks, fried, chips',
          category: DailyTaskCategory.nutrition,
          xpReward: 20,
          weskerPenalty: 15,
        ),
      ];

  static List<DailyTask> _recoveryTasks() => [
        DailyTask(
          id: 'rec_water',
          title: 'Drink 6 Glasses of Water',
          subtitle: 'Log each one as you drink',
          category: DailyTaskCategory.hydration,
          xpReward: 20,
          weskerPenalty: 5,
        ),
        DailyTask(
          id: 'rec_sleep',
          title: 'Log Last Night\'s Sleep',
          subtitle: 'Target: 7+ hours',
          category: DailyTaskCategory.recovery,
          xpReward: 30,
          weskerPenalty: 8,
        ),
        DailyTask(
          id: 'rec_steps',
          title: 'Stay Active During Commute',
          subtitle: 'Walk when you can — 2hr commute tip',
          category: DailyTaskCategory.recovery,
          xpReward: 10,
        ),
      ];

  // ── Helpers ────────────────────────────────────────────

  static DailyTask _exercise(
          String id, String name, String detail, int xp) =>
      DailyTask(
        id: id,
        title: name,
        subtitle: detail,
        category: DailyTaskCategory.workout,
        xpReward: xp,
      );

  static DailyTask _missionTask(
    String id,
    String title,
    String subtitle,
    int xp, {
    int weskerPenalty = 0,
  }) =>
      DailyTask(
        id: id,
        title: title,
        subtitle: subtitle,
        category: DailyTaskCategory.mission,
        xpReward: xp,
        weskerPenalty: weskerPenalty,
      );

  static DailyTask _generateNemesis(DateTime date) {
    // Deterministic random so the task doesn't flip out during the same day
    final seed = date.year * 1000 + date.month * 100 + date.day;
    final options = [
      DailyTask(
        id: 'nemesis_1',
        title: 'NEMESIS SPAWNED: 50 Burpees',
        subtitle: 'Wesker influence critical. Containment required.',
        category: DailyTaskCategory.nemesis,
        xpReward: 200,
        weskerPenalty: 40,
      ),
      DailyTask(
        id: 'nemesis_2',
        title: 'NEMESIS SPAWNED: 100 Push-ups',
        subtitle: 'Neutralize the threat immediately.',
        category: DailyTaskCategory.nemesis,
        xpReward: 200,
        weskerPenalty: 40,
      ),
      DailyTask(
        id: 'nemesis_3',
        title: 'NEMESIS SPAWNED: 5 Min Plank Hold',
        subtitle: 'Hold the line. Do not break.',
        category: DailyTaskCategory.nemesis,
        xpReward: 200,
        weskerPenalty: 40,
      ),
    ];
    return options[seed % options.length];
  }
}
