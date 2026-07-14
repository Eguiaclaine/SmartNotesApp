import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uuid/uuid.dart';



import '../models/note.dart';

import '../services/notes_service.dart';

import '../services/notification_service.dart';

import '../services/storage_service.dart';



class NotesProvider extends ChangeNotifier {

  NotesProvider(this.userId, {this.supabaseReady = true}) {

    _loadNotes();

    if (supabaseReady) {

      _subscribeRealtime();

    }

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



  List<Note> get notes => _notes;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isRealtimeConnected => _isRealtimeConnected;



  Future<void> reload() async {

    await _loadNotes();

    if (supabaseReady) {

      _resubscribeRealtime();

    }

  }



  void _subscribeRealtime() {

    _channel = _notesService.subscribeToNotes(

      userId: userId,

      onChanged: (notes) async {

        _notes = notes;

        await _storageService.saveNotes(_notes);

        await _syncReminders();

        notifyListeners();

      },

      onStatus: (status, error) {

        _isRealtimeConnected = status == RealtimeSubscribeStatus.subscribed;

        if (error != null && kDebugMode) {

          debugPrint('Notes realtime error: $error');

        }

        notifyListeners();

      },

    );

  }



  void _resubscribeRealtime() {

    _notesService.unsubscribe(_channel);

    _subscribeRealtime();

  }



  @override

  void dispose() {

    _notesService.unsubscribe(_channel);

    super.dispose();

  }



  Future<void> _loadNotes() async {

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {

      final cached = await _storageService.loadNotes();

      _notes = cached.where((note) => note.userId == userId).toList();

      notifyListeners();



      if (supabaseReady) {

        final remote = await _notesService.fetchNotes(userId);

        _notes = remote;

        await _storageService.saveNotes(_notes);

        await _syncReminders();

      }

    } catch (error) {

      _errorMessage = _friendlyError(error);

    } finally {

      _isLoading = false;

      notifyListeners();

    }

  }



  Future<void> _persistLocal() async {

    await _storageService.saveNotes(_notes);

    notifyListeners();

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

      notifyListeners();

      return false;

    }

  }



  Future<bool> updateNote(Note note) async {

    try {

      if (supabaseReady) {

        await _notesService.updateNote(note);

      }

      _notes = _notes.map((item) => item.id == note.id ? note : item).toList();

      await _persistLocal();

      await _syncNoteReminder(note);

      return true;

    } catch (error) {

      _errorMessage = _friendlyError(error);

      notifyListeners();

      return false;

    }

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

      notifyListeners();

      return false;

    }

  }



  Future<void> _syncNoteReminder(Note note) async {

    if (note.reminderAt == null) {

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

    return message.replaceFirst('Exception: ', '');

  }

}


