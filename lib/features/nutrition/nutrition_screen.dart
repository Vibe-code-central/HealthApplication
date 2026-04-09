import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../core/integrity/integrity_service.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/nutrition_log.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(nutritionProvider);
    final todayLog = ref.watch(nutritionProvider.notifier).getTodayLog();
    final user = ref.watch(userProvider);

    final proteinProgress = (todayLog.proteinGrams / 160.0).clamp(0.0, 1.0);
    final proteinColor = proteinProgress >= 1.0
        ? RequiemColors.operative
        : proteinProgress > 0.5
            ? RequiemColors.gold
            : RequiemColors.bsaaRed;

    return Scaffold(
      backgroundColor: RequiemColors.primaryBackground,
      appBar: AppBar(
        title: const Text('NUTRITION INTEL'),
        actions: [
          if (user != null && user.isRookiePhase)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                    color: RequiemColors.operative.withOpacity(0.6), width: 1),
                color: RequiemColors.operative.withOpacity(0.08),
              ),
              child: Text(
                'ROOKIE PHASE',
                style: GoogleFonts.barlowCondensed(
                  color: RequiemColors.operative,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cooldown Banner ──────────────────────────
            if (user != null) _CooldownBanner(user: user),

            // ── Protein Target ───────────────────────────
            const ReDividerHeader(
                label: 'PROTEIN SYNTHESIS',
                color: RequiemColors.bsaaRed,
                icon: Icons.monitor_heart_outlined),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: RePanel(
                borderColor: proteinColor.withOpacity(0.4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${todayLog.proteinGrams.toStringAsFixed(0)}g',
                          style: GoogleFonts.bebasNeue(
                              color: proteinColor,
                              fontSize: 32,
                              letterSpacing: 1),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('TARGET',
                                style: GoogleFonts.barlowCondensed(
                                    color: RequiemColors.textSecondary,
                                    fontSize: 10,
                                    letterSpacing: 2)),
                            Text('160g',
                                style: GoogleFonts.barlowCondensed(
                                    color: RequiemColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ReStatusBar(
                        value: proteinProgress,
                        color: proteinColor,
                        height: 10),
                    const SizedBox(height: 8),
                    Text(
                      proteinProgress >= 1.0
                          ? '"Target acquired. Muscle synthesis confirmed." — Ada'
                          : '"${(160 - todayLog.proteinGrams).toStringAsFixed(0)}g remaining. Correct this before end of day."',
                      style: GoogleFonts.barlow(
                          color: RequiemColors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hydration ────────────────────────────────
            const ReDividerHeader(
                label: 'HYDRATION STATUS',
                color: RequiemColors.intelBlue,
                icon: Icons.water_drop_outlined),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _HydrationPanel(
                  current: todayLog.waterGlasses, user: user, ref: ref),
            ),

            // ── Log Actions ──────────────────────────────
            const ReDividerHeader(
                label: 'LOG RATION',
                color: RequiemColors.operative,
                icon: Icons.add_circle_outline),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  _LogButton(
                    label: 'LOG CLEAN MEAL',
                    sublabel: 'Chicken, rice, eggs, dal, milk...',
                    color: RequiemColors.operative,
                    icon: Icons.check,
                    onTap: () => _handleLog(
                        context, ref, _mockMeal(), false),
                  ),
                  const SizedBox(height: 8),
                  _LogButton(
                    label: 'LOG COMPROMISED MEAL',
                    sublabel: 'Cold drink, chips, fried food...',
                    color: RequiemColors.ember,
                    icon: Icons.warning_amber_outlined,
                    onTap: () => _handleLog(
                        context, ref, _mockJunk(), true),
                  ),
                ],
              ),
            ),

            // ── Daily Log ────────────────────────────────
            const ReDividerHeader(
                label: 'DAILY FIELD LOG',
                color: RequiemColors.textSecondary,
                icon: Icons.list_alt),
            if (todayLog.meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Text(
                  'No rations logged yet. Begin logging above.',
                  style: GoogleFonts.barlowCondensed(
                      color: RequiemColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1),
                ),
              ),
            ...List.generate(todayLog.meals.length, (index) {
              final meal = todayLog.meals[index];
              return _MealRow(
                meal: meal,
                index: index,
                ref: ref,
                context: context,
              );
            }),

            // ── Ada Report ───────────────────────────────
            const ReDividerHeader(
                label: 'FIELD REPORT — ADA WONG',
                color: RequiemColors.intelBlue,
                icon: Icons.support_agent),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _AdaReportPanel(
                junkIncidents: todayLog.junkFoodIncidents,
                protein: todayLog.proteinGrams,
                water: todayLog.waterGlasses,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLog(
    BuildContext context,
    WidgetRef ref,
    MealEntry meal,
    bool isJunk,
  ) async {
    final result = await ref.read(nutritionProvider.notifier).logMeal(meal);
    if (!context.mounted) return;

    final colour = switch (result.characterId ?? 'ADA') {
      'ADA' => RequiemColors.intelBlue,
      'CHRIS' => RequiemColors.operative,
      'WESKER' => RequiemColors.wesker,
      'CLAIRE' => RequiemColors.shadow,
      _ => RequiemColors.bsaaRed,
    };

    if (result.narrativeMessage != null || !result.allowed) {
      final msg = result.narrativeMessage ?? 'Action blocked.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: RequiemColors.secondarySurface,
          padding: EdgeInsets.zero,
          content: Row(
            children: [
              Container(width: 3, height: 56, color: colour),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(msg,
                      style: GoogleFonts.barlow(
                          color: colour, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _CooldownBanner extends StatelessWidget {
  final dynamic user;
  const _CooldownBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    final check = IntegrityService.checkMealCooldown(user);
    if (check.allowed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RequiemColors.intelBlue.withOpacity(0.07),
        border: const Border(
          left: BorderSide(color: RequiemColors.intelBlue, width: 2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined,
              color: RequiemColors.intelBlue, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '"Ration cooldown active. Rushing intel degrades accuracy." — Ada',
              style: GoogleFonts.barlow(
                  color: RequiemColors.intelBlue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationPanel extends StatelessWidget {
  final int current;
  final dynamic user;
  final WidgetRef ref;

  const _HydrationPanel(
      {required this.current, required this.user, required this.ref});

  @override
  Widget build(BuildContext context) {
    final rateLimited = user != null
        ? !IntegrityService.checkWaterRateLimit(user).allowed
        : false;

    return RePanel(
      borderColor: RequiemColors.intelBlue.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current / 6 GLASSES',
                  style: GoogleFonts.bebasNeue(
                      color: current >= 6
                          ? RequiemColors.operative
                          : RequiemColors.intelBlue,
                      fontSize: 22,
                      letterSpacing: 1)),
              if (rateLimited)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: RequiemColors.ember.withOpacity(0.6)),
                    color: RequiemColors.ember.withOpacity(0.07),
                  ),
                  child: Text('RATE LIMITED',
                      style: GoogleFonts.barlowCondensed(
                          color: RequiemColors.ember,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(6, (i) {
              final filled = i < current;
              return Expanded(
                child: GestureDetector(
                  onTap: rateLimited
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: RequiemColors.secondarySurface,
                              content: Text(
                                '"Max 2 glasses per hour, Kennedy." — Ada',
                                style: GoogleFonts.barlow(
                                    color: RequiemColors.intelBlue,
                                    fontSize: 13),
                              ),
                            ),
                          )
                      : () async {
                          final result = await ref
                              .read(nutritionProvider.notifier)
                              .addWater();
                          if (!context.mounted) return;
                          if (result.narrativeMessage != null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              backgroundColor: RequiemColors.secondarySurface,
                              content: Text(result.narrativeMessage!,
                                  style: GoogleFonts.barlow(
                                      color: RequiemColors.intelBlue)),
                            ));
                          }
                        },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 36,
                    decoration: BoxDecoration(
                      color: filled
                          ? RequiemColors.intelBlue
                          : RequiemColors.tertiarySurface,
                      border: Border.all(
                        color: filled
                            ? RequiemColors.intelBlue
                            : RequiemColors.borderBright,
                        width: 1,
                      ),
                    ),
                    child: filled
                        ? const Icon(Icons.water_drop,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _LogButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.barlowCondensed(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  Text(sublabel,
                      style: GoogleFonts.barlow(
                          color: RequiemColors.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealEntry meal;
  final int index;
  final WidgetRef ref;
  final BuildContext context;

  const _MealRow({
    required this.meal,
    required this.index,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final isJunk = meal.isJunkFood;
    final color =
        isJunk ? RequiemColors.ember : RequiemColors.operative;

    return Dismissible(
      key: ValueKey('meal_${index}_${meal.description}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: RequiemColors.bsaaRed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.undo, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Text('UNDO',
                style: GoogleFonts.barlowCondensed(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmReverse(ctx, meal.description),
      onDismissed: (_) => _doReverse(ctx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 2),
            bottom: const BorderSide(
                color: RequiemColors.border, width: 1),
          ),
          color: color.withOpacity(0.04),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                  isJunk
                      ? Icons.warning_amber_outlined
                      : Icons.check,
                  color: color,
                  size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.description,
                        style: GoogleFonts.barlow(
                            color: RequiemColors.textPrimary,
                            fontSize: 14)),
                    Text(
                        '${meal.proteinGrams.toStringAsFixed(0)}g protein  •  ${meal.mealType}',
                        style: GoogleFonts.barlowCondensed(
                            color: RequiemColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              if (isJunk)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: RequiemColors.ember.withOpacity(0.5)),
                    color: RequiemColors.ember.withOpacity(0.1),
                  ),
                  child: Text('+WESKER',
                      style: GoogleFonts.barlowCondensed(
                          color: RequiemColors.ember,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: RequiemColors.textSecondary),
                padding: const EdgeInsets.only(left: 8),
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  final ok =
                      await _confirmReverse(ctx, meal.description);
                  if (ok == true && ctx.mounted) _doReverse(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmReverse(
      BuildContext ctx, String description) {
    return showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        title: Text('REVERSE LOG ENTRY?',
            style: GoogleFonts.bebasNeue(
                color: RequiemColors.bsaaRed,
                fontSize: 20,
                letterSpacing: 1.5)),
        content: Text(
          'Remove "$description" and reverse all effects on XP, Wesker and protein?',
          style: GoogleFonts.barlow(
              color: RequiemColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('CANCEL')),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('REVERSE',
                  style: TextStyle(color: RequiemColors.bsaaRed))),
        ],
      ),
    );
  }

  Future<void> _doReverse(BuildContext ctx) async {
    final result =
        await ref.read(nutritionProvider.notifier).removeMeal(index);
    if (!ctx.mounted) return;
    if (result.narrativeMessage != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        backgroundColor: RequiemColors.secondarySurface,
        content: Text(result.narrativeMessage!,
            style: GoogleFonts.barlow(
                color: RequiemColors.intelBlue, fontSize: 13)),
      ));
    }
  }
}

class _AdaReportPanel extends StatelessWidget {
  final int junkIncidents;
  final double protein;
  final int water;

  const _AdaReportPanel({
    required this.junkIncidents,
    required this.protein,
    required this.water,
  });

  @override
  Widget build(BuildContext context) {
    final msg = junkIncidents > 0
        ? '"${junkIncidents > 1 ? 'Multiple compromised rations logged.' : 'One incident logged.'} Don\'t repeat it." — Ada'
        : protein >= 160
            ? '"Target acquired. Muscle synthesis confirmed. Proceed, Kennedy." — Ada'
            : '"${(160 - protein).toStringAsFixed(0)}g of protein left on the table. Correct this before end of day." — Ada';

    return RePanel(
      borderColor: RequiemColors.intelBlue.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent,
                  color: RequiemColors.intelBlue, size: 15),
              const SizedBox(width: 8),
              Text('ADA WONG — FIELD ASSESSMENT',
                  style: GoogleFonts.barlowCondensed(
                      color: RequiemColors.intelBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 10),
          Text(msg,
              style: GoogleFonts.barlow(
                  color: RequiemColors.textPrimary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ── Mock helpers (to be replaced with real meal input dialog) ────────────────
MealEntry _mockMeal() => MealEntry(
    mealType: 'LUNCH',
    description: 'Chicken Breast & Rice',
    proteinGrams: 35.0,
    isJunkFood: false,
    isSugarDrink: false,
    location: 'HOME');

MealEntry _mockJunk() => MealEntry(
    mealType: 'SNACK',
    description: 'Cold Drink & Chips',
    proteinGrams: 2.0,
    isJunkFood: true,
    isSugarDrink: true,
    location: 'OUTSIDE');
