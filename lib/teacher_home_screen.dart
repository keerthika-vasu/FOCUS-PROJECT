import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'assign.dart';
import 'mock_data.dart';
import 'common_widgets.dart';
import 'login_screen.dart';
import 'create_test_screen.dart';
import 'analytics_screen.dart';
import 'motivation.dart';
import 'notes.dart';
import 'activity_log.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

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
                        const Text('Welcome back,',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textMuted)),
                        Text(MockData.teacherName,
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

              // Stats
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                        icon: Icons.groups_rounded,
                        value: '${MockData.totalStudents}',
                        label: 'Students',
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                        icon: Icons.task_alt_rounded,
                        value:
                        '${(MockData.completionRate * 100).round()}%',
                        label: 'Completion',
                        color: AppColors.success),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                        icon: Icons.bar_chart_rounded,
                        value: '${MockData.avgScore}',
                        label: 'Avg Score',
                        color: AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 14),
              _ActionCard(
                icon: Icons.add_circle_outline_rounded,
                title: 'Create MCQ Test',
                subtitle: 'Add questions for your class',
                color: AppColors.primary,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CreateTestScreen())),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.insights_rounded,
                title: 'View Analytics',
                subtitle: 'Class performance & weak areas',
                color: AppColors.success,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.assignment_outlined,
                title: 'Assign Homework',
                subtitle: 'Share reading & study material',
                color: AppColors.warning,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AssignHomeworkScreen())),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.format_quote_rounded,
                title: 'Daily Motivation',
                subtitle: 'Set today\'s quote for students',
                color: AppColors.gold,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MotivationScreen())),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.sticky_note_2_outlined,
                title: 'Class Notes',
                subtitle: 'Post text notes students can read',
                color: AppColors.primary,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TeacherNotesScreen())),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.history_rounded,
                title: 'Login Activity',
                subtitle: 'See student login & logout times',
                color: AppColors.success,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ActivityLogScreen())),
              ),
              const SizedBox(height: 24),

              const SectionTitle(title: 'Recent Activity'),
              const SizedBox(height: 12),
              _activity('Priya completed Laws of Motion', '5 min ago',
                  Icons.check_circle_rounded, AppColors.success),
              _activity('New test "Algebra Basics" published', '1 hr ago',
                  Icons.quiz_rounded, AppColors.primary),
              _activity('Karthik scored 9/10 in Science', '2 hr ago',
                  Icons.star_rounded, AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activity(String text, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w500))),
            Text(time,
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}