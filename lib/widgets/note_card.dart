import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/space.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onArchiveOrRestore,
    required this.onDelete,
    this.space,
    this.isArchiveView = false,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onArchiveOrRestore;
  final VoidCallback onDelete;
  final Space? space;
  final bool isArchiveView;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = note.colorTag != null
        ? AppColors.parseHex(note.colorTag!)
        : (space != null ? AppColors.parseHex(space!.colorHex) : scheme.primary);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: accent.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.18),
                scheme.surface.withValues(alpha: 0.98),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 42,
                      margin: const EdgeInsets.only(top: 4, right: 12),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Note actions',
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: scheme.primary.withValues(alpha: 0.85),
                      ),
                      onSelected: (value) {
                        if (value == 'archive') onArchiveOrRestore();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'archive',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isArchiveView
                                  ? Icons.unarchive_rounded
                                  : Icons.archive_outlined,
                            ),
                            title: Text(isArchiveView ? 'Restore' : 'Archive'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.delete_outline_rounded),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (space != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.parseHex(space!.colorHex).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.parseHex(space!.colorHex).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '${space!.emoji} ${space!.name}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _MetaRow(
                      icon: Icons.schedule_rounded,
                      label: formatNoteDateTime(note.createdAt),
                    ),
                    if (note.reminderAt != null)
                      _MetaRow(
                        icon: Icons.notifications_active_rounded,
                        label: formatNoteDateTime(note.reminderAt!),
                        color: scheme.primary,
                      ),
                    if (note.isArchived)
                      _MetaRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Archived',
                        color: scheme.tertiary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: tone),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: tone,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
