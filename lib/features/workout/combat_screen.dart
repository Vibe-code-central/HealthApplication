import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class CombatScreen extends StatelessWidget {
  const CombatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold UI for Combat
    return Scaffold(
      appBar: AppBar(
        title: const Text('COMBAT LOG'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Briefing from Chris Redfield
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: RequiemColors.operative),
              color: RequiemColors.operative.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  children: [
                    const Icon(Icons.military_tech, color: RequiemColors.operative),
                    const SizedBox(width: 8),
                    Text('CHRIS REDFIELD — BRIEFING', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RequiemColors.operative)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "You've got one hour. Make it count, Kennedy.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text('MISSION OBJECTIVES', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          
          _buildExerciseCard(context, '1. BARBELL BENCH PRESS', '3 sets × 10-12 reps'),
          _buildExerciseCard(context, '2. INCLINE DUMBBELL PRESS', '3 sets × 10-12 reps'),
          _buildExerciseCard(context, '3. LAT PULLDOWN', '3 sets × 10-12 reps'),
          
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('COMPLETE MISSION'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, String name, String details) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
        subtitle: Text(details, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RequiemColors.textSecondary)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
             children: [
               _buildSetRow(context, 1),
               _buildSetRow(context, 2),
               _buildSetRow(context, 3),
             ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, int setNum) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('Set $setNum', style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          SizedBox(
            width: 70,
            child: TextField(
              decoration: const InputDecoration(hintText: 'kg', isDense: true),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 70,
            child: TextField(
              decoration: const InputDecoration(hintText: 'reps', isDense: true),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
