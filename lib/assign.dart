import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'common_widgets.dart';

class AssignHomeworkScreen extends StatefulWidget {
  const AssignHomeworkScreen({super.key});

  @override
  State<AssignHomeworkScreen> createState() => _AssignHomeworkScreenState();
}

class _AssignHomeworkScreenState extends State<AssignHomeworkScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _subjects = const [
    'Mathematics',
    'Science',
    'English',
    'Social Studies',
    'Computer'
  ];
  String _subject = 'Mathematics';
  DateTime _due = DateTime.now().add(const Duration(days: 1));

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

  void _assign() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a homework title.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // TODO: send to your Flask API (subject, title, description, due date).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Homework assigned to your class!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dueText =
        '${_due.day}/${_due.month}/${_due.year}';
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
                  items: _subjects
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
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(dueText,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        color: AppColors.background,
        child: PrimaryButton(
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