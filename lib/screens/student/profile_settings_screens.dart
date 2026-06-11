import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

// ───────────────────────── EDIT PROFILE ─────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: Session.name);
  late final _email = TextEditingController(text: Session.email);
  late final _className = TextEditingController(text: Session.className);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _className.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(Session.userId, {
        'name': _name.text.trim(),
        'class_name': _className.text.trim(),
      });
      Session.name = _name.text.trim();
      Session.className = _className.text.trim();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        Session.name.isNotEmpty ? Session.name[0].toUpperCase() : 'S';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.primaryLight,
                child: Text(initial,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 38,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 28),
            _LabeledInput(label: 'Full Name', controller: _name),
            const SizedBox(height: 16),
            _LabeledInput(label: 'Email', controller: _email, enabled: false),
            const SizedBox(height: 16),
            _LabeledInput(label: 'Class', controller: _className),
            const SizedBox(height: 28),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    label: 'Save Changes',
                    icon: Icons.check_rounded,
                    onPressed: _save),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── NOTIFICATIONS ─────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _distraction = true, _streak = true, _peer = false, _daily = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _toggle('Distraction Alerts', 'Warn me when I lose focus',
                _distraction, (v) => setState(() => _distraction = v)),
            _toggle('Streak Warnings', 'Remind me before my streak breaks',
                _streak, (v) => setState(() => _streak = v)),
            _toggle('Peer Motivation', 'Tell me when classmates finish tasks',
                _peer, (v) => setState(() => _peer = v)),
            _toggle('Daily Reminders', 'A nudge to study every day', _daily,
                (v) => setState(() => _daily = v)),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          title: Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textMuted)),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ───────────────────────── PRIVACY ─────────────────────────
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _current = TextEditingController();
  final _newPass = TextEditingController();
  bool _shareProgress = true;
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (_current.text.isEmpty || _newPass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fill in both password fields.'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.changePassword(
          Session.userId, _current.text, _newPass.text);
      if (!mounted) return;
      _current.clear();
      _newPass.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password updated!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const SectionTitle(title: 'Change Password'),
            const SizedBox(height: 14),
            _LabeledInput(
                label: 'Current Password',
                controller: _current,
                obscure: true),
            const SizedBox(height: 16),
            _LabeledInput(
                label: 'New Password', controller: _newPass, obscure: true),
            const SizedBox(height: 14),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(label: 'Update Password', onPressed: _update),
            const SizedBox(height: 28),
            const SectionTitle(title: 'Data Sharing'),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Share progress with parents',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                subtitle: const Text('Allow parents to view your reports',
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted)),
                value: _shareProgress,
                onChanged: (v) => setState(() => _shareProgress = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── HELP ─────────────────────────
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      q: 'How does Focus Mode work?',
      a: 'Focus Mode blocks distracting apps for the time you choose so you can study without interruptions.'
    ),
    (
      q: 'How do I earn points and badges?',
      a: 'You earn points by completing homework and passing MCQ tests. Keeping a daily streak unlocks badges.'
    ),
    (
      q: 'What happens if I fail a test?',
      a: 'You can review the material and retry. You need 60% to pass and unlock your apps.'
    ),
    (
      q: 'How do I reset my password?',
      a: 'Go to Profile → Privacy & Security → Change Password.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const SectionTitle(title: 'Frequently Asked Questions'),
            const SizedBox(height: 14),
            ..._faqs.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(12, 0, 12, 14),
                        title: Text(f.q,
                            style: const TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w600)),
                        iconColor: AppColors.primary,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(f.a,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.4,
                                    color: AppColors.textMuted)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 12),
            const SectionTitle(title: 'Contact Us'),
            const SizedBox(height: 14),
            AppCard(
              child: Column(children: [
                _contactRow(Icons.mail_outline_rounded, 'Email',
                    'support@focusshield.app'),
                const Divider(height: 24),
                _contactRow(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(width: 12),
      Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
    ]);
  }
}

// ───────────────────────── shared input ─────────────────────────
class _LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool enabled;

  const _LabeledInput({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColors.surface : const Color(0xFFF3F4F6),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}
