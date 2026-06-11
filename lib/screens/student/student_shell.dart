import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'student_home_screen.dart';
import 'focus_mode_screen.dart';
import 'rewards_screen.dart';
import 'student_profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  // Bumping a tab's tick makes that screen reload its data when reopened.
  int _homeTick = 0;
  int _rewardsTick = 0;
  int _profileTick = 0;

  void _onSelect(int i) {
    setState(() {
      _index = i;
      if (i == 0) _homeTick++;
      if (i == 2) _rewardsTick++;
      if (i == 3) _profileTick++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      StudentHomeScreen(refreshTick: _homeTick),
      const FocusModeScreen(),
      RewardsScreen(refreshTick: _rewardsTick),
      StudentProfileScreen(refreshTick: _profileTick),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryLight,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          child: NavigationBar(
            height: 68,
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.shield_outlined),
                selectedIcon:
                    Icon(Icons.shield_rounded, color: AppColors.primary),
                label: 'Focus',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon:
                    Icon(Icons.emoji_events_rounded, color: AppColors.primary),
                label: 'Rewards',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon:
                    Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
