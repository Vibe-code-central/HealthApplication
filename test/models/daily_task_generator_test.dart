import 'package:flutter_test/flutter_test.dart';
import 'package:project_requiem/models/daily_task.dart';

void main() {
  group('DailyTaskGenerator', () {
    test('Monday generates Chest + Triceps tasks', () {
      final mondayTasks = DailyTaskGenerator.generateFor(DateTime(2026, 4, 6)); // Monday Apr 6, 2026
      
      final workoutTasks = mondayTasks.where((t) => t.category == DailyTaskCategory.workout).toList();
      
      expect(workoutTasks.any((t) => t.title.contains('Bench Press')), isTrue);
      expect(workoutTasks.any((t) => t.title.contains('Tricep')), isTrue);
    });

    test('Tuesday generates Back + Biceps tasks', () {
      final tuesdayTasks = DailyTaskGenerator.generateFor(DateTime(2026, 4, 7)); // Tuesday Apr 7, 2026
      
      final workoutTasks = tuesdayTasks.where((t) => t.category == DailyTaskCategory.workout).toList();
      
      expect(workoutTasks.any((t) => t.title.contains('Lat Pulldown')), isTrue);
      expect(workoutTasks.any((t) => t.title.contains('Curl')), isTrue);
    });

    test('All days contain Nutrition and Recovery tasks', () {
      final tasks = DailyTaskGenerator.generateFor(DateTime.now());
      
      final hasNutrition = tasks.any((t) => t.category == DailyTaskCategory.nutrition);
      final hasHydration = tasks.any((t) => t.category == DailyTaskCategory.hydration);
      final hasRecovery = tasks.any((t) => t.category == DailyTaskCategory.recovery);
      
      expect(hasNutrition, isTrue);
      expect(hasHydration, isTrue);
      expect(hasRecovery, isTrue);

      expect(tasks.any((t) => t.title == 'Hit 160g Protein'), isTrue);
      expect(tasks.any((t) => t.title == 'Drink 6 Glasses of Water'), isTrue);
    });
  });
}
