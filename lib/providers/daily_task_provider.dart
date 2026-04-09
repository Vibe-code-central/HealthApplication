import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task.dart';
import 'user_provider.dart';

final dailyTaskProvider =
    StateNotifierProvider<DailyTaskNotifier, List<DailyTask>>((ref) {
  return DailyTaskNotifier(ref);
});

class DailyTaskNotifier extends StateNotifier<List<DailyTask>> {
  final Ref _ref;
  static const String _prefKey = 'daily_task_completed_ids';
  static const String _prefDateKey = 'daily_task_date';

  DailyTaskNotifier(this._ref) : super([]) {
    Future.microtask(_init);
  }

  Future<void> _init() async {
    final today = DateTime.now();
    final tasks = DailyTaskGenerator.generateFor(today);

    // Load persisted completions for today
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_prefDateKey);
    final todayStr = _dayKey(today);

    if (savedDate == todayStr) {
      // Same day — restore which tasks were ticked
      final completedIds =
          prefs.getStringList(_prefKey)?.toSet() ?? <String>{};
      for (final task in tasks) {
        task.isCompleted = completedIds.contains(task.id);
      }
    } else {
      // New day — clear old completions
      await prefs.setString(_prefDateKey, todayStr);
      await prefs.setStringList(_prefKey, []);
    }

    state = tasks;
  }

  /// Toggle a task's completion and award XP if just completed.
  Future<void> toggleTask(String taskId) async {
    final index = state.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = state[index];
    final nowCompleted = !task.isCompleted;

    // Update state
    final updated = List<DailyTask>.from(state);
    updated[index] = task.copyWith(isCompleted: nowCompleted);
    state = updated;

    // Persist
    await _persistCompletions(updated);

    // Award / revoke XP
    if (nowCompleted) {
      await _ref.read(userProvider.notifier).addXP(task.xpReward);
    } else {
      // Un-checking refunds XP so users can correct accidental ticks
      await _ref.read(userProvider.notifier).removeXP(task.xpReward);
    }
  }

  // ── Computed helpers ────────────────────────────────────

  int get totalTasks => state.length;

  int get completedCount => state.where((t) => t.isCompleted).length;

  double get completionPercent =>
      totalTasks == 0 ? 0.0 : completedCount / totalTasks;

  List<DailyTask> get byCategory {
    // Sort: incomplete first, then completed at bottom
    final list = List<DailyTask>.from(state);
    list.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.category.index.compareTo(b.category.index);
      }
      return a.isCompleted ? 1 : -1;
    });
    return list;
  }

  String get dayLabel {
    final day = DateTime.now().weekday;
    const labels = {
      DateTime.monday: 'MONDAY — CHEST + TRICEPS',
      DateTime.tuesday: 'TUESDAY — BACK + BICEPS',
      DateTime.wednesday: 'WEDNESDAY — HOME RECOVERY',
      DateTime.thursday: 'THURSDAY — LEGS + CORE',
      DateTime.friday: 'FRIDAY — SHOULDERS + FINISHER',
      DateTime.saturday: 'SATURDAY — REST DAY',
      DateTime.sunday: 'SUNDAY — FULL RECOVERY',
    };
    return labels[day] ?? 'TODAY\'S OPERATIONS';
  }

  // ── Persistence ─────────────────────────────────────────

  Future<void> _persistCompletions(List<DailyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds =
        tasks.where((t) => t.isCompleted).map((t) => t.id).toList();
    await prefs.setStringList(_prefKey, completedIds);
  }

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
