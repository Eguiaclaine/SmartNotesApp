import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/space.dart';
import 'realtime_service.dart';
import 'supabase_service.dart';

class SpacesService {
  static const _table = 'spaces';

  final RealtimeService _realtimeService = RealtimeService();

  SupabaseClient? get _client => SupabaseService.client;

  Future<List<Space>> fetchSpaces(String userId) async {
    final client = _client;
    if (client == null) return [];

    final response = await client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((row) => Space.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  RealtimeChannel subscribeToSpaces({
    required String userId,
    required void Function(List<Space> spaces) onChanged,
    void Function(RealtimeSubscribeStatus status, Object? error)? onStatus,
  }) {
    final channel = _realtimeService.subscribeToTable(
      channelName: 'spaces:$userId',
      table: _table,
      filterColumn: 'user_id',
      filterValue: userId,
      onStatus: onStatus,
      onChanged: (_) async {
        final spaces = await fetchSpaces(userId);
        onChanged(spaces);
      },
    );

    fetchSpaces(userId).then(onChanged);
    return channel;
  }

  void unsubscribe(RealtimeChannel? channel) {
    _realtimeService.unsubscribe(channel);
  }

  Future<void> createSpace(Space space) async {
    final client = _client;
    if (client == null) return;

    final response = await client
        .from(_table)
        .insert(space.toSupabase())
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception(
        'Life Space create failed. Run supabase/sql/14_life_spaces_align.sql in Supabase.',
      );
    }
  }

  Future<void> updateSpace(Space space) async {
    final client = _client;
    if (client == null) return;

    final response = await client
        .from(_table)
        .update(space.toSupabaseUpdate())
        .eq('id', space.id)
        .eq('user_id', space.userId)
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception(
        'Life Space update failed. Run supabase/sql/14_life_spaces_align.sql in Supabase.',
      );
    }
  }

  Future<void> deleteSpace(String id) async {
    final client = _client;
    if (client == null) return;
    await client.from(_table).delete().eq('id', id);
  }
}
