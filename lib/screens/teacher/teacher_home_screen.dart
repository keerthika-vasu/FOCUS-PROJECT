import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'create_test_screen.dart';
import 'analytics_screen.dart';
import 'assign_homework_screen.dart';
import 'motivation_screen.dart';
import 'notes_screen.dart';
import '../shared/activity_log_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final results = await Future.wait([
      ApiService.analytics(),
      ApiService.getActivity(),
    ]);
    return results;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout(Session.email);
    } catch (_) {}
    Session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<dynamic>>(
            future: _future,
            builder: (context, snap) {
              final loading = snap.connectionState == ConnectionState.waiting;
              final analytics = (!loading && !snap.hasError)
                  ? snap.data![0] as Map<String, dynamic>
                  : <String, dynamic>{};
              final activity = (!loading && !snap.hasError)
                  ? snap.data![1] as List
                  : [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back,',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.textMuted)),
                          Text(Session.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.textMuted),
                        onPressed: _logout),
                  ]),
                  const SizedBox(height: 20),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Row(children: [
                      Expanded(
                        child: StatTile(
                            icon: Icons.groups_rounded,
                            value: '${analytics['total_students'] ?? 0}',
                            label: 'Students',
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                            icon: Icons.task_alt_rounded,
                            value:
                                '${(((analytics['completion_rate'] ?? 0) as num) * 100).round()}%',
                            label: 'Completion',
                            color: AppColors.success),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                            icon: Icons.bar_chart_rounded,
                            value: '${analytics['avg_score'] ?? 0}',
                            label: 'Avg Score',
                            color: AppColors.warning),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: 14),
                  _ActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Create MCQ Test',
                      subtitle: 'Add questions for your class',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const CreateTestScreen()))),
                  const SizedBox(height: 12),
                  _ActionCard(
                      icon: Icons.insights_rounded,
                      title: 'View Analytics',
                      subtitle: 'Class performance & ranking',
                      color: AppColors.success,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const AnalyticsScreen()))),
                  const SizedBox(height: 12),
                  _ActionCard(
                      icon: Icons.assignment_outlined,
                      title: 'Assign Homework',
                      subtitle: 'Share reading & study material',
                      color: AppColors.warning,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const AssignHomeworkScreen()))),
                  const SizedBox(height: 12),
                  _ActionCard(
                      icon: Icons.format_quote_rounded,
                      title: 'Daily Motivation',
                      subtitle: "Set today's quote for students",
                      color: AppColors.gold,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const MotivationScreen()))),
                  const SizedBox(height: 12),
                  _ActionCard(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'Class Notes',
                      subtitle: 'Post text notes students can read',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const TeacherNotesScreen()))),
                  const SizedBox(height: 12),
                  _ActionCard(
                      icon: Icons.history_rounded,
                      title: 'Login Activity',
                      subtitle: 'See student login & logout times',
                      color: AppColors.success,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ActivityLogScreen()))),
                  const SizedBox(height: 24),
                  if (!loading && activity.isNotEmpty) ...[
                    const SectionTitle(title: 'Recent Activity'),
                    const SizedBox(height: 12),
                    ...activity.take(3).map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (e['event'] == 'login'
                                          ? AppColors.success
                                          : AppColors.textMuted)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                    e['event'] == 'login'
                                        ? Icons.login_rounded
                                        : Icons.logout_rounded,
                                    color: e['event'] == 'login'
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      '${e['name']} ${e['event'] == 'login' ? 'logged in' : 'logged out'}',
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500))),
                              Text('${e['time'] ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted)),
                            ]),
                          ),
                        )),
                  ],
                ],
              );
            },
          ),
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
      child: Row(children: [
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
      ]),
    );
  }
}
