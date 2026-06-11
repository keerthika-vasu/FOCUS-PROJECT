import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'mock_data.dart';
import 'common_widgets.dart';

class McqTestScreen extends StatefulWidget {
  const McqTestScreen({super.key});

  @override
  State<McqTestScreen> createState() => _McqTestScreenState();
}

class _McqTestScreenState extends State<McqTestScreen> {
  final _questions = MockData.quiz;
  int _current = 0;
  int? _selected;
  bool _submitted = false;
  int _score = 0;

  // Gamification state
  int _xp = 0; // total XP earned this test
  int _combo = 0; // current consecutive-correct streak
  int _bestCombo = 0;
  int _lastEarned = 0; // XP from the current question
  bool _finished = false;

  MCQQuestion get _q => _questions[_current];

  void _submit() {
    if (_selected == null) return;
    final correct = _selected == _q.correctIndex;
    setState(() {
      _submitted = true;
      if (correct) {
        _score++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        final bonus = _combo >= 2 ? (_combo - 1) * 10 : 0; // combo bonus
        _lastEarned = 20 + bonus;
        _xp += _lastEarned;
      } else {
        _combo = 0;
        _lastEarned = 0;
      }
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _submitted = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _selected = null;
      _submitted = false;
      _score = 0;
      _xp = 0;
      _combo = 0;
      _bestCombo = 0;
      _lastEarned = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();

    final isCorrect = _selected == _q.correctIndex;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Question ${_current + 1} of ${_questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          // Live XP pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: AppColors.gold, size: 18),
                const SizedBox(width: 4),
                Text('$_xp XP',
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress + combo row
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_current + 1) / _questions.length,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                  if (_combo >= 2) ...[
                    const SizedBox(width: 12),
                    AnimatedScale(
                      scale: 1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('🔥 ${_combo}x',
                            style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Question
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.help_outline_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(_q.question,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.35)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Options
              Expanded(
                child: ListView.separated(
                  itemCount: _q.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OptionTile(
                    text: _q.options[i],
                    index: i,
                    selected: _selected == i,
                    submitted: _submitted,
                    isCorrect: i == _q.correctIndex,
                    onTap: _submitted
                        ? null
                        : () => setState(() => _selected = i),
                  ),
                ),
              ),

              // Feedback banner
              if (_submitted) _feedbackBanner(isCorrect),
              const SizedBox(height: 12),

              PrimaryButton(
                label: _submitted
                    ? (_current == _questions.length - 1
                    ? 'See Results'
                    : 'Next Question')
                    : 'Submit Answer',
                onPressed:
                _selected == null ? null : (_submitted ? _next : _submit),
                icon: _submitted ? Icons.arrow_forward_rounded : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackBanner(bool correct) {
    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (correct ? AppColors.success : AppColors.danger)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(correct ? (_combo >= 3 ? '🔥' : '🎉') : '💪',
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    correct
                        ? 'Correct!  +$_lastEarned XP'
                        : 'Not quite — keep going, you\'ve got this!',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: correct ? AppColors.success : AppColors.danger,
                    ),
                  ),
                  if (correct && _combo >= 2)
                    Text('$_combo in a row — combo bonus!',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.warning)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final pct = _score / _questions.length;
    final passed = pct >= 0.6;
    final perfect = _score == _questions.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (passed ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    perfect
                        ? Icons.workspace_premium_rounded
                        : passed
                        ? Icons.emoji_events_rounded
                        : Icons.refresh_rounded,
                    size: 60,
                    color: passed ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                  perfect
                      ? 'Perfect Score! 🏆'
                      : passed
                      ? 'Great job! 🎊'
                      : 'Keep going! 📚',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'You passed the test. Apps unlocked!'
                    : 'You need 60% to pass. Review and retry.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              // XP earned banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.stars_rounded,
                        color: Colors.white, size: 30),
                    const SizedBox(height: 6),
                    Text('+$_xp XP',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700)),
                    const Text('Total earned',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Stats row
              Row(
                children: [
                  Expanded(
                      child: _miniStat('$_score/${_questions.length}',
                          'Correct', AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _miniStat('🔥 ${_bestCombo}x', 'Best Combo',
                          AppColors.warning)),
                ],
              ),
              const SizedBox(height: 24),

              if (!passed)
                PrimaryButton(
                    label: 'Retry Test',
                    icon: Icons.refresh_rounded,
                    color: AppColors.warning,
                    onPressed: _restart),
              if (passed)
                PrimaryButton(
                    label: 'Continue',
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                    onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final int index;
  final bool selected;
  final bool submitted;
  final bool isCorrect;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.text,
    required this.index,
    required this.selected,
    required this.submitted,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border = const Color(0xFFE5E7EB);
    Color bg = AppColors.surface;
    Color fg = AppColors.textDark;

    if (submitted) {
      if (isCorrect) {
        border = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.08);
        fg = AppColors.success;
      } else if (selected) {
        border = AppColors.danger;
        bg = AppColors.danger.withValues(alpha: 0.08);
        fg = AppColors.danger;
      }
    } else if (selected) {
      border = AppColors.primary;
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    }

    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (selected || (submitted && isCorrect))
                    ? fg
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                letters[index],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: (selected || (submitted && isCorrect))
                      ? Colors.white
                      : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: fg)),
            ),
            if (submitted && isCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22),
            if (submitted && selected && !isCorrect)
              const Icon(Icons.cancel_rounded,
                  color: AppColors.danger, size: 22),
          ],
        ),
      ),
    );
  }
}