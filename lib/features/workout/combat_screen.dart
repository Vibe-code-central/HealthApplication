import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../models/daily_task.dart';
import '../../providers/daily_task_provider.dart';

class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({super.key});

  @override
  ConsumerState<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen> {
  // Track which exercise cards are expanded
  final Set<String> _expanded = {};
  // kg / reps per set: exerciseId -> setIndex -> {kg, reps}
  final Map<String, List<Map<String, String>>> _setData = {};
  // Which sets have been confirmed (checked off)
  final Map<String, Set<int>> _completedSets = {};

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(dailyTaskProvider);
    final notifier = ref.read(dailyTaskProvider.notifier);

    // Only show workout tasks
    final workoutTasks = tasks
        .where((t) =>
            t.category == DailyTaskCategory.workout ||
            t.category == DailyTaskCategory.mission)
        .toList();

    final exerciseTasks =
        workoutTasks.where((t) => t.category == DailyTaskCategory.workout).toList();
    final missionTask =
        workoutTasks.where((t) => t.category == DailyTaskCategory.mission).toList();

    final sessionCompleted =
        missionTask.isNotEmpty && missionTask.first.isCompleted;

    return Scaffold(
      backgroundColor: RequiemColors.primaryBackground,
      appBar: AppBar(
        title: Text(notifier.dayLabel),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Chris Briefing ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: RePanel(
                borderColor: RequiemColors.operative.withOpacity(0.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: RequiemColors.operative, width: 1.5),
                        color: RequiemColors.operative.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.military_tech,
                          color: RequiemColors.operative, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CHRIS REDFIELD — BRIEFING',
                              style: GoogleFonts.barlowCondensed(
                                  color: RequiemColors.operative,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                          const SizedBox(height: 4),
                          Text(
                            _briefingText(),
                            style: GoogleFonts.barlow(
                                color: RequiemColors.textPrimary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Progress ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _SessionProgress(
                exercises: exerciseTasks,
                completedSets: _completedSets,
              ),
            ),
          ),

          // ── Exercise List ────────────────────────────
          const SliverToBoxAdapter(
            child: ReDividerHeader(
              label: 'MISSION OBJECTIVES',
              color: RequiemColors.operative,
              icon: Icons.fitness_center,
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final task = exerciseTasks[i];
                _setData.putIfAbsent(task.id, () => [
                  {'kg': '', 'reps': ''},
                  {'kg': '', 'reps': ''},
                  {'kg': '', 'reps': ''},
                ]);
                _completedSets.putIfAbsent(task.id, () => {});

                return _ExerciseCard(
                  task: task,
                  index: i + 1,
                  isExpanded: _expanded.contains(task.id),
                  setData: _setData[task.id]!,
                  completedSets: _completedSets[task.id]!,
                  onToggleExpand: () => setState(() {
                    if (_expanded.contains(task.id)) {
                      _expanded.remove(task.id);
                    } else {
                      _expanded.add(task.id);
                    }
                  }),
                  onSetChecked: (setIndex) {
                    setState(() {
                      final sets = _completedSets[task.id]!;
                      if (sets.contains(setIndex)) {
                        sets.remove(setIndex);
                      } else {
                        sets.add(setIndex);
                        // If all 3 sets done → tick the task
                        if (sets.length == 3 && !task.isCompleted) {
                          ref
                              .read(dailyTaskProvider.notifier)
                              .toggleTask(task.id);
                        }
                      }
                    });
                  },
                  onKgChanged: (si, v) =>
                      setState(() => _setData[task.id]![si]['kg'] = v),
                  onRepsChanged: (si, v) =>
                      setState(() => _setData[task.id]![si]['reps'] = v),
                );
              },
              childCount: exerciseTasks.length,
            ),
          ),

          // ── Complete Session Button ──────────────────
          if (missionTask.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _CompleteSessionButton(
                  task: missionTask.first,
                  isCompleted: sessionCompleted,
                  onTap: () => ref
                      .read(dailyTaskProvider.notifier)
                      .toggleTask(missionTask.first.id),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _briefingText() {
    final day = DateTime.now().weekday;
    return switch (day) {
      DateTime.monday => '"Chest and triceps today. Full effort — three sets each. No skipping, Kennedy."',
      DateTime.tuesday => '"Back and biceps. Pull hard. Every rep counts against Wesker."',
      DateTime.wednesday => '"Active recovery day. Keep moving — no excuses."',
      DateTime.thursday => '"Legs. The mission doesn\'t care if you\'re sore."',
      DateTime.friday => '"Shoulders and finisher. End the week strong, operative."',
      _ => '"Rest day. Recover smart. You\'ve earned it."',
    };
  }
}

// ── Session Progress ──────────────────────────────────────────────────────────

class _SessionProgress extends StatelessWidget {
  final List<DailyTask> exercises;
  final Map<String, Set<int>> completedSets;

  const _SessionProgress(
      {required this.exercises, required this.completedSets});

  @override
  Widget build(BuildContext context) {
    final completedCount = exercises.where((t) => t.isCompleted).length;
    final total = exercises.length;
    final progress = total == 0 ? 0.0 : completedCount / total;

    return RePanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SESSION PROGRESS',
                    style: GoogleFonts.barlowCondensed(
                        color: RequiemColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 2)),
                const SizedBox(height: 6),
                ReStatusBar(
                    value: progress,
                    color: RequiemColors.operative,
                    height: 6),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text('$completedCount/$total',
              style: GoogleFonts.bebasNeue(
                  color: progress == 1.0
                      ? RequiemColors.operative
                      : RequiemColors.textPrimary,
                  fontSize: 28,
                  letterSpacing: 1)),
        ],
      ),
    );
  }
}

// ── Exercise Card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final DailyTask task;
  final int index;
  final bool isExpanded;
  final List<Map<String, String>> setData;
  final Set<int> completedSets;
  final VoidCallback onToggleExpand;
  final void Function(int setIndex) onSetChecked;
  final void Function(int setIndex, String value) onKgChanged;
  final void Function(int setIndex, String value) onRepsChanged;

  const _ExerciseCard({
    required this.task,
    required this.index,
    required this.isExpanded,
    required this.setData,
    required this.completedSets,
    required this.onToggleExpand,
    required this.onSetChecked,
    required this.onKgChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    final borderColor = isDone
        ? RequiemColors.operative
        : RequiemColors.borderBright;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: RequiemColors.secondarySurface,
          border: Border(
            left: BorderSide(
                color: isDone
                    ? RequiemColors.operative
                    : RequiemColors.tertiarySurface,
                width: 2),
            top: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Header row
            InkWell(
              onTap: onToggleExpand,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDone
                                ? RequiemColors.operative
                                : RequiemColors.textMuted,
                            width: 1.5),
                        color: isDone
                            ? RequiemColors.operative.withOpacity(0.15)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check,
                                size: 14,
                                color: RequiemColors.operative)
                            : Text('$index',
                                style: GoogleFonts.barlowCondensed(
                                    color: RequiemColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title,
                              style: GoogleFonts.barlow(
                                  color: isDone
                                      ? RequiemColors.textSecondary
                                      : RequiemColors.textPrimary,
                                  fontSize: 14,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor:
                                      RequiemColors.textSecondary)),
                          if (task.subtitle != null)
                            Text(task.subtitle!,
                                style: GoogleFonts.barlowCondensed(
                                    color: RequiemColors.textMuted,
                                    fontSize: 11,
                                    letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: RequiemColors.gold.withOpacity(0.4)),
                        color: RequiemColors.gold.withOpacity(0.07),
                      ),
                      child: Text('+${task.xpReward}',
                          style: GoogleFonts.barlowCondensed(
                              color: isDone
                                  ? RequiemColors.textMuted
                                  : RequiemColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: RequiemColors.textSecondary,
                        size: 18),
                  ],
                ),
              ),
            ),

            // Expanded set rows
            if (isExpanded) ...[
              Container(
                  height: 1, color: RequiemColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  children: List.generate(3, (si) {
                    final done = completedSets.contains(si);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // Set label
                          SizedBox(
                            width: 42,
                            child: Text('SET ${si + 1}',
                                style: GoogleFonts.barlowCondensed(
                                    color: done
                                        ? RequiemColors.operative
                                        : RequiemColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                          ),
                          // kg field
                          Expanded(
                            child: TextField(
                              onChanged: (v) => onKgChanged(si, v),
                              decoration: const InputDecoration(
                                hintText: 'kg',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.barlow(
                                  color: RequiemColors.textPrimary,
                                  fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // reps field
                          Expanded(
                            child: TextField(
                              onChanged: (v) => onRepsChanged(si, v),
                              decoration: const InputDecoration(
                                hintText: 'reps',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.barlow(
                                  color: RequiemColors.textPrimary,
                                  fontSize: 13),
                            ),
                          ),
                          // Check button
                          GestureDetector(
                            onTap: () => onSetChecked(si),
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: done
                                        ? RequiemColors.operative
                                        : RequiemColors.borderBright,
                                    width: 1.5),
                                color: done
                                    ? RequiemColors.operative
                                        .withOpacity(0.15)
                                    : Colors.transparent,
                              ),
                              child: done
                                  ? const Icon(Icons.check,
                                      size: 16,
                                      color: RequiemColors.operative)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Complete Session Button ───────────────────────────────────────────────────

class _CompleteSessionButton extends StatelessWidget {
  final DailyTask task;
  final bool isCompleted;
  final VoidCallback onTap;

  const _CompleteSessionButton({
    required this.task,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isCompleted
              ? RequiemColors.operative.withOpacity(0.1)
              : RequiemColors.bsaaRed,
          border: Border.all(
              color: isCompleted
                  ? RequiemColors.operative
                  : RequiemColors.bsaaRed,
              width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.flag,
              color: isCompleted
                  ? RequiemColors.operative
                  : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isCompleted ? 'MISSION COMPLETE' : 'COMPLETE SESSION',
              style: GoogleFonts.barlowCondensed(
                color: isCompleted
                    ? RequiemColors.operative
                    : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
