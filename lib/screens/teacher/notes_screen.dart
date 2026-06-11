import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/session.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class TeacherNotesScreen extends StatefulWidget {
  const TeacherNotesScreen({super.key});

  @override
  State<TeacherNotesScreen> createState() => _TeacherNotesScreenState();
}

class _TeacherNotesScreenState extends State<TeacherNotesScreen> {
  late Future<List> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getNotes();
  }

  Future<void> _refresh() async {
    setState(() => _future = ApiService.getNotes());
    await _future;
  }

  void _openComposer() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool posting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('New Class Note',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: _dec('Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  decoration: _dec('Write your note...'),
                ),
                const SizedBox(height: 16),
                posting
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        label: 'Post Note',
                        icon: Icons.send_rounded,
                        onPressed: () async {
                          if (bodyCtrl.text.trim().isEmpty &&
                              titleCtrl.text.trim().isEmpty) {
                            return;
                          }
                          setSheet(() => posting = true);
                          try {
                            await ApiService.addNote(
                                titleCtrl.text.trim().isEmpty
                                    ? 'Note'
                                    : titleCtrl.text.trim(),
                                bodyCtrl.text.trim(),
                                Session.userId);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _refresh();
                          } catch (e) {
                            setSheet(() => posting = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text(e
                                    .toString()
                                    .replaceFirst('Exception: ', '')),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          }
                        }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      );

  Future<void> _delete(int id) async {
    try {
      await ApiService.deleteNote(id);
      _refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _openComposer,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Note', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ListView(children: [
                  const SizedBox(height: 140),
                  Center(
                      child: Text(
                          snap.error.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(color: AppColors.textMuted))),
                ]);
              }
              final notes = snap.data ?? [];
              if (notes.isEmpty) {
                return ListView(children: const [
                  SizedBox(height: 160),
                  Center(
                      child: Text('No notes yet. Tap "New Note" to post one.',
                          style: TextStyle(color: AppColors.textMuted))),
                ]);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                itemCount: notes.length,
                itemBuilder: (_, i) {
                  final n = notes[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text('${n['title']}',
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text('${n['created_at'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _delete(n['id']),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.danger, size: 19),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text('${n['body']}',
                              style: const TextStyle(
                                  fontSize: 13.5, height: 1.4)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
