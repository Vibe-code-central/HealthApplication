import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const _screens = [
    HomeScreen(),
    CombatScreen(),
    NutritionScreen(),
    BsaaFileScreen(),
    OpsScreen(),
  ];

  static const _navItems = [
    _NavItem(Icons.shield_outlined, Icons.shield, 'MISSION'),
    _NavItem(Icons.fitness_center_outlined, Icons.fitness_center, 'COMBAT'),
    _NavItem(Icons.restaurant_outlined, Icons.restaurant, 'INTEL'),
    _NavItem(Icons.folder_outlined, Icons.folder_special, 'BSAA FILE'),
    _NavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'OPS'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const OnboardingScreen();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _ReNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── RE-styled bottom nav ─────────────────────────────────────────────────────

class _NavItem {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
  const _NavItem(this.outlinedIcon, this.filledIcon, this.label);
}

class _ReNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _ReNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RequiemColors.primaryBackground,
        border: Border(
          top: BorderSide(color: RequiemColors.borderBright, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: RequiemColors.bsaaRed.withOpacity(0.1),
                  highlightColor: RequiemColors.bsaaRed.withOpacity(0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isSelected
                              ? RequiemColors.bsaaRed
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.filledIcon : item.outlinedIcon,
                          size: 20,
                          color: isSelected
                              ? RequiemColors.bsaaRed
                              : RequiemColors.textMuted,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.barlowCondensed(
                            fontSize: 9,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? RequiemColors.bsaaRed
                                : RequiemColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
