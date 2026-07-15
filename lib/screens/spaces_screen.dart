import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/space.dart';
import '../providers/notes_provider.dart';
import '../providers/spaces_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validation_utils.dart';
import '../widgets/candy_ui.dart';
import '../widgets/empty_state.dart';

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  static const _emojiOptions = [
    '💗', '📚', '💼', '🎓', '🏠', '✨', '🎯', '🌈', '📝', '🧠', '🚀', '🎨',
  ];

  @override
  Widget build(BuildContext context) {
    final spacesProvider = context.watch<SpacesProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final scheme = Theme.of(context).colorScheme;
    final focus = spacesProvider.focusSpace;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Life Spaces',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.candyRose,
                fontWeight: FontWeight.w800,
              ),
        ),
        leading: CandyIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CandyIconButton(
            icon: Icons.add_rounded,
            tooltip: 'New space',
            onPressed: () => _showSpaceEditor(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CandyBody(
        child: spacesProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await spacesProvider.reload();
                  await notesProvider.reload();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (spacesProvider.errorMessage != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Card(
                            color: scheme.errorContainer.withValues(alpha: 0.55),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                spacesProvider.errorMessage!,
                                style: TextStyle(color: scheme.onErrorContainer),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick templates',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 42,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: SpaceTemplate.presets.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final template = SpaceTemplate.presets[index];
                                  return ActionChip(
                                    avatar: Text(template.emoji),
                                    label: Text(template.name),
                                    onPressed: () async {
                                      final ok = await spacesProvider.addFromTemplate(template);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? '${template.name} Space ready'
                                                : (spacesProvider.errorMessage ??
                                                    'Could not create template'),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            if (focus != null) ...[
                              const SizedBox(height: 14),
                              _FocusBanner(
                                space: focus,
                                weekCount: notesProvider.notesInSpaceThisWeek(focus.id),
                                onOpen: () {
                                  notesProvider.setFilterSpaceId(focus.id);
                                  notesProvider.setShowArchivedOnly(false);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (spacesProvider.spaces.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Create your first Life Space',
                          subtitle:
                              'Use templates or craft your own space with mood, motto, weekly goals, and Today’s Focus.',
                          action: CandyButton(
                            label: 'New Space',
                            icon: Icons.auto_awesome_rounded,
                            expanded: false,
                            onPressed: () => _showSpaceEditor(context),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        sliver: SliverList.separated(
                          itemCount: spacesProvider.spaces.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final space = spacesProvider.spaces[index];
                            final weekCount =
                                notesProvider.notesInSpaceThisWeek(space.id);
                            final totalCount = notesProvider.notesInSpace(space.id);
                            return _SpaceCard(
                              space: space,
                              weekCount: weekCount,
                              totalCount: totalCount,
                              onOpen: () {
                                notesProvider.setFilterSpaceId(space.id);
                                notesProvider.setShowArchivedOnly(false);
                                Navigator.pop(context);
                              },
                              onEdit: () => _showSpaceEditor(context, spaceId: space.id),
                              onToggleFocus: () async {
                                final ok = space.isFocus
                                    ? await spacesProvider.clearFocusSpace(space.id)
                                    : await spacesProvider.setFocusSpace(space.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? (space.isFocus
                                              ? 'Focus cleared'
                                              : '${space.name} is today’s focus')
                                          : (spacesProvider.errorMessage ?? 'Update failed'),
                                    ),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDelete(context, space),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSpaceEditor(context),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('New Space'),
        backgroundColor: AppColors.candyRose,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Space space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete space?'),
        content: Text(
          'Delete “${space.name}”? Notes stay safe and become unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final notesProvider = context.read<NotesProvider>();
    final ok = await context.read<SpacesProvider>().deleteSpace(space.id);
    if (!context.mounted) return;
    if (notesProvider.filterSpaceId == space.id) {
      notesProvider.setFilterSpaceId(null);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Space deleted'
              : (context.read<SpacesProvider>().errorMessage ?? 'Delete failed'),
        ),
      ),
    );
  }

  Future<void> _showSpaceEditor(BuildContext context, {String? spaceId}) async {
    final spacesProvider = context.read<SpacesProvider>();
    final existing = spaceId == null ? null : spacesProvider.spaceById(spaceId);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final mottoController = TextEditingController(text: existing?.motto ?? '');
    var emoji = existing?.emoji ?? '💗';
    var colorHex = existing?.colorHex ?? AppColors.toHex(AppColors.spacePalette.first);
    var mood = existing?.mood ?? SpaceMood.focus;
    var weeklyGoal = existing?.weeklyGoal ?? 5;
    var isFocus = existing?.isFocus ?? false;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existing == null ? 'New Life Space' : 'Edit Life Space',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set mood, motto, weekly goal, and optionally make it Today’s Focus.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Space name'),
                        textInputAction: TextInputAction.next,
                        validator: ValidationUtils.validateSpaceName,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mottoController,
                        decoration: const InputDecoration(
                          labelText: 'Motto (optional)',
                          hintText: 'e.g. One focused note at a time',
                        ),
                        maxLength: 80,
                        validator: ValidationUtils.validateSpaceMotto,
                      ),
                      const SizedBox(height: 8),
                      Text('Mood vibe', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SpaceMood.values.map((item) {
                          return ChoiceChip(
                            label: Text('${item.emoji} ${item.label}'),
                            selected: mood == item,
                            onSelected: (_) => setModalState(() => mood = item),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Weekly note goal: $weeklyGoal',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Slider(
                        value: weeklyGoal.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '$weeklyGoal',
                        onChanged: (value) =>
                            setModalState(() => weeklyGoal = value.round()),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Today’s Focus Space'),
                        subtitle: const Text('Highlight this space on top of Life Spaces'),
                        value: isFocus,
                        onChanged: (value) => setModalState(() => isFocus = value),
                      ),
                      const SizedBox(height: 8),
                      Text('Emoji', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _emojiOptions.map((item) {
                          return ChoiceChip(
                            label: Text(item, style: const TextStyle(fontSize: 18)),
                            selected: item == emoji,
                            onSelected: (_) => setModalState(() => emoji = item),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Candy color', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppColors.spacePalette.map((color) {
                          final hex = AppColors.toHex(color);
                          final selected = hex == colorHex;
                          return GestureDetector(
                            onTap: () => setModalState(() => colorHex = hex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.45),
                                    blurRadius: selected ? 10 : 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      CandyButton(
                        label: existing == null ? 'Create Space' : 'Save Space',
                        icon: existing == null
                            ? Icons.auto_awesome_rounded
                            : Icons.check_rounded,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final name = SanitizationUtils.sanitizeText(
                            nameController.text,
                            maxLength: 40,
                          );
                          final motto = SanitizationUtils.sanitizeText(
                            mottoController.text,
                            maxLength: 80,
                          );
                          final ok = existing == null
                              ? await spacesProvider.addSpace(
                                  name: name,
                                  emoji: emoji,
                                  colorHex: colorHex,
                                  motto: motto.isEmpty ? null : motto,
                                  mood: mood,
                                  weeklyGoal: weeklyGoal,
                                  isFocus: isFocus,
                                )
                              : await spacesProvider.updateSpace(
                                  existing.copyWith(
                                    name: name,
                                    emoji: emoji,
                                    colorHex: colorHex,
                                    motto: motto.isEmpty ? null : motto,
                                    mood: mood,
                                    weeklyGoal: weeklyGoal,
                                    isFocus: isFocus,
                                    clearMotto: motto.isEmpty,
                                  ),
                                );
                          if (!context.mounted) return;
                          final messenger = ScaffoldMessenger.of(context);
                          final message = ok
                              ? (existing == null
                                  ? 'Life Space created'
                                  : 'Life Space updated')
                              : (spacesProvider.errorMessage ??
                                  'Could not save Life Space');
                          Navigator.pop(context);
                          messenger.showSnackBar(SnackBar(content: Text(message)));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    mottoController.dispose();
  }
}

class _FocusBanner extends StatelessWidget {
  const _FocusBanner({
    required this.space,
    required this.weekCount,
    required this.onOpen,
  });

  final Space space;
  final int weekCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.parseHex(space.colorHex);
    final progress = (weekCount / space.weeklyGoal).clamp(0.0, 1.0);

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.35),
              AppColors.candyBlush.withValues(alpha: 0.65),
            ],
          ),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Text(space.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Focus · ${space.name}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${space.mood.emoji} ${space.mood.label} · $weekCount / ${space.weeklyGoal} notes this week',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.55),
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.weekCount,
    required this.totalCount,
    required this.onOpen,
    required this.onEdit,
    required this.onToggleFocus,
    required this.onDelete,
  });

  final Space space;
  final int weekCount;
  final int totalCount;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onToggleFocus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.parseHex(space.colorHex);
    final progress = (weekCount / space.weeklyGoal).clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.18),
                scheme.surface.withValues(alpha: 0.96),
              ],
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.28),
                    child: Text(space.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                space.name,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (space.isFocus)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'FOCUS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${space.mood.emoji} ${space.mood.label} · $totalCount notes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'focus') onToggleFocus();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'focus',
                        child: Text(
                          space.isFocus ? 'Clear today’s focus' : 'Set as today’s focus',
                        ),
                      ),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              if (space.motto != null && space.motto!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '“${space.motto!}”',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Week goal  $weekCount / ${space.weeklyGoal}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    progress >= 1 ? 'Goal met 🎉' : 'Keep going',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.15),
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
