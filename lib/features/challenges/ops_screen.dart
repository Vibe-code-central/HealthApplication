import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../providers/daily_task_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/daily_task.dart';

class OpsScreen extends ConsumerWidget {
  const OpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final tasks = ref.watch(dailyTaskProvider);
    final notifier = ref.read(dailyTaskProvider.notifier);

    final completed = notifier.completedCount;
    final total = notifier.totalTasks;

    // Group for weekly summary
    final workoutCompleted = tasks
        .where((t) => t.category == DailyTaskCategory.mission && t.isCompleted)
        .length;
    final nutritionCompleted = tasks
        .where((t) =>
            t.category == DailyTaskCategory.nutrition && t.isCompleted)
        .length;
    final nutritionTotal = tasks
        .where((t) => t.category == DailyTaskCategory.nutrition)
        .length;
    final waterCompleted = tasks
        .where(
            (t) => t.category == DailyTaskCategory.hydration && t.isCompleted)
        .length;

    return Scaffold(
      backgroundColor: RequiemColors.primaryBackground,
      appBar: AppBar(title: const Text('ACTIVE OPERATIONS')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Today's Status ──────────────────────────────
          const ReDividerHeader(
            label: "TODAY'S DEBRIEF",
            color: RequiemColors.bsaaRed,
            icon: Icons.assignment_outlined,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: RePanel(
              borderColor: RequiemColors.bsaaRed.withOpacity(0.4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAILY COMPLETION',
                        style: GoogleFonts.barlowCondensed(
                            color: RequiemColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 2),
                      ),
                      Text(
                        '$completed / $total',
                        style: GoogleFonts.bebasNeue(
                            color: completed == total && total > 0
                                ? RequiemColors.operative
                                : RequiemColors.bsaaRed,
                            fontSize: 26,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReStatusBar(
                    value: total == 0 ? 0 : completed / total,
                    color: completed == total && total > 0
                        ? RequiemColors.operative
                        : RequiemColors.bsaaRed,
                    height: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completed == total && total > 0
                        ? '"All objectives cleared. Outstanding performance, Kennedy." — Chris'
                        : '"${total - completed} objectives remain. Stay on target." — Chris',
                    style: GoogleFonts.barlow(
                        color: RequiemColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          // ── Mission Metrics ──────────────────────────────
          const ReDividerHeader(
            label: 'MISSION METRICS',
            color: RequiemColors.gold,
            icon: Icons.bar_chart,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: RePanel(
              child: Column(
                children: [
                  _MetricRow(
                    label: 'SESSIONS LOGGED TODAY',
                    value: '$workoutCompleted / 1',
                    color: workoutCompleted > 0
                        ? RequiemColors.operative
                        : RequiemColors.textSecondary,
                  ),
                  const Divider(color: RequiemColors.border, height: 16),
                  _MetricRow(
                    label: 'MEALS LOGGED',
                    value: '$nutritionCompleted / $nutritionTotal',
                    color: nutritionCompleted == nutritionTotal && nutritionTotal > 0
                        ? RequiemColors.operative
                        : RequiemColors.gold,
                  ),
                  const Divider(color: RequiemColors.border, height: 16),
                  _MetricRow(
                    label: 'HYDRATION TARGET',
                    value: waterCompleted > 0 ? 'HIT' : 'PENDING',
                    color: waterCompleted > 0
                        ? RequiemColors.intelBlue
                        : RequiemColors.textSecondary,
                  ),
                  if (user != null) ...[
                    const Divider(color: RequiemColors.border, height: 16),
                    _MetricRow(
                      label: 'CURRENT STREAK',
                      value: '${user.currentStreak} DAYS',
                      color: RequiemColors.ember,
                    ),
                    const Divider(color: RequiemColors.border, height: 16),
                    _MetricRow(
                      label: 'BEST STREAK',
                      value: '${user.longestStreak} DAYS',
                      color: RequiemColors.gold,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Weekly Challenge ─────────────────────────────
          const ReDividerHeader(
            label: 'WEEKLY CHALLENGE',
            color: RequiemColors.operative,
            icon: Icons.emoji_events_outlined,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: _WeeklyChallenge(),
          ),

          // ── HUNK Terminal ────────────────────────────────
          const ReDividerHeader(
            label: 'HUNK — SECURE CHANNEL',
            color: RequiemColors.textSecondary,
            icon: Icons.terminal,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: _HunkTerminal(
              weskerPower: user?.weskerPower ?? 0,
              level: user?.level ?? 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metric Row ──────────────────────────────────────────────────────────────

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.barlowCondensed(
                color: RequiemColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1)),
        Text(value,
            style: GoogleFonts.barlowCondensed(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
      ],
    );
  }
}

// ── Weekly Challenge ────────────────────────────────────────────────────────

class _WeeklyChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // How many gym days have passed this week (Mon/Tue/Thu/Fri = 4)
    final today = DateTime.now().weekday;
    final gymDaysPassed = [1, 2, 4, 5].where((d) => d <= today).length;
    final progress = gymDaysPassed / 4;

    return RePanel(
      borderColor: RequiemColors.operative.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: RequiemColors.operative,
                child: Text('GREEN',
                    style: GoogleFonts.barlowCondensed(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ),
              const SizedBox(width: 10),
              Text('FIELD OPERATIVE',
                  style: GoogleFonts.bebasNeue(
                      color: RequiemColors.textPrimary,
                      fontSize: 18,
                      letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Log 4 gym sessions this week.',
              style: GoogleFonts.barlow(
                  color: RequiemColors.textPrimary, fontSize: 14)),
          const SizedBox(height: 10),
          ReStatusBar(
              value: progress,
              color: RequiemColors.operative,
              height: 6),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$gymDaysPassed / 4 SESSIONS',
                  style: GoogleFonts.barlowCondensed(
                      color: RequiemColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1)),
              Text(
                  progress >= 1.0 ? 'COMPLETE' : 'IN PROGRESS',
                  style: GoogleFonts.barlowCondensed(
                      color: progress >= 1.0
                          ? RequiemColors.operative
                          : RequiemColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── HUNK Terminal ───────────────────────────────────────────────────────────

class _HunkTerminal extends StatelessWidget {
  final int weskerPower;
  final int level;

  const _HunkTerminal({required this.weskerPower, required this.level});

  @override
  Widget build(BuildContext context) {
    final lines = [
      '> SYSTEM: REQUIEM PROTOCOL v4.1',
      '> STATUS: OPERATIVE ACTIVE',
      '> WESKER INDEX: $weskerPower%',
      '> CLEARANCE: LVL $level',
      '> ${_hunkQuote(weskerPower)}',
    ];

    return RePanel(
      borderColor: RequiemColors.textMuted.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          final isQuote = line.startsWith('> "');
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: GoogleFonts.robotoMono(
                color: isQuote
                    ? RequiemColors.textSecondary
                    : RequiemColors.operative,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _hunkQuote(int power) {
    if (power >= 80) return '"Wesker index critical. Discipline or lose everything."';
    if (power >= 50) return '"Performance gaps detected. Tighten up, operative."';
    if (power >= 20) return '"Wesker contained. Maintain pressure."';
    return '"Target under control. This is the mission." — HUNK';
  }
}
