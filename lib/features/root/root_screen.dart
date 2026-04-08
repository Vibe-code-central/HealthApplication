import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../providers/user_provider.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../workout/combat_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../profile/bsaa_file_screen.dart';
import '../challenges/ops_screen.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CombatScreen(),
    const NutritionScreen(),
    const BsaaFileScreen(),
    const OpsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const OnboardingScreen();
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: RequiemColors.border, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'MISSION'),
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'COMBAT'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'INTEL'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: 'BSAA FILE'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'OPS'),
          ],
        ),
      ),
    );
  }
}
