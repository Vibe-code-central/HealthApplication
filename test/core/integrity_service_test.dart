import 'package:flutter_test/flutter_test.dart';
import 'package:project_requiem/core/integrity/integrity_service.dart';
import 'package:project_requiem/models/user_profile.dart';

void main() {
  UserProfile createMockUser({
    DateTime? lastMealLogTime,
    List<DateTime>? waterLogTimestamps,
  }) {
    return UserProfile(
      name: 'Test Kennedy',
      startingWeight: 80,
      currentWeight: 80,
      heightCm: 180,
      totalXP: 0,
      level: 1,
      weskerPower: 0,
      avatarState: 0,
      programmeStart: DateTime.now(),
      currentStreak: 0,
      longestStreak: 0,
      lastMealLogTime: lastMealLogTime,
      waterLogTimestamps: waterLogTimestamps ?? [],
    );
  }

  group('IntegrityService - Meal Cooldown', () {
    test('Allowed if last meal was long ago', () {
      final user = createMockUser(
        lastMealLogTime: DateTime.now().subtract(const Duration(hours: 2)),
      );
      final result = IntegrityService.checkMealCooldown(user);
      expect(result.allowed, isTrue);
    });

    test('Blocked if last meal was recent (under 90m)', () {
      final user = createMockUser(
        lastMealLogTime: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      final result = IntegrityService.checkMealCooldown(user);
      expect(result.allowed, isFalse);
      expect(result.characterId, equals('ADA'));
    });
  });

  group('IntegrityService - Water Rate Limiter', () {
    test('Allowed if no recent logs', () {
      final user = createMockUser(waterLogTimestamps: []);
      final result = IntegrityService.checkWaterRateLimit(user);
      expect(result.allowed, isTrue);
    });

    test('Blocked if 2 glasses logged in past hour', () {
      final now = DateTime.now();
      final user = createMockUser(waterLogTimestamps: [
        now.subtract(const Duration(minutes: 10)),
        now.subtract(const Duration(minutes: 30)),
      ]);
      final result = IntegrityService.checkWaterRateLimit(user);
      expect(result.allowed, isFalse);
    });

    test('Blocked if 6 glasses logged today', () {
      final now = DateTime.now();
      // Use the middle of the day so that subtracting hours doesn't cross the midnight boundary, 
      // or just explicitly specify hours on the same timestamp day.
      final user = createMockUser(waterLogTimestamps: List.generate(
        6,
        (i) => DateTime(now.year, now.month, now.day, 10 + i, 0),
      ));
      final result = IntegrityService.checkWaterRateLimit(user);
      expect(result.allowed, isFalse);
    });
  });

  group('IntegrityService - Wesker Decay', () {
    test('No decay if active today', () {
      final decay = IntegrityService.calculateWeskerDecay(
        currentPower: 50,
        lastActivityDate: DateTime.now(),
      );
      expect(decay, equals(0));
    });

    test('Decay is 2 per absent day', () {
      final decay = IntegrityService.calculateWeskerDecay(
        currentPower: 50,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(decay, equals(10)); // 5 days * 2
    });

    test('Decay capped at current power', () {
      final decay = IntegrityService.calculateWeskerDecay(
        currentPower: 5,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(decay, equals(5)); // Should normally be 20, but capped at 5
    });
  });
}
