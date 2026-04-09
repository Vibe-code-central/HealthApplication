import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_profile.dart';
import '../../models/workout_session.dart';
import '../../models/nutrition_log.dart';
import '../../models/muscle_progress.dart';
import '../../models/recovery_log.dart';
import '../../models/character_event.dart';
import '../../models/weekly_challenge.dart';
import '../../models/achievement.dart';

class HiveSetup {
  static Future<void> init() async {
    // Register Adapters
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(WorkoutSessionAdapter());
    Hive.registerAdapter(ExerciseLogAdapter());
    Hive.registerAdapter(SetLogAdapter());
    Hive.registerAdapter(NutritionLogAdapter());
    Hive.registerAdapter(MealEntryAdapter());
    Hive.registerAdapter(MuscleProgressAdapter());
    Hive.registerAdapter(RecoveryLogAdapter());
    Hive.registerAdapter(CharacterEventAdapter());
    Hive.registerAdapter(WeeklyChallengeAdapter());
    Hive.registerAdapter(AchievementAdapter());

    // Open Boxes
    await Hive.openBox<UserProfile>('userProfileBox');
    await Hive.openBox<WorkoutSession>('workoutSessionsBox');
    await Hive.openBox<NutritionLog>('nutritionLogsBox');
    await Hive.openBox<MuscleProgress>('muscleProgressBox');
    await Hive.openBox<RecoveryLog>('recoveryLogsBox');
    await Hive.openBox<CharacterEvent>('characterEventsBox');
    await Hive.openBox<WeeklyChallenge>('weeklyChallengeBox');
    await Hive.openBox<Achievement>('achievementsBox');
  }
}

