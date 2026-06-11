import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.analytics();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.analytics());
    await _future;
  }

  Color _scoreColor(num pct) {
    if (pct < 50) return AppColors.danger;
    if (pct < 75) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
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
                  const SizedBox(height: 140),
                  Center(
                      child: Text(
                          snap.error.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(color: AppColors.textMuted))),
                ]);
              }
              final data = snap.data!;
              final ranking = List.from(data['ranking'] ?? []);
              final perf = List<Map<String, dynamic>>.from(
                  (data['test_performance'] ?? [])
                      .map((e) => Map<String, dynamic>.from(e)));
              final attempted =
                  perf.where((t) => (t['attempts'] ?? 0) > 0).toList();
              final weak = [...attempted]
                ..sort((a, b) =>
                    (a['avg_pct'] as num).compareTo(b['avg_pct'] as num));
              final completion =
                  (((data['completion_rate'] ?? 0) as num) * 100).round();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Row(children: [
                    Expanded(
                      child: StatTile(
                          icon: Icons.task_alt_rounded,
                          value: '$completion%',
                          label: 'Homework Done',
                          color: AppColors.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                          icon: Icons.grade_rounded,
                          value: '${data['avg_score'] ?? 0}/10',
                          label: 'Avg Score',
                          color: AppColors.primary),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  const SectionTitle(title: 'Average Score by Test'),
                  const SizedBox(height: 14),
                  if (attempted.isEmpty)
                    const AppCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No test attempts yet.',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    AppCard(
                      child: SizedBox(
                        height: 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: attempted.length > 1
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                          children: attempted.map((t) {
                            final pct = (t['avg_pct'] as num).toDouble();
                            final c = _scoreColor(pct);
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${pct.round()}%',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: c)),
                                  const SizedBox(height: 6),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    height: (110 * (pct / 100))
                                        .clamp(4, 110)
                                        .toDouble(),
                                    decoration: BoxDecoration(
                                      color: c,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      '${t['title']}'.length > 12
                                          ? '${'${t['title']}'.substring(0, 11)}…'
                                          : '${t['title']}',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  const SectionTitle(title: 'Needs Attention'),
                  const SizedBox(height: 14),
                  if (weak.isEmpty)
                    const AppCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                            'No data yet — assign a test to see weak areas.',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    ...weak.take(3).map((t) {
                      final pct = (t['avg_pct'] as num).toDouble();
                      final c = _scoreColor(pct);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('${t['title']}',
                                        style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  Text('${pct.round()}% avg',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: c)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation(c),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('${t['attempts']} attempt(s)',
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),

                  const SectionTitle(title: 'Top Students'),
                  const SizedBox(height: 14),
                  if (ranking.isEmpty)
                    const AppCard(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('No student data yet.',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: List.generate(ranking.length, (i) {
                          final r = ranking[i];
                          final medal = i == 0
                              ? AppColors.gold
                              : i == 1
                                  ? const Color(0xFF9CA3AF)
                                  : i == 2
                                      ? const Color(0xFFCD7F32)
                                      : AppColors.textMuted;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: medal.withValues(alpha: 0.15),
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      color: medal,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                            title: Text('${r['name']}',
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500)),
                            trailing: Text('${r['points']} pts',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          );
                        }),
                      ),
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
