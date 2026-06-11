import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'profile_settings_screens.dart';

class StudentProfileScreen extends StatefulWidget {
  final int refreshTick;
  const StudentProfileScreen({super.key, this.refreshTick = 0});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _loggingOut = false;
  int _points = Session.points;
  int _streak = Session.streak;
  int _badges = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(StudentProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getRewards(Session.userId);
      final badges = List.from(data['badges'] ?? []);
      if (!mounted) return;
      setState(() {
        _points = data['points'] ?? Session.points;
        _streak = data['streak'] ?? Session.streak;
        _badges = badges.where((b) => b['earned'] == true).length;
      });
      Session.points = _points;
      Session.streak = _streak;
    } catch (_) {/* keep session fallback values */}
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
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
    final initial =
        Session.name.isNotEmpty ? Session.name[0].toUpperCase() : 'S';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryLight,
              child: Text(initial,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            Text(Session.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(
                '${Session.className.isNotEmpty ? "${Session.className} • " : ""}Student',
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: StatTile(
                    icon: Icons.local_fire_department_rounded,
                    value: '$_streak',
                    label: 'Day Streak',
                    color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                    icon: Icons.stars_rounded,
                    value: '$_points',
                    label: 'Points',
                    color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                    icon: Icons.emoji_events_rounded,
                    value: '$_badges',
                    label: 'Badges',
                    color: AppColors.primary),
              ),
            ]),
            const SizedBox(height: 24),
            _MenuTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _MenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _MenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & Security',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
            _MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()))),
            const SizedBox(height: 12),
            _loggingOut
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    label: 'Log Out',
                    icon: Icons.logout_rounded,
                    color: AppColors.danger,
                    onPressed: _logout),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}
