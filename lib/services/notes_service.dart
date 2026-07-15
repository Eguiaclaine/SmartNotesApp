import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/note.dart';
import 'realtime_service.dart';
import 'supabase_service.dart';

class NotesService {
  static const _table = 'notes';

  final RealtimeService _realtimeService = RealtimeService();

  SupabaseClient? get _client => SupabaseService.client;

  Future<List<Note>> fetchNotes(String userId) async {
    final client = _client;
    if (client == null) return [];

    final response = await client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Note.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  RealtimeChannel subscribeToNotes({
    required String userId,
    required void Function(List<Note> notes) onChanged,
    void Function(RealtimeSubscribeStatus status, Object? error)? onStatus,
  }) {
    final channel = _realtimeService.subscribeToTable(
      channelName: 'notes:$userId',
      table: _table,
      filterColumn: 'user_id',
      filterValue: userId,
      onStatus: onStatus,
      onChanged: (_) async {
        final notes = await fetchNotes(userId);
        onChanged(notes);
      },
    );

    fetchNotes(userId).then(onChanged);
    return channel;
  }

  void unsubscribe(RealtimeChannel? channel) {
    _realtimeService.unsubscribe(channel);
  }

  Future<void> createNote(Note note) async {
    final client = _client;
    if (client == null) return;
    await client.from(_table).insert(note.toSupabase());
  }

  Future<void> updateNote(Note note) async {
    final client = _client;
    if (client == null) return;

    final response = await client
        .from(_table)
        .update(note.toSupabaseUpdate())
        .eq('id', note.id)
        .eq('user_id', note.userId)
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception('Note update failed. Check connection or re-run supabase/sql/13_notes_update_fix.sql');
    }
  }

  Future<void> deleteNote(String id) async {
    final client = _client;
    if (client == null) return;
    await client.from(_table).delete().eq('id', id);
  }
}
