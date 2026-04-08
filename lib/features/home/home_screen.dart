import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: RequiemColors.bsaaRed));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('BSAA CLASSIFIED [LEVEL ${user.level}]'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '🔥 ${user.currentStreak} DAYS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RequiemColors.gold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AVATAR AREA placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: RequiemColors.tertiarySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RequiemColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 80, color: RequiemColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'State: ${_getAvatarStateText(user.avatarState)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // TODAY'S MISSION
            Text('TODAY\'S MISSION', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏋️ LOG WORKOUT', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('View your required sets and track progress.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RequiemColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('BEGIN MISSION'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // QUICK LOG
            Text('QUICK LOG', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(context, '💧 Water', Icons.water_drop, RequiemColors.intelBlue),
                _buildQuickAction(context, '🍽️ Meal', Icons.restaurant, RequiemColors.operative),
                _buildQuickAction(context, '😴 Sleep', Icons.bedtime, RequiemColors.shadow),
              ],
            ),
            const SizedBox(height: 24),

            // WESKER STATUS
            Text('WESKER THREAT LEVEL', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: RequiemColors.ember)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: user.weskerPower / 100,
              backgroundColor: RequiemColors.tertiarySurface,
              color: RequiemColors.wesker,
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text(
              '${user.weskerPower}% — "Contained. For now."',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RequiemColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RequiemColors.tertiarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }

  String _getAvatarStateText(int state) {
    switch (state) {
      case 0: return "Raccoon City Rookie";
      case 1: return "Field Agent";
      case 2: return "Government Operative";
      case 3: return "Veteran Operative";
      case 4: return "Elite Operative";
      case 5: return "Requiem Warrior";
      case 6: return "Requiem - Final Form";
      default: return "Unknown";
    }
  }
}
