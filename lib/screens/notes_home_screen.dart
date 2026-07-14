import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/responsive.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/page_container.dart';
import 'note_editor_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<NotesProvider>().reload();
      context.read<ProfileProvider>().loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Notes'),
        actions: [
          if (notesProvider.isRealtimeConnected)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.sync, size: 18, color: Colors.green),
            ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: notesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesProvider.errorMessage != null
              ? EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Something went wrong',
                  subtitle: notesProvider.errorMessage!,
                  action: FilledButton.icon(
                    onPressed: () => context.read<NotesProvider>().reload(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                )
              : notesProvider.notes.isEmpty
                  ? EmptyState(
                      icon: Icons.note_add_outlined,
                      title: 'No notes yet',
                      subtitle: 'Tap + New Note to create your first note.',
                      action: FilledButton.icon(
                        onPressed: () => _openEditor(context),
                        icon: const Icon(Icons.add),
                        label: const Text('New Note'),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = gridColumnCount(context);
                        return PageContainer(
                          padding: _gridPadding(context),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: columns == 1 ? 1.45 : 1.3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: notesProvider.notes.length,
                            itemBuilder: (context, index) {
                              final note = notesProvider.notes[index];
                              return NoteCard(
                                note: note,
                                onTap: () => _openEditor(context, note: note),
                                onDelete: () => _confirmDelete(context, note.id),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
    );
  }

  void _openEditor(BuildContext context, {Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final deleted = await context.read<NotesProvider>().deleteNote(id);
      if (!context.mounted) return;
      if (!deleted) {
        final error = context.read<NotesProvider>().errorMessage ?? 'Could not delete note';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  EdgeInsets _gridPadding(BuildContext context) {
    final base = pagePadding(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = maxContentWidth(context);
    if (screenWidth <= contentWidth) return base;
    final inset = (screenWidth - contentWidth) / 2;
    return EdgeInsets.fromLTRB(
      math.max(base.left, inset),
      base.top,
      math.max(base.right, inset),
      base.bottom,
    );
  }
}
