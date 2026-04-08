import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../providers/nutrition_provider.dart';
import '../../models/nutrition_log.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(nutritionProvider.notifier).getTodayLog();
    // In a reactive setup we would watch the specific log or the list, 
    // but for MVP we are just rebuilding when nutritionProvider changes
    ref.watch(nutritionProvider); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('INTEL // NUTRITION'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PROTEIN METER
            Text('PROTEIN SYNTHESIS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            _buildProteinMeter(context, todayLog.proteinGrams, 160.0),
            const SizedBox(height: 24),

            // WATER TRACKER
            Text('HYDRATION STATUS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            _buildWaterTracker(context, ref, todayLog.waterGlasses),
            const SizedBox(height: 24),

            // LOG MEAL BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('LOG RATION'),
              onPressed: () {
                // Mock adding a good meal
                ref.read(nutritionProvider.notifier).logMeal(
                  _mockMeal(),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning, color: RequiemColors.primaryBackground),
              style: ElevatedButton.styleFrom(backgroundColor: RequiemColors.ember),
              label: const Text('LOG COMPROMISED MEAL', style: TextStyle(color: RequiemColors.primaryBackground)),
              onPressed: () {
                // Mock adding a junk meal
                ref.read(nutritionProvider.notifier).logMeal(
                  _mockJunk(),
                );
              },
            ),
            const SizedBox(height: 24),

            // MEAL LOG
            Text('DAILY LOG', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            ...todayLog.meals.map((meal) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  meal.isJunkFood ? Icons.warning : Icons.check_circle,
                  color: meal.isJunkFood ? RequiemColors.ember : RequiemColors.operative,
                ),
                title: Text(meal.description, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text('${meal.proteinGrams}g Protein', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RequiemColors.textSecondary)),
                trailing: meal.isJunkFood ? const Text('+10 Wesker') : null,
              ),
            )),
            
            const SizedBox(height: 24),
            // ADA'S REPORT
            Container(
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
                      const Icon(Icons.support_agent, color: RequiemColors.intelBlue),
                      const SizedBox(width: 8),
                      Text('ADA WONG — REPORT', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RequiemColors.intelBlue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todayLog.junkFoodIncidents > 0 
                      ? "You've compromised your integrity. Wesker gains power."
                      : "Target tracking well. Proceed.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProteinMeter(BuildContext context, double current, double target) {
    double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${current.toStringAsFixed(0)}g', style: Theme.of(context).textTheme.bodyLarge),
            Text('${target.toStringAsFixed(0)}g TARGET', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 20,
          backgroundColor: RequiemColors.tertiarySurface,
          color: progress >= 1.0 ? RequiemColors.operative : RequiemColors.bsaaRed,
        ),
      ],
    );
  }

  Widget _buildWaterTracker(BuildContext context, WidgetRef ref, int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        bool isFilled = index < current;
        return GestureDetector(
          onTap: () => ref.read(nutritionProvider.notifier).addWater(),
          child: Icon(
            isFilled ? Icons.water_drop : Icons.water_drop_outlined,
            color: isFilled ? RequiemColors.intelBlue : RequiemColors.textSecondary,
            size: 40,
          ),
        );
      }),
    );
  }
}

// Temporary helpers
MealEntry _mockMeal() => MealEntry(mealType: 'LUNCH', description: 'Chicken Breast & Rice', proteinGrams: 35.0, isJunkFood: false, isSugarDrink: false, location: 'HOME');
MealEntry _mockJunk() => MealEntry(mealType: 'SNACK', description: 'Cold Drink & Chips', proteinGrams: 2.0, isJunkFood: true, isSugarDrink: true, location: 'OUTSIDE');
