import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../models/space.dart';
import '../providers/notes_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/spaces_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/candy_ui.dart';
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
            Text(
              'NoteVault',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.candyRose,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              notesProvider.showArchivedOnly
                  ? 'Archive vault'
                  : (filterSpace != null
                      ? '${filterSpace.emoji} ${filterSpace.name}'
                      : 'Your candy note space'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          if (notesProvider.isRealtimeConnected)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.cloud_done_rounded,
                size: 18,
                color: Colors.green.shade500,
              ),
            ),
          CandyIconButton(
            icon: Icons.auto_awesome_rounded,
            tooltip: 'Life Spaces',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpacesScreen()),
            ),
          ),
          CandyIconButton(
            icon: notesProvider.showArchivedOnly
                ? Icons.inventory_2_rounded
                : Icons.inventory_2_outlined,
            tooltip: notesProvider.showArchivedOnly ? 'Show active notes' : 'Archive',
            selected: notesProvider.showArchivedOnly,
            onPressed: () {
              notesProvider.setShowArchivedOnly(!notesProvider.showArchivedOnly);
              if (notesProvider.showArchivedOnly) {
                notesProvider.setFilterSpaceId(null);
              }
            },
          ),
          CandyIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          CandyIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CandyBody(
        child: notesProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notesProvider.errorMessage != null
                ? EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Something went wrong',
                    subtitle: notesProvider.errorMessage!,
                    action: CandyButton(
                      label: 'Try again',
                      icon: Icons.refresh_rounded,
                      expanded: false,
                      onPressed: () => context.read<NotesProvider>().reload(),
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
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: scheme.primary,
                            ),
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
                          !notesProvider.showArchivedOnly) ...[
                        if (spacesProvider.focusSpace != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: _HomeFocusStrip(
                              space: spacesProvider.focusSpace!,
                              weekCount: notesProvider.notesInSpaceThisWeek(
                                spacesProvider.focusSpace!.id,
                              ),
                              onTap: () => notesProvider
                                  .setFilterSpaceId(spacesProvider.focusSpace!.id),
                            ),
                          ),
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
                                    avatar: space.isFocus
                                        ? const Icon(Icons.star_rounded, size: 16)
                                        : null,
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
                      ],
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
                                    : CandyButton(
                                        label: 'New Note',
                                        icon: Icons.add_rounded,
                                        expanded: false,
                                        onPressed: () => _openEditor(context),
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
                                        childAspectRatio: columns == 1 ? 1.32 : 1.18,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
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
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Note'),
              backgroundColor: AppColors.candyRose,
              foregroundColor: Colors.white,
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

class _HomeFocusStrip extends StatelessWidget {
  const _HomeFocusStrip({
    required this.space,
    required this.weekCount,
    required this.onTap,
  });

  final Space space;
  final int weekCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.parseHex(space.colorHex);
    final progress = (weekCount / space.weeklyGoal).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.28),
                AppColors.candyBlush.withValues(alpha: 0.7),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(space.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Today’s Focus · ${space.name}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '$weekCount/${space.weeklyGoal}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.55),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
