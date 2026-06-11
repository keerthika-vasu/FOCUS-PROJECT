/// Holds the currently logged-in user for the app session.
/// Set on login, cleared on logout.
class Session {
  static int userId = 0;
  static String name = '';
  static String email = '';
  static String role = 'student'; // student | teacher | parent
  static String className = '';
  static int linkedStudentId = 0;
  static int points = 0;
  static int streak = 0;

  static void setFrom(Map<String, dynamic> u) {
    userId = u['id'] ?? 0;
    name = u['name'] ?? '';
    email = u['email'] ?? '';
    role = u['role'] ?? 'student';
    className = u['class_name'] ?? '';
    linkedStudentId = u['linked_student_id'] ?? 0;
    points = u['points'] ?? 0;
    streak = u['streak'] ?? 0;
  }

  static void clear() {
    userId = 0;
    name = '';
    email = '';
    role = 'student';
    className = '';
    linkedStudentId = 0;
    points = 0;
    streak = 0;
  }
}
