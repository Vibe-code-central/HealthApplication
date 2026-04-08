import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box<UserProfile>('userProfileBox');
    if (box.isNotEmpty) {
      state = box.getAt(0);
    }
  }

  Future<void> createProfile(String name, double height, double weight) async {
    final newProfile = UserProfile(
      name: name,
      startingWeight: weight,
      currentWeight: weight,
      heightCm: height,
      totalXP: 0,
      level: 1,
      weskerPower: 0,
      avatarState: 0,
      programmeStart: DateTime.now(),
      currentStreak: 0,
      longestStreak: 0,
    );
    
    final box = Hive.box<UserProfile>('userProfileBox');
    await box.add(newProfile);
    state = newProfile;
  }

  Future<void> addXP(int amount) async {
    if (state == null) return;
    
    int newXP = state!.totalXP + amount;
    int newLevel = _calculateLevel(newXP);
    
    await _updateState(
      state!.totalXP = newXP,
      state!.level = newLevel,
    );
    _calculateAvatarState();
  }

  Future<void> addWeskerPower(int amount) async {
    if (state == null) return;
    
    int newPower = (state!.weskerPower + amount).clamp(0, 100);
    await _updateState(state!.weskerPower = newPower);
  }

  Future<void> reduceWeskerPower(int amount) async {
    if (state == null) return;
    
    int newPower = (state!.weskerPower - amount).clamp(0, 100);
    await _updateState(state!.weskerPower = newPower);
  }

  int _calculateLevel(int xp) {
    // Basic curve: level = 1 + sqrt(xp / 100) or similar
    // Max level 50
    int level = 1 + (xp / 500).floor();
    return level.clamp(1, 50);
  }

  Future<void> _calculateAvatarState() async {
    if (state == null) return;
    // For MVP, avatar state loosely based on level
    // state 0: level 1-5
    // state 1: level 6-12
    // state 2: level 13-20
    // state 3: level 21-28
    // state 4: level 29-37
    // state 5: level 38-46
    // state 6: level 47-50
    int newState = state!.avatarState;
    if (state!.level >= 47) newState = 6;
    else if (state!.level >= 38) newState = 5;
    else if (state!.level >= 29) newState = 4;
    else if (state!.level >= 21) newState = 3;
    else if (state!.level >= 13) newState = 2;
    else if (state!.level >= 6) newState = 1;

    // Never decrease avatar state
    if (newState > state!.avatarState) {
      await _updateState(state!.avatarState = newState);
    }
  }

  Future<void> _updateState(dynamic _, [dynamic __]) async {
    final box = Hive.box<UserProfile>('userProfileBox');
    await box.putAt(0, state!);
    state = UserProfile(
      name: state!.name,
      startingWeight: state!.startingWeight,
      currentWeight: state!.currentWeight,
      heightCm: state!.heightCm,
      totalXP: state!.totalXP,
      level: state!.level,
      weskerPower: state!.weskerPower,
      avatarState: state!.avatarState,
      programmeStart: state!.programmeStart,
      currentStreak: state!.currentStreak,
      longestStreak: state!.longestStreak,
    );
  }
}
