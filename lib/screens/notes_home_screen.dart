import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/spaces_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/page_container.dart';
import 'note_editor_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'spaces_screen.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> with WidgetsBindingObserver {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<NotesProvider>().reload();
      context.read<ProfileProvider>().loadProfile();
      context.read<SpacesProvider>().reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final spacesProvider = context.watch<SpacesProvider>();
    final scheme = Theme.of(context).colorScheme;
    final visible = notesProvider.visibleNotes;
    final filterSpace = spacesProvider.spaceById(notesProvider.filterSpaceId);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NoteVault',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              notesProvider.showArchivedOnly
                  ? 'Archive vault'
                  : (filterSpace != null
                      ? '${filterSpace.emoji} ${filterSpace.name}'
                      : 'Your candy note space'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          if (notesProvider.isRealtimeConnected)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.cloud_done_rounded, size: 18, color: Color(0xFF4CAF50)),
            ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpacesScreen()),
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Life Spaces',
          ),
          IconButton(
            onPressed: () {
              notesProvider.setShowArchivedOnly(!notesProvider.showArchivedOnly);
              if (notesProvider.showArchivedOnly) {
                notesProvider.setFilterSpaceId(null);
              }
            },
            icon: Icon(
              notesProvider.showArchivedOnly
                  ? Icons.inventory_2_rounded
                  : Icons.inventory_2_outlined,
            ),
            tooltip: notesProvider.showArchivedOnly ? 'Show active notes' : 'Archive',
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.candyBlush.withValues(alpha: 0.55),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: notesProvider.isLoading
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
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: notesProvider.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Search notes...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: notesProvider.searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      notesProvider.setSearchQuery('');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),
                      if (spacesProvider.spaces.isNotEmpty &&
                          !notesProvider.showArchivedOnly)
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FilterChip(
                                  label: const Text('All'),
                                  selected: notesProvider.filterSpaceId == null,
                                  onSelected: (_) => notesProvider.setFilterSpaceId(null),
                                ),
                              ),
                              ...spacesProvider.spaces.map(
                                (space) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: FilterChip(
                                    label: Text('${space.emoji} ${space.name}'),
                                    selected: notesProvider.filterSpaceId == space.id,
                                    onSelected: (_) =>
                                        notesProvider.setFilterSpaceId(space.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: visible.isEmpty
                            ? EmptyState(
                                icon: notesProvider.showArchivedOnly
                                    ? Icons.inventory_2_outlined
                                    : Icons.note_add_outlined,
                                title: notesProvider.showArchivedOnly
                                    ? 'Archive is empty'
                                    : (notesProvider.searchQuery.isNotEmpty
                                        ? 'No matching notes'
                                        : 'No notes yet'),
                                subtitle: notesProvider.showArchivedOnly
                                    ? 'Archived notes will appear here.'
                                    : 'Create a note, or organize with Life Spaces.',
                                action: notesProvider.showArchivedOnly
                                    ? null
                                    : FilledButton.icon(
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
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        childAspectRatio: columns == 1 ? 1.35 : 1.2,
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                      ),
                                      itemCount: visible.length,
                                      itemBuilder: (context, index) {
                                        final note = visible[index];
                                        return NoteCard(
                                          note: note,
                                          space: spacesProvider.spaceById(note.spaceId),
                                          isArchiveView: notesProvider.showArchivedOnly,
                                          onTap: () => _openEditor(context, note: note),
                                          onArchiveOrRestore: () =>
                                              _archiveOrRestore(context, note),
                                          onDelete: () =>
                                              _confirmDelete(context, note.id),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: notesProvider.showArchivedOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('New Note'),
            ),
    );
  }

  void _openEditor(BuildContext context, {Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  Future<void> _archiveOrRestore(BuildContext context, Note note) async {
    final provider = context.read<NotesProvider>();
    final ok = note.isArchived
        ? await provider.restoreNote(note.id)
        : await provider.archiveNote(note.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (note.isArchived ? 'Note restored' : 'Note archived')
              : (provider.errorMessage ?? 'Action failed'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This permanently deletes the note.'),
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
