import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_requiem/models/weekly_challenge.dart';
import 'package:project_requiem/providers/user_provider.dart';
import 'package:project_requiem/core/integrity/weekly_challenge_generator.dart';

final weeklyChallengeProvider = StateNotifierProvider<WeeklyChallengeNotifier, WeeklyChallenge?>((ref) {
  return WeeklyChallengeNotifier(ref);
});

class WeeklyChallengeNotifier extends StateNotifier<WeeklyChallenge?> {
  final Ref _ref;

  WeeklyChallengeNotifier(this._ref) : super(null) {
    _init();
  }

  void _init() {
    final box = Hive.box<WeeklyChallenge>('weeklyChallengeBox');
    
    // Check if we have an active challenge
    if (box.isNotEmpty) {
      final current = box.getAt(0)!;
      if (current.expiresAt.isAfter(DateTime.now())) {
        state = current;
        return;
      }
    }

    // Generate a new challenge if none or expired
    _generateNewChallenge();
  }

  void _generateNewChallenge() {
    final box = Hive.box<WeeklyChallenge>('weeklyChallengeBox');
    
    final now = DateTime.now();
    final challenge = WeeklyChallengeGenerator.generateFor(now);

    box.put(0, challenge);
    state = challenge;
  }

  Future<void> incrementProgress() async {
    if (state == null || state!.completed) return;

    final currentProgress = state!.progress['combat_sessions'] as int? ?? 0;
    final target = state!.requirements['combat_sessions'] as int? ?? 4;

    final newProgress = currentProgress + 1;
    final isCompleted = newProgress >= target;

    final updated = WeeklyChallenge(
      challengeId: state!.challengeId,
      title: state!.title,
      description: state!.description,
      difficulty: state!.difficulty,
      requirements: state!.requirements,
      progress: {'combat_sessions': newProgress},
      xpReward: state!.xpReward,
      completed: isCompleted,
      expiresAt: state!.expiresAt,
    );

    final box = Hive.box<WeeklyChallenge>('weeklyChallengeBox');
    await box.put(0, updated);
    state = updated;

    if (isCompleted) {
      // Award bounty
      await _ref.read(userProvider.notifier).addXP(updated.xpReward);
      await _ref.read(userProvider.notifier).addGold(150);
    }
  }
}
