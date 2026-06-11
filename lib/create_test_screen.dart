import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'common_widgets.dart';

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _QuestionDraft {
  final questionCtrl = TextEditingController();
  final optionCtrls =
      List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;

  void dispose() {
    questionCtrl.dispose();
    for (final c in optionCtrls) {
      c.dispose();
    }
  }
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _titleCtrl = TextEditingController();
  final List<_QuestionDraft> _questions = [_QuestionDraft()];

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() => setState(() => _questions.add(_QuestionDraft()));

  void _removeQuestion(int i) {
    setState(() {
      _questions[i].dispose();
      _questions.removeAt(i);
    });
  }

  void _save() {
    // TODO: send title + questions to your Flask API.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test saved successfully!'),
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
        title: const Text('Create Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _field('Test Title', _titleCtrl, 'e.g. Algebra Basics'),
            const SizedBox(height: 20),
            ...List.generate(_questions.length, (i) {
              final q = _questions[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Question ${i + 1}',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                          if (_questions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.danger, size: 20),
                              onPressed: () => _removeQuestion(i),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _innerField(q.questionCtrl, 'Enter question'),
                      const SizedBox(height: 14),
                      const Text('Options (tap circle to mark correct)',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textMuted)),
                      const SizedBox(height: 10),
                      ...List.generate(4, (j) {
                        final correct = q.correctIndex == j;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => q.correctIndex = j),
                                child: Icon(
                                  correct
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: correct
                                      ? AppColors.success
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _innerField(
                                    q.optionCtrls[j],
                                    'Option ${String.fromCharCode(65 + j)}'),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Question'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        color: AppColors.background,
        child: PrimaryButton(
            label: 'Save Test',
            icon: Icons.save_rounded,
            onPressed: _save),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const SizedBox(height: 8),
        _innerField(ctrl, hint),
      ],
    );
  }

  Widget _innerField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
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
