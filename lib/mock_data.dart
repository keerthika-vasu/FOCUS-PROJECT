import 'package:flutter/material.dart';

enum UserRole { student, teacher, parent }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.parent:
        return 'Parent';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.teacher:
        return Icons.cast_for_education_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
    }
  }
}

class MCQQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const MCQQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class Homework {
  final String subject;
  final String title;
  final bool completed;
  final Color color;

  const Homework({
    required this.subject,
    required this.title,
    required this.completed,
    required this.color,
  });
}

class Badge {
  final String name;
  final IconData icon;
  final bool earned;

  const Badge({required this.name, required this.icon, required this.earned});
}

/// In-memory demo data. Swap these with your Flask API responses later.
class MockData {
  static const studentName = 'Arjun';
  static const teacherName = 'Mrs. Rao';
  static const parentName = 'Mr. Sharma';

  static const int points = 1240;
  static const int streak = 7;

  static const List<Homework> homework = [
    Homework(
        subject: 'Mathematics',
        title: 'Quadratic Equations',
        completed: true,
        color: Color(0xFF4F46E5)),
    Homework(
        subject: 'Science',
        title: 'Laws of Motion',
        completed: false,
        color: Color(0xFF10B981)),
    Homework(
        subject: 'English',
        title: 'Essay: My Future',
        completed: false,
        color: Color(0xFFF59E0B)),
  ];

  static const List<MCQQuestion> quiz = [
    MCQQuestion(
      question: 'What is the value of x in 2x + 4 = 10?',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
    ),
    MCQQuestion(
      question: 'Which law states "every action has an equal and opposite reaction"?',
      options: ["Newton's First Law", "Newton's Second Law", "Newton's Third Law", "Law of Gravity"],
      correctIndex: 2,
    ),
    MCQQuestion(
      question: 'What is the chemical symbol for water?',
      options: ['O2', 'H2O', 'CO2', 'NaCl'],
      correctIndex: 1,
    ),
    MCQQuestion(
      question: 'Which is a prime number?',
      options: ['9', '15', '17', '21'],
      correctIndex: 2,
    ),
    MCQQuestion(
      question: 'The capital of India is?',
      options: ['Mumbai', 'Chennai', 'New Delhi', 'Kolkata'],
      correctIndex: 2,
    ),
  ];

  static const List<Badge> badges = [
    Badge(name: 'Focus Master', icon: Icons.bolt_rounded, earned: true),
    Badge(name: 'Gold Streak', icon: Icons.local_fire_department_rounded, earned: true),
    Badge(name: 'Study Champion', icon: Icons.emoji_events_rounded, earned: true),
    Badge(name: 'Quiz Wizard', icon: Icons.auto_awesome_rounded, earned: false),
    Badge(name: 'Early Bird', icon: Icons.wb_sunny_rounded, earned: false),
    Badge(name: 'Perfect Week', icon: Icons.verified_rounded, earned: false),
  ];

  static const List<String> blockedApps = [
    'Instagram',
    'YouTube',
    'Games',
    'WhatsApp',
  ];

  // Teacher analytics
  static const double completionRate = 0.80;
  static const double avgScore = 7.2;
  static const int totalStudents = 32;

  static const List<({String name, int score})> ranking = [
    (name: 'Priya M.', score: 95),
    (name: 'Arjun S.', score: 88),
    (name: 'Karthik R.', score: 82),
    (name: 'Sneha P.', score: 76),
    (name: 'Ravi K.', score: 71),
  ];

  static const List<({String topic, double mastery})> weakTopics = [
    (topic: 'Trigonometry', mastery: 0.42),
    (topic: 'Chemical Bonding', mastery: 0.55),
    (topic: 'Probability', mastery: 0.63),
  ];

  static const List<({String day, double value})> weeklyScores = [
    (day: 'Mon', value: 0.6),
    (day: 'Tue', value: 0.75),
    (day: 'Wed', value: 0.5),
    (day: 'Thu', value: 0.85),
    (day: 'Fri', value: 0.9),
    (day: 'Sat', value: 0.7),
  ];
}
