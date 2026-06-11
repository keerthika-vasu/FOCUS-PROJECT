import 'dart:convert';
import 'package:http/http.dart' as http;
import '../url.dart';

/// All backend calls live here. Base URL comes from the shared Url class.
class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  static dynamic _handle(http.Response res) {
    final body =
        res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['error'] != null)
        ? body['error']
        : 'Request failed (${res.statusCode})';
    throw Exception(msg);
  }

  static Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('${Url.Urls}$path'));
    return _handle(res);
  }

  static Future<dynamic> _post(String path, Map body) async {
    final res = await http.post(Uri.parse('${Url.Urls}$path'),
        headers: _headers, body: jsonEncode(body));
    return _handle(res);
  }

  static Future<dynamic> _put(String path, Map body) async {
    final res = await http.put(Uri.parse('${Url.Urls}$path'),
        headers: _headers, body: jsonEncode(body));
    return _handle(res);
  }

  static Future<dynamic> _delete(String path) async {
    final res = await http.delete(Uri.parse('${Url.Urls}$path'));
    return _handle(res);
  }

  // ── AUTH ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('/login', {'email': email, 'password': password});
    return Map<String, dynamic>.from(data['user']);
  }

  static Future<void> signup(Map<String, dynamic> payload) async {
    await _post('/signup', payload);
  }

  static Future<void> logout(String email) async {
    await _post('/logout', {'email': email});
  }

  // ── PROFILE ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(int id) async =>
      Map<String, dynamic>.from(await _get('/profile/$id'));

  static Future<void> updateProfile(int id, Map<String, dynamic> body) async =>
      _put('/profile/$id', body);

  static Future<void> changePassword(
          int id, String current, String newPass) async =>
      _post('/change_password/$id',
          {'current_password': current, 'new_password': newPass});

  // ── ACTIVITY ──────────────────────────────────────────
  static Future<List> getActivity({int? studentId}) async {
    final q = studentId != null ? '?student_id=$studentId' : '';
    return List.from(await _get('/activity$q'));
  }

  // ── MOTIVATION ────────────────────────────────────────
  static Future<String> getMotivation() async {
    final data = await _get('/motivation');
    return data['quote'] ?? '';
  }

  static Future<void> setMotivation(String quote, int by) async =>
      _post('/motivation', {'quote': quote, 'created_by': by});

  // ── NOTES ─────────────────────────────────────────────
  static Future<List> getNotes() async => List.from(await _get('/notes'));

  static Future<void> addNote(String title, String body, int by) async =>
      _post('/notes', {'title': title, 'body': body, 'created_by': by});

  static Future<void> deleteNote(int id) async => _delete('/notes/$id');

  // ── HOMEWORK ──────────────────────────────────────────
  static Future<List> getHomework(int studentId) async =>
      List.from(await _get('/homework/$studentId'));

  static Future<void> addHomework(Map<String, dynamic> body) async =>
      _post('/homework', body);

  static Future<void> completeHomework(
          int homeworkId, int studentId, bool completed) async =>
      _post('/homework/$homeworkId/complete',
          {'student_id': studentId, 'completed': completed});

  // ── TESTS ─────────────────────────────────────────────
  static Future<List> getTests() async => List.from(await _get('/tests'));

  static Future<Map<String, dynamic>> getTest(int id) async =>
      Map<String, dynamic>.from(await _get('/tests/$id'));

  static Future<int> createTest(
      String title, int by, List<Map<String, dynamic>> questions) async {
    final data = await _post(
        '/tests', {'title': title, 'created_by': by, 'questions': questions});
    return data['id'] ?? 0;
  }

  static Future<Map<String, dynamic>> submitAttempt(Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await _post('/test_attempts', body));

  // ── REWARDS ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getRewards(int id) async =>
      Map<String, dynamic>.from(await _get('/rewards/$id'));

  // ── FOCUS ─────────────────────────────────────────────
  static Future<void> addFocusSession(
          int studentId, int minutes, bool completed) async =>
      _post('/focus_sessions',
          {'student_id': studentId, 'minutes': minutes, 'completed': completed});

  // ── DASHBOARDS ────────────────────────────────────────
  static Future<Map<String, dynamic>> studentDashboard(int id) async =>
      Map<String, dynamic>.from(await _get('/dashboard/student/$id'));

  static Future<Map<String, dynamic>> parentDashboard(int id) async =>
      Map<String, dynamic>.from(await _get('/dashboard/parent/$id'));

  static Future<Map<String, dynamic>> analytics() async =>
      Map<String, dynamic>.from(await _get('/analytics'));
}
