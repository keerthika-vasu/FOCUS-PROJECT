import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class RewardsScreen extends StatefulWidget {
  final int refreshTick;
  const RewardsScreen({super.key, this.refreshTick = 0});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getRewards(Session.userId);
  }

  @override
  void didUpdateWidget(RewardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      setState(() => _future = ApiService.getRewards(Session.userId));
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.getRewards(Session.userId));
    await _future;
  }

  IconData _iconFor(String? name) {
    switch (name) {
      case 'bolt':
        return Icons.bolt_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'sparkles':
        return Icons.auto_awesome_rounded;
      case 'sun':
        return Icons.wb_sunny_rounded;
      case 'verified':
        return Icons.verified_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            final badges = List.from(data['badges'] ?? []);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                const Text('Rewards',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Earn points, badges and unlock themes',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(children: [
                    const Icon(Icons.stars_rounded,
                        color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    Text('${data['points'] ?? 0}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700)),
                    const Text('Total Points',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ]),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Your Badges'),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: badges.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (_, i) {
                    final b = badges[i];
                    final earned = b['earned'] == true;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: earned
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : const Color(0xFFF3F4F6),
                            ),
                            child: Icon(
                                earned
                                    ? _iconFor(b['icon'])
                                    : Icons.lock_rounded,
                                color: earned
                                    ? AppColors.gold
                                    : AppColors.textMuted,
                                size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text('${b['name']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: earned
                                      ? AppColors.textDark
                                      : AppColors.textMuted)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Unlockables'),
                const SizedBox(height: 14),
                _unlockRow(Icons.palette_rounded, 'Ocean Theme',
                    'Unlock at 1500 points', true),
                const SizedBox(height: 12),
                _unlockRow(Icons.face_rounded, 'Avatar Pack', 'Unlocked', false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _unlockRow(
      IconData icon, String title, String subtitle, bool locked) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        Icon(locked ? Icons.lock_rounded : Icons.check_circle_rounded,
            color: locked ? AppColors.textMuted : AppColors.success),
      ]),
    );
  }
}
