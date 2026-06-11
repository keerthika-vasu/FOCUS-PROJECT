import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'mock_data.dart';
import 'common_widgets.dart';
import 'login_screen.dart';
import 'profile.dart';
import 'app_store.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryLight,
              child: Text('A',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            Text(MockData.studentName,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            const Text('Class 10 - A • Student',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: StatTile(
                      icon: Icons.local_fire_department_rounded,
                      value: '${MockData.streak}',
                      label: 'Day Streak',
                      color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                      icon: Icons.stars_rounded,
                      value: '${MockData.points}',
                      label: 'Points',
                      color: AppColors.gold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                      icon: Icons.emoji_events_rounded,
                      value: '3',
                      label: 'Badges',
                      color: AppColors.primary),
                ),
              ],
            ),
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
            PrimaryButton(
              label: 'Log Out',
              icon: Icons.logout_rounded,
              color: AppColors.danger,
              onPressed: () {
                AppStore.instance
                    .logEvent(MockData.studentName, isLogin: false);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
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
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted, size: 22),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}