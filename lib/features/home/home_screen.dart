import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    if (user == null || tasks.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: RequiemColors.bsaaRed),
        ),
      );
    }

    final completedCount = notifier.completedCount;
    final totalCount = notifier.totalTasks;
    final dayLabel = notifier.dayLabel;
    final sortedTasks = notifier.byCategory;

    final grouped = <DailyTaskCategory, List<DailyTask>>{};
    for (final task in sortedTasks) {
      grouped.putIfAbsent(task.category, () => []).add(task);
    }

    return Scaffold(
      backgroundColor: RequiemColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          // ── Tactical App Bar ──────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: RequiemColors.primaryBackground,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _TacticalHeader(
                dayLabel: dayLabel,
                completed: completedCount,
                total: totalCount,
                percent: notifier.completionPercent,
                level: user.level,
                streak: user.currentStreak,
                avatarState: user.avatarState,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: RequiemColors.bsaaRed.withOpacity(0.5)),
            ),
          ),

          // ── Task Sections ──────────────────────────────
          ...grouped.entries.expand((entry) => [
                SliverToBoxAdapter(
                  child: ReDividerHeader(
                    label: entry.key.label,
                    color: _categoryColor(entry.key),
                    icon: _categoryIcon(entry.key),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final task = entry.value[i];
                      return _ReTile(
                        task: task,
                        onToggle: () => ref
                            .read(dailyTaskProvider.notifier)
                            .toggleTask(task.id),
                      );
                    },
                    childCount: entry.value.length,
                  ),
                ),
              ]),

          // ── Wesker Panel ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _WeskerPanel(weskerPower: user.weskerPower),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Color _categoryColor(DailyTaskCategory cat) => switch (cat) {
        DailyTaskCategory.workout => RequiemColors.operative,
        DailyTaskCategory.nutrition => RequiemColors.gold,
        DailyTaskCategory.hydration => RequiemColors.intelBlue,
        DailyTaskCategory.recovery => RequiemColors.shadow,
        DailyTaskCategory.mission => RequiemColors.bsaaRed,
      };

  IconData _categoryIcon(DailyTaskCategory cat) => switch (cat) {
        DailyTaskCategory.workout => Icons.fitness_center,
        DailyTaskCategory.nutrition => Icons.restaurant,
        DailyTaskCategory.hydration => Icons.water_drop,
        DailyTaskCategory.recovery => Icons.bedtime,
        DailyTaskCategory.mission => Icons.flag,
      };
}

// ── Tactical Header ─────────────────────────────────────────────────────────

class _TacticalHeader extends StatelessWidget {
  final String dayLabel;
  final int completed;
  final int total;
  final double percent;
  final int level;
  final int streak;
  final int avatarState;

  const _TacticalHeader({
    required this.dayLabel,
    required this.completed,
    required this.total,
    required this.percent,
    required this.level,
    required this.streak,
    required this.avatarState,
  });

  @override
  Widget build(BuildContext context) {
    final color = percent == 1.0
        ? RequiemColors.operative
        : percent > 0.5
            ? RequiemColors.gold
            : RequiemColors.bsaaRed;

    return Container(
      color: RequiemColors.primaryBackground,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  dayLabel,
                  style: GoogleFonts.bebasNeue(
                    color: color,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatChip('LVL $level', RequiemColors.bsaaRed),
              const SizedBox(width: 8),
              _StatChip('🔥 ${streak}d', RequiemColors.ember),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ReStatusBar(value: percent, color: color, height: 6),
              ),
              const SizedBox(width: 10),
              Text(
                '$completed/$total',
                style: GoogleFonts.barlowCondensed(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.6), width: 1),
        color: color.withOpacity(0.08),
      ),
      child: Text(
        label,
        style: GoogleFonts.barlowCondensed(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Task Tile ───────────────────────────────────────────────────────────────

class _ReTile extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onToggle;

  const _ReTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final color = switch (task.category) {
      DailyTaskCategory.workout => RequiemColors.operative,
      DailyTaskCategory.nutrition => RequiemColors.gold,
      DailyTaskCategory.hydration => RequiemColors.intelBlue,
      DailyTaskCategory.recovery => RequiemColors.shadow,
      DailyTaskCategory.mission => RequiemColors.bsaaRed,
    };

    return InkWell(
      onTap: onToggle,
      splashColor: color.withOpacity(0.08),
      highlightColor: color.withOpacity(0.04),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCompleted ? color.withOpacity(0.04) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
                color: RequiemColors.border.withOpacity(0.6), width: 1),
            left: BorderSide(
                color: isCompleted ? color : Colors.transparent, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // RE-style square checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCompleted ? color : color.withOpacity(0.45),
                    width: 1.5,
                  ),
                  color: isCompleted ? color : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.barlow(
                        color: isCompleted
                            ? RequiemColors.textSecondary
                            : RequiemColors.textPrimary,
                        fontSize: 14,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: RequiemColors.textSecondary,
                      ),
                    ),
                    if (task.subtitle != null)
                      Text(
                        task.subtitle!,
                        style: GoogleFonts.barlowCondensed(
                          color: RequiemColors.textMuted
                              .withOpacity(isCompleted ? 0.5 : 1.0),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),

              // XP badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.transparent
                      : color.withOpacity(0.12),
                  border: Border.all(
                    color: isCompleted
                        ? RequiemColors.textMuted.withOpacity(0.3)
                        : color.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '+${task.xpReward}',
                  style: GoogleFonts.barlowCondensed(
                    color: isCompleted ? RequiemColors.textMuted : color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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

// ── Wesker Threat Panel ──────────────────────────────────────────────────────

class _WeskerPanel extends StatelessWidget {
  final int weskerPower;
  const _WeskerPanel({required this.weskerPower});

  @override
  Widget build(BuildContext context) {
    final commentary = switch (weskerPower) {
      >= 90 => '"You were never worthy of the Requiem, Kennedy."',
      >= 60 => '"Already faltering? How disappointing."',
      >= 30 => '"Already faltering, Mr. Kennedy?"',
      _ => '"Contained. For now."',
    };

    final barColor = weskerPower >= 70
        ? RequiemColors.bsaaRed
        : weskerPower >= 40
            ? RequiemColors.ember
            : RequiemColors.wesker;

    return RePanel(
      borderColor: RequiemColors.wesker.withOpacity(0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  color: RequiemColors.wesker, size: 14),
              const SizedBox(width: 8),
              Text(
                'WESKER THREAT ASSESSMENT',
                style: GoogleFonts.barlowCondensed(
                  color: RequiemColors.wesker,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
              const Spacer(),
              Text(
                '$weskerPower%',
                style: GoogleFonts.bebasNeue(
                  color: barColor,
                  fontSize: 22,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ReStatusBar(value: weskerPower / 100, color: barColor, height: 6),
          const SizedBox(height: 8),
          Text(
            commentary,
            style: GoogleFonts.barlow(
              color: RequiemColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
