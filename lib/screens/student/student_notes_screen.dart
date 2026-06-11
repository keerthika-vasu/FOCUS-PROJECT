import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class StudentNotesScreen extends StatefulWidget {
  const StudentNotesScreen({super.key});

  @override
  State<StudentNotesScreen> createState() => _StudentNotesScreenState();
}

class _StudentNotesScreenState extends State<StudentNotesScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                      child: Text('No notes from your teacher yet.',
                          style: TextStyle(color: AppColors.textMuted))),
                ]);
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
                          Row(children: [
                            const Icon(Icons.campaign_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${n['title']}',
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text('${n['created_at'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
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
