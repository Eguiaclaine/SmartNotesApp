import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'realtime_service.dart';
import 'supabase_service.dart';

class ProfileService {
  static const _table = 'profiles';
  static const _bucket = 'profile-avatars';

  final RealtimeService _realtimeService = RealtimeService();

  SupabaseClient? get _client => SupabaseService.client;

  Future<UserProfile?> fetchProfile(String userId) async {
    final client = _client;
    if (client == null) return null;

    final response = await client.from(_table).select().eq('id', userId).maybeSingle();
    if (response == null) return null;
    return UserProfile.fromSupabase(response);
  }

  RealtimeChannel subscribeToProfile({
    required String userId,
    required void Function(UserProfile? profile) onChanged,
    void Function(RealtimeSubscribeStatus status, Object? error)? onStatus,
  }) {
    final channel = _realtimeService.subscribeToTable(
      channelName: 'profile:$userId',
      table: _table,
      filterColumn: 'id',
      filterValue: userId,
      onStatus: onStatus,
      onChanged: (_) async {
        final profile = await fetchProfile(userId);
        onChanged(profile);
      },
    );

    fetchProfile(userId).then(onChanged);
    return channel;
  }

  void unsubscribe(RealtimeChannel? channel) {
    _realtimeService.unsubscribe(channel);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final client = _client;
    if (client == null) return profile;

    final payload = {
      'id': profile.id,
      ...profile.toSupabase(),
    };

    final response = await client.from(_table).upsert(payload).select().single();
    return UserProfile.fromSupabase(response);
  }

  Future<String?> uploadAvatar(String userId, Uint8List bytes, String fileName) async {
    final client = _client;
    if (client == null) return null;

    final path = '$userId/$fileName';
    await client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from(_bucket).getPublicUrl(path);
  }
}
