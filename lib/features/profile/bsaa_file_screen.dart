import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../providers/user_provider.dart';

class BsaaFileScreen extends ConsumerWidget {
  const BsaaFileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: RequiemColors.primaryBackground,
      appBar: AppBar(
        title: const Text('BSAA — CLASSIFIED DOSSIER'),
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: RequiemColors.bsaaRed))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Operative ID Card ──────────────────────────
                RePanel(
                  borderColor: RequiemColors.bsaaRed.withOpacity(0.6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: RequiemColors.bsaaRed, width: 1.5),
                              color: RequiemColors.tertiarySurface,
                            ),
                            child: const Icon(Icons.radar,
                                color: RequiemColors.bsaaRed, size: 36)
                                .animate(onPlay: (controller) => controller.repeat())
                                .rotate(duration: 4.seconds, curve: Curves.linear),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name.toUpperCase(),
                                  style: GoogleFonts.bebasNeue(
                                    color: RequiemColors.textPrimary,
                                    fontSize: 26,
                                    letterSpacing: 2,
                                  ),
                                )
                                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                    .shimmer(duration: 3.seconds, color: RequiemColors.bsaaRed.withOpacity(0.3)),
                                Text(
                                  _avatarLabel(user.avatarState),
                                  style: GoogleFonts.barlowCondensed(
                                    color: RequiemColors.bsaaRed,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: RequiemColors.operative, width: 1),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: GoogleFonts.barlowCondensed(
                                color: RequiemColors.operative,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: RequiemColors.borderBright),
                      const SizedBox(height: 10),
                      _StatRow('CLEARANCE LEVEL',
                          'LVL ${user.level}', RequiemColors.bsaaRed),
                      _StatRow('OPERATIVE STATUS',
                          _avatarLabel(user.avatarState), RequiemColors.textPrimary),
                      _StatRow('PROGRAMME START',
                          _formatDate(user.programmeStart), RequiemColors.textSecondary),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── XP Progress ────────────────────────────────
                const ReDividerHeader(
                    label: 'FIELD PERFORMANCE', icon: Icons.bar_chart),
                RePanel(
                  child: Column(
                    children: [
                      _StatRow('TOTAL XP ACCRUED',
                          '${user.totalXP} XP', RequiemColors.gold),
                      const SizedBox(height: 10),
                      _LevelBar(level: user.level, totalXP: user.totalXP),
                      const SizedBox(height: 10),
                      _StatRow('CURRENT STREAK',
                          '${user.currentStreak} DAYS', RequiemColors.ember),
                      _StatRow('LONGEST STREAK',
                          '${user.longestStreak} DAYS', RequiemColors.textSecondary),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── Bio Data ───────────────────────────────────
                const ReDividerHeader(
                    label: 'BIOMETRIC DATA', icon: Icons.person_search),
                RePanel(
                  child: Column(
                    children: [
                      _StatRow('STARTING WEIGHT',
                          '${user.startingWeight.toStringAsFixed(1)} KG',
                          RequiemColors.textSecondary),
                      _StatRow('CURRENT WEIGHT',
                          '${user.currentWeight.toStringAsFixed(1)} KG',
                          RequiemColors.textPrimary),
                      _StatRow('HEIGHT',
                          '${user.heightCm.toStringAsFixed(0)} CM',
                          RequiemColors.textSecondary),
                      _StatRow('WEIGHT Δ',
                          '${(user.currentWeight - user.startingWeight).toStringAsFixed(1)} KG',
                          user.currentWeight < user.startingWeight
                              ? RequiemColors.operative
                              : RequiemColors.ember),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── Wesker Threat ──────────────────────────────
                const ReDividerHeader(
                    label: 'THREAT CONTAINMENT',
                    color: RequiemColors.wesker,
                    icon: Icons.remove_red_eye_outlined),
                RePanel(
                  borderColor: RequiemColors.wesker.withOpacity(0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('WESKER POWER LEVEL',
                              style: GoogleFonts.barlowCondensed(
                                  color: RequiemColors.textSecondary,
                                  fontSize: 12,
                                  letterSpacing: 1.5)),
                          Text('${user.weskerPower}%',
                              style: GoogleFonts.bebasNeue(
                                  color: _weskerColor(user.weskerPower),
                                  fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ReStatusBar(
                          value: user.weskerPower / 100,
                          color: _weskerColor(user.weskerPower),
                          height: 8),
                      const SizedBox(height: 8),
                      Text(
                        user.weskerPower == 0
                            ? '"Contained. Wesker influence at zero." — BSAA Intel'
                            : '"Subject shows ${user.weskerPower}% Wesker influence. Monitor closely."',
                        style: GoogleFonts.barlow(
                            color: RequiemColors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                          color: RequiemColors.wesker,
                          duration: const Duration(seconds: 2),
                          blendMode: BlendMode.srcATop),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Color _weskerColor(int power) {
    if (power >= 70) return RequiemColors.bsaaRed;
    if (power >= 40) return RequiemColors.ember;
    return RequiemColors.wesker;
  }

  String _avatarLabel(int state) {
    const labels = [
      'RACCOON CITY ROOKIE',
      'FIELD AGENT',
      'GOVERNMENT OPERATIVE',
      'VETERAN OPERATIVE',
      'ELITE OPERATIVE',
      'REQUIEM WARRIOR',
      'REQUIEM — FINAL FORM',
    ];
    return state < labels.length ? labels[state] : 'OPERATIVE';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ── UI Helpers ───────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.barlowCondensed(
                  color: RequiemColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.barlowCondensed(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  final int level;
  final int totalXP;

  const _LevelBar({required this.level, required this.totalXP});

  @override
  Widget build(BuildContext context) {
    // XP required per level = 500 * level
    final xpForCurrentLevel = (level - 1) * 500;
    final xpForNextLevel = level * 500;
    final xpInLevel = totalXP - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    final percent = (xpInLevel / xpNeeded).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LVL $level',
                style: GoogleFonts.barlowCondensed(
                    color: RequiemColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            Text('LVL ${level + 1}',
                style: GoogleFonts.barlowCondensed(
                    color: RequiemColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ReStatusBar(value: percent, color: RequiemColors.gold, height: 6),
        const SizedBox(height: 4),
        Text(
          '$xpInLevel / $xpNeeded XP',
          style: GoogleFonts.barlowCondensed(
              color: RequiemColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
