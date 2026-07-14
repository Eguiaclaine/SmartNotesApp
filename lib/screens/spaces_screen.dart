import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import '../providers/spaces_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validation_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_container.dart';

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  static const _emojiOptions = ['💗', '📚', '💼', '🎓', '🏠', '✨', '🎯', '🌈', '📝', '🧠'];

  @override
  Widget build(BuildContext context) {
    final spacesProvider = context.watch<SpacesProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Spaces'),
        actions: [
          IconButton(
            onPressed: () => _showSpaceEditor(context),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New space',
          ),
        ],
      ),
      body: spacesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : spacesProvider.spaces.isEmpty
              ? EmptyState(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Create your first Life Space',
                  subtitle:
                      'Life Spaces are your unique organizer — group notes by School, Work, Ideas, and more.',
                  action: FilledButton.icon(
                    onPressed: () => _showSpaceEditor(context),
                    icon: const Icon(Icons.add),
                    label: const Text('New Space'),
                  ),
                )
              : PageContainer(
                  child: ListView.separated(
                    itemCount: spacesProvider.spaces.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final space = spacesProvider.spaces[index];
                      final color = AppColors.parseHex(space.colorHex);
                      final count = notesProvider.notesInSpace(space.id);

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.25),
                            child: Text(space.emoji, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(
                            space.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('$count active note${count == 1 ? '' : 's'}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await _showSpaceEditor(context, spaceId: space.id);
                              } else if (value == 'filter') {
                                notesProvider.setFilterSpaceId(space.id);
                                notesProvider.setShowArchivedOnly(false);
                                if (context.mounted) Navigator.pop(context);
                              } else if (value == 'delete') {
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
                                if (confirmed == true && context.mounted) {
                                  await context.read<SpacesProvider>().deleteSpace(space.id);
                                  if (notesProvider.filterSpaceId == space.id) {
                                    notesProvider.setFilterSpaceId(null);
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'filter', child: Text('Show notes')),
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                          onTap: () {
                            notesProvider.setFilterSpaceId(space.id);
                            notesProvider.setShowArchivedOnly(false);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSpaceEditor(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('New Space'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  Future<void> _showSpaceEditor(BuildContext context, {String? spaceId}) async {
    final spacesProvider = context.read<SpacesProvider>();
    final existing = spaceId == null ? null : spacesProvider.spaceById(spaceId);
    final nameController = TextEditingController(text: existing?.name ?? '');
    var emoji = existing?.emoji ?? '💗';
    var colorHex = existing?.colorHex ?? AppColors.toHex(AppColors.spacePalette.first);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      'Organize notes beyond a plain list — your unique folders with vibe.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Space name'),
                      validator: ValidationUtils.validateSpaceName,
                    ),
                    const SizedBox(height: 16),
                    Text('Emoji', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _emojiOptions.map((item) {
                        final selected = item == emoji;
                        return ChoiceChip(
                          label: Text(item, style: const TextStyle(fontSize: 18)),
                          selected: selected,
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
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final name = SanitizationUtils.sanitizeText(
                          nameController.text,
                          maxLength: 40,
                        );
                        final ok = existing == null
                            ? await spacesProvider.addSpace(
                                name: name,
                                emoji: emoji,
                                colorHex: colorHex,
                              )
                            : await spacesProvider.updateSpace(
                                existing.copyWith(
                                  name: name,
                                  emoji: emoji,
                                  colorHex: colorHex,
                                ),
                              );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? (existing == null
                                      ? 'Life Space created'
                                      : 'Life Space updated')
                                  : 'Could not save Life Space',
                            ),
                          ),
                        );
                      },
                      child: Text(existing == null ? 'Create Space' : 'Save Space'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
  }
}
