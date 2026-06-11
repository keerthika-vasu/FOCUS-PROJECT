import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'mock_data.dart';
import 'common_widgets.dart';
import 'login_screen.dart';
import 'activity_log.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hello,',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textMuted)),
                        Text(MockData.parentName,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textMuted),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Child card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text('A',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MockData.studentName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const Text('Class 10 - A',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: Color(0xFFFFB020), size: 18),
                            const SizedBox(width: 4),
                            Text('${MockData.streak} day streak',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Login activity entry point
              AppCard(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ActivityLogScreen())),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: AppColors.success, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login Activity',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          Text('See when your child logs in & out',
                              style: TextStyle(
                                  fontSize: 12.5, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const SectionTitle(title: 'This Week'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                        icon: Icons.menu_book_rounded,
                        value: '8/10',
                        label: 'Tasks Done',
                        color: AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                        icon: Icons.timer_rounded,
                        value: '6.5h',
                        label: 'Focus Time',
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                        icon: Icons.grade_rounded,
                        value: '88%',
                        label: 'Avg Score',
                        color: AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Completion report
              const SectionTitle(title: 'Completion Report'),
              const SizedBox(height: 14),
              ...MockData.homework.map((hw) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: hw.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.book_rounded,
                            color: hw.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hw.subject,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted)),
                            Text(hw.title,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Icon(
                        hw.completed
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: hw.completed
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 8),

              // Focus behavior
              const SectionTitle(title: 'Focus Behavior'),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  children: [
                    _behaviorRow('Distraction attempts', '2 this week',
                        Icons.warning_amber_rounded, AppColors.warning),
                    const Divider(height: 24),
                    _behaviorRow('Sessions completed', '14 sessions',
                        Icons.check_circle_rounded, AppColors.success),
                    const Divider(height: 24),
                    _behaviorRow('Best focus day', 'Friday — 2.1h',
                        Icons.star_rounded, AppColors.gold),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _behaviorRow(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500))),
        Text(value,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}