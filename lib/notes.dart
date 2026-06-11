import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_store.dart';
import 'common_widgets.dart';

class TeacherNotesScreen extends StatelessWidget {
  const TeacherNotesScreen({super.key});

  void _showAddSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('New Note',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _sheetField(titleCtrl, 'Title (e.g. Reminder)'),
            const SizedBox(height: 12),
            _sheetField(bodyCtrl, 'Write your note for students...',
                maxLines: 4),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Post Note',
              icon: Icons.send_rounded,
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty &&
                    bodyCtrl.text.trim().isEmpty) {
                  return;
                }
                AppStore.instance.addNote(
                    titleCtrl.text.isEmpty ? 'Note' : titleCtrl.text,
                    bodyCtrl.text);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sheetField(TextEditingController c, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Note',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppStore.instance,
          builder: (context, _) {
            final notes = AppStore.instance.notes;
            if (notes.isEmpty) {
              return const Center(
                child: Text('No notes yet. Tap "Add Note" to post one.',
                    style: TextStyle(color: AppColors.textMuted)),
              );
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
                        Row(
                          children: [
                            const Icon(Icons.push_pin_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(n.title,
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text(formatDateTime(n.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(n.body,
                            style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.4,
                                color: AppColors.textDark)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}