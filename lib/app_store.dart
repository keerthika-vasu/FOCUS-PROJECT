import 'package:flutter/foundation.dart';

/// A simple in-memory store shared across roles for one app session.
/// Replace these with your Flask API calls later — the structure maps
/// cleanly to endpoints (GET/POST motivation, notes, and activity).
class TeacherNote {
  final String title;
  final String body;
  final DateTime createdAt;
  TeacherNote(
      {required this.title, required this.body, required this.createdAt});
}

class SessionEvent {
  final String student;
  final bool isLogin; // true = login, false = logout
  final DateTime time;
  SessionEvent(
      {required this.student, required this.isLogin, required this.time});
}

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  // Today's motivation quote (teacher editable, student visible)
  String motivation =
      "Push yourself, because no one else is going to do it for you.";

  // Teacher text notes visible to students
  final List<TeacherNote> notes = [
    TeacherNote(
      title: "Tomorrow's Test",
      body:
      'Revise chapters 4 and 5. Focus on the formulas and solved examples in class.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // Login / logout activity (visible to teachers & parents)
  final List<SessionEvent> sessions = [];

  void setMotivation(String value) {
    motivation = value.trim();
    notifyListeners();
  }

  void addNote(String title, String body) {
    notes.insert(
      0,
      TeacherNote(
          title: title.trim(), body: body.trim(), createdAt: DateTime.now()),
    );
    notifyListeners();
  }

  void logEvent(String student, {required bool isLogin}) {
    sessions.insert(
      0,
      SessionEvent(student: student, isLogin: isLogin, time: DateTime.now()),
    );
    notifyListeners();
  }
}

/// Formats a DateTime like "10 Jun, 3:45 PM".
String formatDateTime(DateTime t) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  final ampm = t.hour >= 12 ? 'PM' : 'AM';
  return '${t.day} ${months[t.month - 1]}, $h:$m $ampm';
}