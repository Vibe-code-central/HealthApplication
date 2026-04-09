import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('INTEL // NUTRITION'),
        actions: [
          if (user != null && user.isRookiePhase)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('ROOKIE PHASE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                backgroundColor: RequiemColors.operative.withOpacity(0.2),
                labelStyle:
                    const TextStyle(color: RequiemColors.operative),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MEAL COOLDOWN INDICATOR
            _MealCooldownBanner(user: user),
            const SizedBox(height: 16),

            // PROTEIN METER
            Text('PROTEIN SYNTHESIS',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            _buildProteinMeter(context, todayLog.proteinGrams, 160.0),
            const SizedBox(height: 24),

            // WATER TRACKER
            Text('HYDRATION STATUS',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            _buildWaterTracker(context, ref, todayLog.waterGlasses, user),
            const SizedBox(height: 24),

            // LOG MEAL BUTTONS
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('LOG RATION (Clean Meal)'),
              onPressed: () =>
                  _handleLogMeal(context, ref, _mockMeal(), false),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning,
                  color: RequiemColors.primaryBackground),
              style: ElevatedButton.styleFrom(
                  backgroundColor: RequiemColors.ember),
              label: const Text('LOG COMPROMISED MEAL',
                  style:
                      TextStyle(color: RequiemColors.primaryBackground)),
              onPressed: () =>
                  _handleLogMeal(context, ref, _mockJunk(), true),
            ),
            const SizedBox(height: 24),

            // MEAL LOG
            Text('DAILY LOG',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            ...todayLog.meals.map(
              (meal) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    meal.isJunkFood
                        ? Icons.warning
                        : Icons.check_circle,
                    color: meal.isJunkFood
                        ? RequiemColors.ember
                        : RequiemColors.operative,
                  ),
                  title: Text(meal.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('${meal.proteinGrams}g Protein',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RequiemColors.textSecondary)),
                  trailing: meal.isJunkFood
                      ? const Text('+Wesker',
                          style: TextStyle(color: RequiemColors.ember))
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ADA'S REPORT
            _AdaReport(
              junkIncidents: todayLog.junkFoodIncidents,
              protein: todayLog.proteinGrams,
              water: todayLog.waterGlasses,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogMeal(
    BuildContext context,
    WidgetRef ref,
    MealEntry meal,
    bool isJunk,
  ) async {
    final result =
        await ref.read(nutritionProvider.notifier).logMeal(meal);

    if (!context.mounted) return;

    if (!result.allowed) {
      // Cooldown gate — show with appropriate character colour
      _showIntegritySnackbar(
        context,
        message: result.narrativeMessage ?? 'Action blocked.',
        characterId: result.characterId ?? 'ADA',
        isWarning: true,
      );
      return;
    }

    if (result.narrativeMessage != null) {
      _showIntegritySnackbar(
        context,
        message: result.narrativeMessage!,
        characterId: result.characterId ?? 'ADA',
        isWarning: isJunk,
      );
    }
  }

  void _showIntegritySnackbar(
    BuildContext context, {
    required String message,
    required String characterId,
    bool isWarning = false,
  }) {
    final Color colour = switch (characterId) {
      'ADA' => RequiemColors.intelBlue,
      'CHRIS' => RequiemColors.operative,
      'WESKER' => RequiemColors.wesker,
      'CLAIRE' => RequiemColors.shadow,
      'HUNK' => RequiemColors.textMuted,
      _ => RequiemColors.bsaaRed,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colour.withOpacity(0.15),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 3, color: colour, height: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isWarning ? RequiemColors.ember : colour,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProteinMeter(
      BuildContext context, double current, double target) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${current.toStringAsFixed(0)}g',
                style: Theme.of(context).textTheme.bodyLarge),
            Text('${target.toStringAsFixed(0)}g TARGET',
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 20,
          backgroundColor: RequiemColors.tertiarySurface,
          color: progress >= 1.0
              ? RequiemColors.operative
              : RequiemColors.bsaaRed,
        ),
      ],
    );
  }

  Widget _buildWaterTracker(BuildContext context, WidgetRef ref, int current,
      dynamic user) {
    // Determine if water rate limit is active
    bool rateLimited = false;
    if (user != null) {
      final check = IntegrityService.checkWaterRateLimit(user);
      rateLimited = !check.allowed;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        final isFilled = index < current;
        return GestureDetector(
          onTap: rateLimited
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '"Pace your intake. Max 2 glasses per hour." — Ada',
                        style: TextStyle(color: RequiemColors.intelBlue),
                      ),
                      backgroundColor: Color(0xFF0A1A2A),
                    ),
                  )
              : () async {
                  final result =
                      await ref.read(nutritionProvider.notifier).addWater();
                  if (!context.mounted) return;
                  if (result.narrativeMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result.narrativeMessage!),
                    ));
                  }
                },
          child: Icon(
            isFilled ? Icons.water_drop : Icons.water_drop_outlined,
            color: rateLimited
                ? RequiemColors.textMuted
                : (isFilled
                    ? RequiemColors.intelBlue
                    : RequiemColors.textSecondary),
            size: 40,
          ),
        );
      }),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────

class _MealCooldownBanner extends StatelessWidget {
  final dynamic user;
  const _MealCooldownBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    final check = IntegrityService.checkMealCooldown(user);
    if (check.allowed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RequiemColors.intelBlue.withOpacity(0.08),
        border: Border.all(color: RequiemColors.intelBlue.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: RequiemColors.intelBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"Ration cooldown active. Rushing reports degrades accuracy." — Ada',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RequiemColors.intelBlue,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaReport extends StatelessWidget {
  final int junkIncidents;
  final double protein;
  final int water;

  const _AdaReport({
    required this.junkIncidents,
    required this.protein,
    required this.water,
  });

  @override
  Widget build(BuildContext context) {
    final message = junkIncidents > 0
        ? '"You\'ve compromised your integrity. ${junkIncidents > 1 ? 'Multiple incidents logged.' : 'One incident logged.'} Don\'t repeat it."'
        : protein >= 160
            ? '"Target acquired. Muscle synthesis confirmed. Proceed."'
            : '"${(160 - protein).toStringAsFixed(0)}g of protein left on the table. Correct this before end of day."';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: RequiemColors.intelBlue),
        color: RequiemColors.intelBlue.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent,
                  color: RequiemColors.intelBlue),
              const SizedBox(width: 8),
              Text(
                'ADA WONG — REPORT',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: RequiemColors.intelBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

// Temporary mock helpers
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
