import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class ActivityLogScreen extends StatefulWidget {
  final int? studentId; // optional filter for a single student
  const ActivityLogScreen({super.key, this.studentId});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late Future<List> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getActivity(studentId: widget.studentId);
  }

  Future<void> _refresh() async {
    setState(
        () => _future = ApiService.getActivity(studentId: widget.studentId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ListView(children: [
                  const SizedBox(height: 140),
                  Center(
                      child: Text(
                          snap.error.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(color: AppColors.textMuted))),
                ]);
              }
              final logs = snap.data ?? [];
              if (logs.isEmpty) {
                return ListView(children: const [
                  SizedBox(height: 160),
                  Center(
                      child: Text('No login activity yet.',
                          style: TextStyle(color: AppColors.textMuted))),
                ]);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: logs.length,
                itemBuilder: (_, i) {
                  final e = logs[i];
                  final isLogin = e['event'] == 'login';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isLogin
                                    ? AppColors.success
                                    : AppColors.textMuted)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                              isLogin
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              color: isLogin
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e['name']}',
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600)),
                              Text(isLogin ? 'Logged in' : 'Logged out',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: isLogin
                                          ? AppColors.success
                                          : AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Text('${e['time'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
