import 'package:flutter_test/flutter_test.dart';
import 'package:project_requiem/core/score/score_service.dart';

void main() {
  group('ScoreService Tests', () {
    test('calculate returns 100 on perfect day', () {
      final score = ScoreService.calculate(
        tasksCompleted: 4,
        tasksTotal: 4,
        workoutDone: true,
        proteinTargetHit: true,
        zeroJunkToday: true,
        waterTargetHit: true,
        sleepLogged: true,
        streakDays: 1,
      );

      expect(score.score, equals(100));
      expect(score.grade, equals('S'));
      expect(score.xpMultiplier, equals(100)); // 1.0x at 1 day
    });

    test('calculate bounds tasks to max 50 points', () {
      final score = ScoreService.calculate(
        tasksCompleted: 4,
        tasksTotal: 4,
        workoutDone: false,
        proteinTargetHit: false,
        zeroJunkToday: false,
        waterTargetHit: false,
        sleepLogged: false,
        streakDays: 1,
      );

      expect(score.score, equals(50));
      expect(score.grade, equals('C'));
    });

    test('calculate handles 0 total tasks gracefully', () {
      final score = ScoreService.calculate(
        tasksCompleted: 0,
        tasksTotal: 0,
        workoutDone: false,
        proteinTargetHit: false,
        zeroJunkToday: false,
        waterTargetHit: false,
        sleepLogged: false,
        streakDays: 1,
      );

      expect(score.score, equals(0));
      expect(score.grade, equals('F'));
    });

    test('xpMultiplier correctly segments by streak days', () {
      expect(
          ScoreService.calculate(
                  tasksCompleted: 0,
                  tasksTotal: 1,
                  workoutDone: false,
                  proteinTargetHit: false,
                  zeroJunkToday: false,
                  waterTargetHit: false,
                  sleepLogged: false,
                  streakDays: 1)
              .xpMultiplier,
          equals(100));
      expect(
          ScoreService.calculate(
                  tasksCompleted: 0,
                  tasksTotal: 1,
                  workoutDone: false,
                  proteinTargetHit: false,
                  zeroJunkToday: false,
                  waterTargetHit: false,
                  sleepLogged: false,
                  streakDays: 7)
              .xpMultiplier,
          equals(110));
      expect(
          ScoreService.calculate(
                  tasksCompleted: 0,
                  tasksTotal: 1,
                  workoutDone: false,
                  proteinTargetHit: false,
                  zeroJunkToday: false,
                  waterTargetHit: false,
                  sleepLogged: false,
                  streakDays: 14)
              .xpMultiplier,
          equals(125));
      expect(
          ScoreService.calculate(
                  tasksCompleted: 0,
                  tasksTotal: 1,
                  workoutDone: false,
                  proteinTargetHit: false,
                  zeroJunkToday: false,
                  waterTargetHit: false,
                  sleepLogged: false,
                  streakDays: 30)
              .xpMultiplier,
          equals(150));
    });
  });
}
