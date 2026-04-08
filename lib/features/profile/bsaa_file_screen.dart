import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class BsaaFileScreen extends StatelessWidget {
  const BsaaFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BSAA CLASSIFIED FILE'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_special, size: 80, color: RequiemColors.textSecondary),
            const SizedBox(height: 16),
            Text('DOSSIER DATA UNAVAILABLE IN MVP', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
