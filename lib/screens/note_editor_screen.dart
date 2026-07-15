import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/spaces_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/validation_utils.dart';
import '../widgets/candy_ui.dart';
import '../widgets/page_container.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  DateTime? _reminderAt;
  bool _reminderEnabled = false;
  bool _isSaving = false;
  String? _spaceId;
  String? _colorTag;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _reminderAt = widget.note?.reminderAt;
    _reminderEnabled = widget.note?.reminderAt != null;
    _spaceId = widget.note?.spaceId;
    _colorTag = widget.note?.colorTag;
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now.add(const Duration(hours: 1))),
    );
    if (time == null) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final reminderError = ValidationUtils.validateReminder(picked);
    if (reminderError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reminderError)));
      return;
    }

    await NotificationService.instance.requestPermissions();
    setState(() {
      _reminderAt = picked;
      _reminderEnabled = true;
    });
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final reminderAt = _reminderEnabled ? _reminderAt : null;
    if (_reminderEnabled && reminderAt != null) {
      final unchanged = widget.note?.reminderAt != null &&
          widget.note!.reminderAt!.isAtSameMomentAs(reminderAt);
      if (!unchanged) {
        final reminderError = ValidationUtils.validateReminder(reminderAt);
        if (reminderError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reminderError)));
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    final provider = context.read<NotesProvider>();
    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      userId: provider.userId,
      title: SanitizationUtils.sanitizeText(_titleController.text, maxLength: 100),
      content: SanitizationUtils.sanitizeText(_contentController.text, maxLength: 5000),
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      reminderAt: reminderAt,
      updatedAt: DateTime.now(),
      spaceId: _spaceId,
      colorTag: _colorTag,
      isArchived: widget.note?.isArchived ?? false,
      archivedAt: widget.note?.archivedAt,
    );

    final saved = widget.note == null
        ? await provider.addNote(note)
        : await provider.updateNote(note);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!saved) {
      final error = provider.errorMessage ?? 'Could not save note';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.watch<SpacesProvider>().spaces;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        leading: CandyIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
            child: CandyButton(
              label: 'Save',
              isLoading: _isSaving,
              expanded: false,
              onPressed: _isSaving ? null : _save,
            ),
          ),
        ],
      ),
      body: CandyBody(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        child: PageContainer(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                    counterText: '${_titleController.text.length} / 100',
                  ),
                  maxLength: 100,
                  validator: ValidationUtils.validateTitle,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    counterText: '${_contentController.text.length} / 5000',
                  ),
                  maxLines: 10,
                  maxLength: 5000,
                  validator: ValidationUtils.validateContent,
                ),
                const SizedBox(height: 22),
                const SectionLabel('Life Space'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  key: ValueKey('space-$_spaceId'),
                  initialValue: _spaceId,
                  decoration: const InputDecoration(
                    labelText: 'Organize into a space',
                    prefixIcon: Icon(Icons.auto_awesome_rounded),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No space'),
                    ),
                    ...spaces.map(
                      (space) => DropdownMenuItem<String?>(
                        value: space.id,
                        child: Text('${space.emoji} ${space.name}'),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _spaceId = value),
                ),
                const SizedBox(height: 20),
                const SectionLabel('Candy tag color'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('None'),
                      selected: _colorTag == null,
                      onSelected: (_) => setState(() => _colorTag = null),
                    ),
                    ...AppColors.spacePalette.map((color) {
                      final hex = AppColors.toHex(color);
                      final selected = _colorTag == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _colorTag = hex),
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
                                color: color.withValues(alpha: selected ? 0.5 : 0.25),
                                blurRadius: selected ? 10 : 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 22),
                const SectionLabel('Reminder'),
                const SizedBox(height: 10),
                if (_reminderEnabled && _reminderAt != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.candyBlush.withValues(alpha: 0.8),
                          scheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: scheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            formatNoteDateTime(_reminderAt!),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _pickReminder,
                  icon: const Icon(Icons.notifications_none_rounded),
                  label: Text(_reminderEnabled ? 'Change Reminder' : 'Set Reminder'),
                ),
                if (_reminderEnabled) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => setState(() {
                              _reminderAt = null;
                              _reminderEnabled = false;
                            }),
                    child: const Text('Remove Reminder'),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
