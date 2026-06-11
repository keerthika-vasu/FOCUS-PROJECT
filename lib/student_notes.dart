import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_store.dart';
import 'common_widgets.dart';

class StudentNotesScreen extends StatelessWidget {
  const StudentNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppStore.instance,
          builder: (context, _) {
            final notes = AppStore.instance.notes;
            if (notes.isEmpty) {
              return const Center(
                child: Text('No notes from your teacher yet.',
                    style: TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                            const Icon(Icons.campaign_rounded,
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
    );
  }
}