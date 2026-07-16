import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../services/notes_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider(this.userId, {this.supabaseReady = true}) {
    scheduleMicrotask(() async {
      if (_disposed) return;
      await _loadNotes();
      if (_disposed || !supabaseReady) return;
      _subscribeRealtime();
    });
  }

  final String userId;
  final bool supabaseReady;
  final StorageService _storageService = StorageService();
  final NotesService _notesService = NotesService();
  final NotificationService _notificationService = NotificationService.instance;

  RealtimeChannel? _channel;
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRealtimeConnected = false;
  String _searchQuery = '';
  String? _filterSpaceId;
  bool _showArchivedOnly = false;
  bool _disposed = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRealtimeConnected => _isRealtimeConnected;
  String get searchQuery => _searchQuery;
  String? get filterSpaceId => _filterSpaceId;
  bool get showArchivedOnly => _showArchivedOnly;

  List<Note> get activeNotes =>
      _notes.where((note) => !note.isArchived).toList();

  List<Note> get archivedNotes =>
      _notes.where((note) => note.isArchived).toList();

  List<Note> get visibleNotes {
    final source = _showArchivedOnly ? archivedNotes : activeNotes;
    var filtered = source;

    if (_filterSpaceId != null) {
      filtered = filtered.where((note) => note.spaceId == _filterSpaceId).toList();
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (note) =>
                note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  int notesInSpace(String spaceId) =>
      activeNotes.where((note) => note.spaceId == spaceId).length;

  /// Active notes created in this space during the current calendar week.
  int notesInSpaceThisWeek(String spaceId) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return activeNotes.where((note) {
      if (note.spaceId != spaceId) return false;
      return !note.createdAt.isBefore(startOfWeek);
    }).length;
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _safeNotify();
  }

  void setFilterSpaceId(String? spaceId) {
    _filterSpaceId = spaceId;
    _safeNotify();
  }

  void setShowArchivedOnly(bool value) {
    _showArchivedOnly = value;
    _safeNotify();
  }

  /// Home header “All notes”: clear space filter + leave Archive.
  bool get isShowingAllNotes =>
      !_showArchivedOnly && _filterSpaceId == null;

  void showAllNotes() {
    _showArchivedOnly = false;
    _filterSpaceId = null;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> reload() async {
    await _loadNotes();
    if (_disposed || !supabaseReady) return;
    _resubscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = _notesService.subscribeToNotes(
      userId: userId,
      onChanged: (notes) async {
        if (_disposed) return;
        _notes = notes;
        await _storageService.saveNotes(_notes);
        await _syncReminders();
        _safeNotify();
      },
      onStatus: (status, error) {
        if (_disposed) return;
        _isRealtimeConnected = status == RealtimeSubscribeStatus.subscribed;
        if (error != null && kDebugMode) {
          debugPrint('Notes realtime error: $error');
        }
        _safeNotify();
      },
    );
  }

  void _resubscribeRealtime() {
    _notesService.unsubscribe(_channel);
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _disposed = true;
    _notesService.unsubscribe(_channel);
    super.dispose();
  }

  Future<void> _loadNotes() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();
    try {
      final cached = await _storageService.loadNotes();
      if (_disposed) return;
      _notes = cached.where((note) => note.userId == userId).toList();
      _safeNotify();

      if (supabaseReady) {
        final remote = await _notesService
            .fetchNotes(userId)
            .timeout(const Duration(seconds: 15));
        if (_disposed) return;
        _notes = remote;
        await _storageService.saveNotes(_notes);
        await _syncReminders();
      }
    } on TimeoutException {
      _errorMessage = 'Notes took too long to load. Pull to refresh.';
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> _persistLocal() async {
    await _storageService.saveNotes(_notes);
    _safeNotify();
  }

  Future<void> _syncReminders() async {
    for (final note in _notes) {
      await _syncNoteReminder(note);
    }
  }

  Future<bool> addNote(Note note) async {
    try {
      if (supabaseReady) {
        await _notesService.createNote(note);
      }
      _notes = [note, ..._notes];
      await _persistLocal();
      await _syncNoteReminder(note);
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _safeNotify();
      return false;
    }
  }

  Future<bool> updateNote(Note note) async {
    try {
      if (supabaseReady) {
        await _notesService.updateNote(note);
      }
      if (_disposed) return false;
      _notes = _notes.map((item) => item.id == note.id ? note : item).toList();
      _errorMessage = null;
      await _persistLocal();
      await _syncNoteReminder(note);
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _safeNotify();
      return false;
    }
  }

  Future<bool> archiveNote(String id) async {
    final existing = _notes.where((note) => note.id == id).firstOrNull;
    if (existing == null) return false;
    return updateNote(
      existing.copyWith(
        isArchived: true,
        archivedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        clearReminder: true,
      ),
    );
  }

  Future<bool> restoreNote(String id) async {
    final existing = _notes.where((note) => note.id == id).firstOrNull;
    if (existing == null) return false;
    return updateNote(
      existing.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
        clearArchivedAt: true,
      ),
    );
  }

  Future<bool> deleteNote(String id) async {
    try {
      if (supabaseReady) {
        await _notesService.deleteNote(id);
      }
      _notes.removeWhere((note) => note.id == id);
      await _persistLocal();
      await _notificationService.cancelNoteReminder(id);
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _safeNotify();
      return false;
    }
  }

  Future<void> _syncNoteReminder(Note note) async {
    if (note.isArchived || note.reminderAt == null) {
      await _notificationService.cancelNoteReminder(note.id);
      return;
    }

    if (!note.reminderAt!.isAfter(DateTime.now())) {
      await _notificationService.cancelNoteReminder(note.id);
      return;
    }

    try {
      await _notificationService.requestPermissions();
      await _notificationService.scheduleNoteReminder(
        noteId: note.id,
        title: note.title,
        body: note.content,
        reminderAt: note.reminderAt!,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Reminder schedule failed for ${note.id}: $error');
      }
    }
  }

  Note createDraft() => Note(
        id: const Uuid().v4(),
        userId: userId,
        title: '',
        content: '',
        createdAt: DateTime.now(),
      );

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('Reminder must be in the future')) {
      return 'Reminder must be in the future when set.';
    }
    if (message.contains('violates check constraint')) {
      return 'Note could not be saved. Check title, content, and reminder values.';
    }
    if (message.contains('space_id') || message.contains('is_archived')) {
      return 'Database schema needs update. Run supabase/sql/10_spaces_archive.sql in Supabase.';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
