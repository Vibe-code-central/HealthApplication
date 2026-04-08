import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_session.dart';

final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<WorkoutSession>>((ref) {
  return WorkoutNotifier();
});

class WorkoutNotifier extends StateNotifier<List<WorkoutSession>> {
  WorkoutNotifier() : super([]) {
    _loadSessions();
  }

  void _loadSessions() {
    final box = Hive.box<WorkoutSession>('workoutSessionsBox');
    state = box.values.toList().cast<WorkoutSession>();
  }
}
