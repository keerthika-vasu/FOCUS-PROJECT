import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../shared/activity_log_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.parentDashboard(Session.userId);
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.parentDashboard(Session.userId));
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
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ListView(children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Center(
                      child: Text(
                          snap.error.toString().replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted))),
                  const SizedBox(height: 12),
                  Center(
                      child: TextButton(
                          onPressed: _refresh, child: const Text('Retry'))),
                ]);
              }
              final data = snap.data!;
              final tasksDone = (data['tasks_done'] ?? 0) as int;
              final tasksTotal = (data['tasks_total'] ?? 0) as int;
              final ratio = tasksTotal == 0 ? 0.0 : tasksDone / tasksTotal;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Parent Dashboard',
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
                  const SizedBox(height: 18),

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
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Text(
                            (data['child_name'] ?? 'S')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data['child_name'] ?? 'Student'}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700)),
                          Text('${data['class_name'] ?? ''}',
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: Color(0xFFFFB020), size: 18),
                            const SizedBox(width: 4),
                            Text('${data['streak'] ?? 0} day streak',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  Row(children: [
                    Expanded(
                      child: StatTile(
                          icon: Icons.timer_outlined,
                          value: '${data['focus_hours'] ?? 0}h',
                          label: 'Focus Time',
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                          icon: Icons.grade_rounded,
                          value: '${(data['avg_score_pct'] ?? 0).round()}%',
                          label: 'Avg Score',
                          color: AppColors.success),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  const SectionTitle(title: 'Homework Progress'),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tasks completed',
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600)),
                            Text('$tasksDone / $tasksTotal',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SectionTitle(title: 'Login Activity'),
                  const SizedBox(height: 12),
                  AppCard(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ActivityLogScreen(
                                studentId: Session.linkedStudentId))),
                    child: Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.history_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('View login & logout times',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            Text('See when your child uses the app',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
