import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../student/student_shell.dart';
import '../teacher/teacher_home_screen.dart';
import '../parent/parent_home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _childEmailCtrl = TextEditingController();
  String _role = 'student';
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  final _roles = const [
    ('student', 'Student', Icons.school_rounded),
    ('teacher', 'Teacher', Icons.cast_for_education_rounded),
    ('parent', 'Parent', Icons.family_restroom_rounded),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _childEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (_role == 'parent' && _childEmailCtrl.text.trim().isEmpty) {
      setState(() => _error = "Please enter your child's email.");
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'confirm_password': _confirmCtrl.text,
        'role': _role,
      };
      if (_role == 'parent') {
        payload['child_email'] = _childEmailCtrl.text.trim();
      }
      await ApiService.signup(payload);
      // Auto-login after successful signup
      final user =
          await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      Session.setFrom(user);
      if (!mounted) return;

      Widget destination;
      switch (Session.role) {
        case 'teacher':
          destination = const TeacherHomeScreen();
          break;
        case 'parent':
          destination = const ParentHomeScreen();
          break;
        default:
          destination = const StudentShell();
      }
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => destination));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Account',
                  style:
                      TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Join Focus Shield and start learning',
                  style: TextStyle(fontSize: 14.5, color: AppColors.textMuted)),
              const SizedBox(height: 28),
              const Text('I am a',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Row(
                children: _roles.map((r) {
                  final selected = r.$1 == _role;
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: r.$1 != 'parent' ? 10 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _role = r.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              Icon(r.$3,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  size: 24),
                              const SizedBox(height: 8),
                              Text(r.$2,
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _Field(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded),
              const SizedBox(height: 16),
              _Field(
                  label: 'Email',
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _Field(
                label: 'Password',
                controller: _passCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 16),
              _Field(
                  label: 'Confirm Password',
                  controller: _confirmCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure),
              if (_role == 'parent') ...[
                const SizedBox(height: 16),
                _Field(
                    label: "Child's Email",
                    controller: _childEmailCtrl,
                    hint: "Your child's student email",
                    icon: Icons.child_care_rounded,
                    keyboardType: TextInputType.emailAddress),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                      'Links your account to your child\'s student profile.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!,
                    style:
                        const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'Create Account',
                      icon: Icons.check_rounded,
                      onPressed: _signup),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign In',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surface,
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
          ),
        ),
      ],
    );
  }
}
