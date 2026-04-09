import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    // ── Cinematic Feedback Listeners ───────────────────────
    ref.listen(userProvider, (previous, next) {
      if (previous == null || next == null) return;

      // 1. Level Up Detected
      if (next.level > previous.level) {
        _triggerCinematic(
          'CLEARANCE UPGRADED\nLVL ${next.level}',
          RequiemColors.gold,
          'NEW TACTICAL OPTIONS AVAILABLE',
        );
      }

      // 2. Streak Broken Detected
      if (next.currentStreak == 0 && previous.currentStreak > 0) {
        _triggerCinematic(
          'STREAK BROKEN.\nMISSION COMPROMISED.',
          RequiemColors.bsaaRed,
          'WESKER INFLUENCE SPREADING.',
          isError: true,
        );
      }
    });

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

  // ── Cinematic Overlay Engine ───────────────────────────────────────────────
  void _triggerCinematic(String mainText, Color color, String subText,
      {bool isError = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.warning_amber_rounded : Icons.shield,
                  color: color,
                  size: 64,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                        duration: 1200.ms, color: Colors.white.withOpacity(0.5))
                    .shake(hz: isError ? 4 : 0, curve: Curves.easeInOutCubic),
                const SizedBox(height: 24),
                Text(
                  mainText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    color: color,
                    fontSize: 42,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 400.ms,
                    curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: color.withOpacity(0.5)),
                    color: color.withOpacity(0.1),
                  ),
                  child: Text(
                    subText,
                    style: GoogleFonts.robotoMono(
                      color: RequiemColors.textPrimary,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.5, duration: 400.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    // Remove after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) entry.remove();
    });
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
