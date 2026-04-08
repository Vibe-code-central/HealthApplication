import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class OpsScreen extends StatelessWidget {
  const OpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTIVE OPERATIONS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('WEEKLY CHALLENGE', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: RequiemColors.operative,
                        child: Text('GREEN', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RequiemColors.primaryBackground)),
                      ),
                      const SizedBox(width: 8),
                      Text('FIELD OPERATIVE', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Log 4 gym sessions this week.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.25,
                    backgroundColor: RequiemColors.tertiarySurface,
                    color: RequiemColors.gold,
                  ),
                  const SizedBox(height: 4),
                  Text('1 / 4 Sessions', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
