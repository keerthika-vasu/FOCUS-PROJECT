import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class AssignHomeworkScreen extends StatefulWidget {
  const AssignHomeworkScreen({super.key});

  @override
  State<AssignHomeworkScreen> createState() => _AssignHomeworkScreenState();
}

class _AssignHomeworkScreenState extends State<AssignHomeworkScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final Map<String, String> _subjectColors = const {
    'Mathematics': '#4F46E5',
    'Science': '#10B981',
    'English': '#F59E0B',
    'Social Studies': '#B5179E',
    'Computer': '#4361EE',
  };
  String _subject = 'Mathematics';
  DateTime _due = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _assign() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('Please enter a homework title.', AppColors.danger);
      return;
    }
    setState(() => _saving = true);
    final due =
        '${_due.year}-${_due.month.toString().padLeft(2, '0')}-${_due.day.toString().padLeft(2, '0')}';
    try {
      await ApiService.addHomework({
        'subject': _subject,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'color': _subjectColors[_subject],
        'due_date': due,
        'created_by': Session.userId,
      });
      if (!mounted) return;
      _snack('Homework assigned to your class!', AppColors.success);
      Navigator.pop(context);
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
    final dueText = '${_due.day}/${_due.month}/${_due.year}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Homework',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            const _Label('Subject'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _subject,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  items: _subjectColors.keys
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _subject = v!),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const _Label('Title'),
            const SizedBox(height: 8),
            _input(_titleCtrl, 'e.g. Quadratic Equations'),
            const SizedBox(height: 18),
            const _Label('Description / Instructions'),
            const SizedBox(height: 8),
            _input(_descCtrl, 'What should students do?', maxLines: 4),
            const SizedBox(height: 18),
            const _Label('Due Date'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: _pickDate,
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(dueText,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ]),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        color: AppColors.background,
        child: _saving
            ? const Center(child: CircularProgressIndicator())
            : PrimaryButton(
                label: 'Assign to Class',
                icon: Icons.send_rounded,
                onPressed: _assign),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted));
}
