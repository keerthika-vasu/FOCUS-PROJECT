import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'mock_data.dart';
import 'common_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            // Summary
            Row(
              children: [
                Expanded(
                  child: StatTile(
                      icon: Icons.task_alt_rounded,
                      value: '${(MockData.completionRate * 100).round()}%',
                      label: 'Homework Done',
                      color: AppColors.success),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                      icon: Icons.grade_rounded,
                      value: '${MockData.avgScore}/10',
                      label: 'Avg Score',
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weekly performance bar chart
            const SectionTitle(title: 'Weekly Performance'),
            const SizedBox(height: 14),
            AppCard(
              child: SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: MockData.weeklyScores.map((e) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${(e.value * 100).round()}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 6),
                            height: 110 * e.value,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(e.day,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weak topics
            const SectionTitle(title: 'Weak Areas'),
            const SizedBox(height: 14),
            ...MockData.weakTopics.map((t) => Padding(
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
                            Text(t.topic,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600)),
                            Text('${(t.mastery * 100).round()}% mastery',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: t.mastery < 0.5
                                        ? AppColors.danger
                                        : AppColors.warning)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: t.mastery,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation(
                                t.mastery < 0.5
                                    ? AppColors.danger
                                    : AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 12),

            // Ranking
            const SectionTitle(title: 'Top Students'),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: List.generate(MockData.ranking.length, (i) {
                  final r = MockData.ranking[i];
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
                    title: Text(r.name,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w500)),
                    trailing: Text('${r.score}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
