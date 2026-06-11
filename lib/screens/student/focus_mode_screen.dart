import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  static const List<int> _presets = [15, 25, 45, 60];
  static const List<String> _blockedApps = [
    'Instagram', 'YouTube', 'Games', 'WhatsApp'
  ];

  int _sessionMinutes = 25;
  late int _remaining = _sessionMinutes * 60;
  bool _active = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setMinutes(int m) {
    if (_active) return;
    setState(() {
      _sessionMinutes = m;
      _remaining = m * 60;
    });
  }

  void _adjust(int delta) {
    if (_active) return;
    _setMinutes((_sessionMinutes + delta).clamp(5, 120));
  }

  Future<void> _logSession(bool completed) async {
    try {
      await ApiService.addFocusSession(
          Session.userId, _sessionMinutes, completed);
    } catch (_) {/* ignore network errors for logging */}
  }

  void _toggle() {
    if (_active) {
      _timer?.cancel();
      _logSession(false); // ended early
      setState(() {
        _active = false;
        _remaining = _sessionMinutes * 60;
      });
    } else {
      setState(() => _active = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining <= 1) {
          t.cancel();
          _logSession(true); // completed fully
          setState(() {
            _active = false;
            _remaining = _sessionMinutes * 60;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Focus session complete! 🎉'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          setState(() => _remaining--);
        }
      });
    }
  }

  String get _timeText {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remaining / (_sessionMinutes * 60));
    return Scaffold(
      backgroundColor: _active ? AppColors.primaryDark : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Focus Mode',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _active ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 4),
              Text(
                _active
                    ? 'Distractions are blocked. Stay focused!'
                    : 'Choose your time, then start your session',
                style: TextStyle(
                    fontSize: 14,
                    color: _active ? Colors.white70 : AppColors.textMuted),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: _active ? progress : 0,
                          strokeWidth: 12,
                          backgroundColor: _active
                              ? Colors.white24
                              : const Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation(
                              _active ? Colors.white : AppColors.primary),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded,
                              size: 30,
                              color:
                                  _active ? Colors.white : AppColors.primary),
                          const SizedBox(height: 8),
                          Text(_timeText,
                              style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: _active
                                      ? Colors.white
                                      : AppColors.textDark)),
                          Text(
                              _active
                                  ? 'remaining'
                                  : '$_sessionMinutes min session',
                              style: TextStyle(
                                  color: _active
                                      ? Colors.white70
                                      : AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_active) ...[
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: _presets.map((m) {
                    final selected = m == _sessionMinutes;
                    return GestureDetector(
                      onTap: () => _setMinutes(m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : const Color(0xFFE5E7EB)),
                        ),
                        child: Text('$m min',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDark)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stepBtn(Icons.remove_rounded, () => _adjust(-5)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Adjust by 5 min',
                          style:
                              TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ),
                    _stepBtn(Icons.add_rounded, () => _adjust(5)),
                  ],
                ),
              ] else ...[
                const Text('Blocked during focus',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _blockedApps.map((app) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.lock_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(app,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ]),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: _active ? 'End Session' : 'Start Focus Session',
                icon: _active ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: _active ? AppColors.danger : AppColors.primary,
                onPressed: _toggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
