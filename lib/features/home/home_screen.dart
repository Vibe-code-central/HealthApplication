import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../models/daily_task.dart';
import '../../providers/user_provider.dart';
import '../../providers/daily_task_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final tasks = ref.watch(dailyTaskProvider);
    final notifier = ref.read(dailyTaskProvider.notifier);

    if (user == null) {
      return const Center(
          child: CircularProgressIndicator(color: RequiemColors.bsaaRed));
    }

    final completedCount = notifier.completedCount;
    final totalCount = notifier.totalTasks;
    final percent = notifier.completionPercent;
    final dayLabel = notifier.dayLabel;
    final sortedTasks = notifier.byCategory;

    // Group tasks by category for sections
    final grouped = <DailyTaskCategory, List<DailyTask>>{};
    for (final task in sortedTasks) {
      grouped.putIfAbsent(task.category, () => []).add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('LEVEL ${user.level} — ${_avatarLabel(user.avatarState)}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${user.currentStreak}d',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: RequiemColors.gold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Day Header ─────────────────────────────────
          SliverToBoxAdapter(
            child: _DayHeader(
              dayLabel: dayLabel,
              completedCount: completedCount,
              totalCount: totalCount,
              percent: percent,
              weskerPower: user.weskerPower,
              context: context,
            ),
          ),

          // ── Task Sections ───────────────────────────────
          ...grouped.entries.expand((entry) {
            final category = entry.key;
            final categoryTasks = entry.value;
            return [
              SliverToBoxAdapter(
                child: _SectionHeader(category: category),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final task = categoryTasks[i];
                    return _TaskTile(
                      task: task,
                      onToggle: () =>
                          ref.read(dailyTaskProvider.notifier).toggleTask(task.id),
                    );
                  },
                  childCount: categoryTasks.length,
                ),
              ),
            ];
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Wesker Status ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _WeskerCard(
                weskerPower: user.weskerPower,
                context: context,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _avatarLabel(int state) {
    const labels = [
      'Raccoon City Rookie',
      'Field Agent',
      'Government Operative',
      'Veteran Operative',
      'Elite Operative',
      'Requiem Warrior',
      'REQUIEM',
    ];
    return state < labels.length ? labels[state].toUpperCase() : 'OPERATIVE';
  }
}

// ── Day Header ──────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final String dayLabel;
  final int completedCount;
  final int totalCount;
  final double percent;
  final int weskerPower;
  final BuildContext context;

  const _DayHeader({
    required this.dayLabel,
    required this.completedCount,
    required this.totalCount,
    required this.percent,
    required this.weskerPower,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final color = percent == 1.0
        ? RequiemColors.operative
        : percent > 0.5
            ? RequiemColors.gold
            : RequiemColors.bsaaRed;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RequiemColors.secondarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: Theme.of(ctx)
                .textTheme
                .headlineMedium
                ?.copyWith(color: color),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: RequiemColors.tertiarySurface,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completedCount / $totalCount',
                style: Theme.of(ctx)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            percent == 1.0
                ? '"All objectives cleared. Leon Kennedy — mission complete." — Chris'
                : percent > 0.5
                    ? '"Over halfway. Don\'t slow down now, Kennedy."'
                    : '"Objectives pending. Get moving, operative."',
            style: Theme.of(ctx)
                .textTheme
                .bodyMedium
                ?.copyWith(color: RequiemColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final DailyTaskCategory category;

  const _SectionHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      DailyTaskCategory.workout => RequiemColors.operative,
      DailyTaskCategory.nutrition => RequiemColors.gold,
      DailyTaskCategory.hydration => RequiemColors.intelBlue,
      DailyTaskCategory.recovery => RequiemColors.shadow,
      DailyTaskCategory.mission => RequiemColors.bsaaRed,
    };

    final icon = switch (category) {
      DailyTaskCategory.workout => Icons.fitness_center,
      DailyTaskCategory.nutrition => Icons.restaurant,
      DailyTaskCategory.hydration => Icons.water_drop,
      DailyTaskCategory.recovery => Icons.bedtime,
      DailyTaskCategory.mission => Icons.flag,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color.withOpacity(0.3))),
        ],
      ),
    );
  }
}

// ── Task Tile ───────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onToggle;

  const _TaskTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    final checkColor = switch (task.category) {
      DailyTaskCategory.workout => RequiemColors.operative,
      DailyTaskCategory.nutrition => RequiemColors.gold,
      DailyTaskCategory.hydration => RequiemColors.intelBlue,
      DailyTaskCategory.recovery => RequiemColors.shadow,
      DailyTaskCategory.mission => RequiemColors.bsaaRed,
    };

    return AnimatedOpacity(
      opacity: isCompleted ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isCompleted
                        ? checkColor
                        : checkColor.withOpacity(0.5),
                    width: 2,
                  ),
                  color: isCompleted
                      ? checkColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: isCompleted
                    ? Icon(Icons.check, size: 16, color: checkColor)
                    : null,
              ),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? RequiemColors.textMuted
                                : null,
                          ),
                    ),
                    if (task.subtitle != null)
                      Text(
                        task.subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: RequiemColors.textSecondary),
                      ),
                  ],
                ),
              ),

              // XP badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: checkColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: checkColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  '+${task.xpReward}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCompleted
                        ? RequiemColors.textMuted
                        : checkColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wesker Card ─────────────────────────────────────────────────────────────

class _WeskerCard extends StatelessWidget {
  final int weskerPower;
  final BuildContext context;

  const _WeskerCard({required this.weskerPower, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final String commentary;
    if (weskerPower >= 90) {
      commentary = '"You were never worthy of the Requiem, Kennedy."';
    } else if (weskerPower >= 60) {
      commentary = '"Already faltering? Disappointing."';
    } else if (weskerPower >= 30) {
      commentary = '"Already faltering, Mr. Kennedy?"';
    } else {
      commentary = '"Contained. For now."';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RequiemColors.wesker.withOpacity(0.05),
        border: Border.all(color: RequiemColors.wesker.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility,
                  color: RequiemColors.wesker, size: 16),
              const SizedBox(width: 8),
              Text(
                'WESKER THREAT — $weskerPower%',
                style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      color: RequiemColors.wesker,
                      letterSpacing: 1.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: weskerPower / 100,
              minHeight: 8,
              backgroundColor: RequiemColors.tertiarySurface,
              color: RequiemColors.wesker,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            commentary,
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: RequiemColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
