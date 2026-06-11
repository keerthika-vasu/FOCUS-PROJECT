import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_store.dart';
import 'common_widgets.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  late final TextEditingController _ctrl =
  TextEditingController(text: AppStore.instance.motivation);

  final _suggestions = const [
    "Believe you can and you're halfway there.",
    'Small progress is still progress.',
    'Discipline beats motivation. Show up today.',
    'Your only limit is you.',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_ctrl.text.trim().isEmpty) return;
    AppStore.instance.setMotivation(_ctrl.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Today's motivation updated!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text('This quote shows up on every student\'s home screen.',
                style: TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
            const SizedBox(height: 18),
            AppCard(
              child: TextField(
                controller: _ctrl,
                maxLines: 4,
                maxLength: 160,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type today\'s motivational quote...',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Quick Picks'),
            const SizedBox(height: 12),
            ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                onTap: () => setState(() => _ctrl.text = s),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(s,
                            style: const TextStyle(fontSize: 13.5))),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
            PrimaryButton(
                label: 'Set as Today\'s Motivation',
                icon: Icons.check_rounded,
                onPressed: _save),
          ],
        ),
      ),
    );
  }
}