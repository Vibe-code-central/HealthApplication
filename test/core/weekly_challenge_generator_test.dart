import 'package:flutter_test/flutter_test.dart';
import 'package:project_requiem/core/integrity/weekly_challenge_generator.dart';

void main() {
  group('WeeklyChallengeGenerator', () {
    test('expiresAt is exactly Sunday at 23:59:59', () {
      // Act: Simulate a Monday
      final monday = DateTime(2023, 10, 2); // oct 2, 2023 was a monday
      final challenge = WeeklyChallengeGenerator.generateFor(monday);

      // Assert: Sunday of that week is Oct 8
      expect(challenge.expiresAt.weekday, DateTime.sunday);
      expect(challenge.expiresAt.year, 2023);
      expect(challenge.expiresAt.month, 10);
      expect(challenge.expiresAt.day, 8);
      expect(challenge.expiresAt.hour, 23);
      expect(challenge.expiresAt.minute, 59);
      expect(challenge.expiresAt.second, 59);
    });

    test('generateFor correctly sets bounty targets', () {
      final now = DateTime.now();
      final challenge = WeeklyChallengeGenerator.generateFor(now);

      expect(challenge.title, 'OPERATION: RELENTLESS');
      expect(challenge.requirements['combat_sessions'], 4);
      expect(challenge.progress['combat_sessions'], 0);
      expect(challenge.xpReward, 300);
      expect(challenge.completed, false);
      expect(challenge.difficulty, 'AMBER');
    });
  });
}
