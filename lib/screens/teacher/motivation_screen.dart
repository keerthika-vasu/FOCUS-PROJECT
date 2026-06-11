import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final _ctrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _current = '';

  static const _suggestions = [
    'Push yourself, because no one else is going to do it for you.',
    'Success is the sum of small efforts repeated day in and day out.',
    "Don't watch the clock; do what it does. Keep going.",
    'The future belongs to those who believe in their dreams.',
    'Little progress each day adds up to big results.',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final quote = await ApiService.getMotivation();
      setState(() {
        _current = quote;
        _ctrl.text = quote;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) {
      _snack('Please enter a quote.', AppColors.danger);
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.setMotivation(_ctrl.text.trim(), Session.userId);
      setState(() => _current = _ctrl.text.trim());
      if (!mounted) return;
      _snack("Today's motivation updated!", AppColors.success);
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''), AppColors.danger);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  if (_current.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, Color(0xFFEF4444)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.format_quote_rounded,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text('Live now for students',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 10),
                          Text(_current,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: "Set Today's Quote"),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type a motivational message...',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _saving
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          label: 'Publish Quote',
                          icon: Icons.send_rounded,
                          onPressed: _save),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Suggestions'),
                  const SizedBox(height: 12),
                  ..._suggestions.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => setState(() => _ctrl.text = s),
                          child: Row(children: [
                            const Icon(Icons.add_circle_outline_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(s,
                                    style: const TextStyle(
                                        fontSize: 13.5, height: 1.35))),
                          ]),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
