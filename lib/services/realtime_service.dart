import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

typedef RealtimeChangeCallback = void Function(PostgresChangePayload payload);

class RealtimeService {
  RealtimeChannel subscribeToTable({
    required String channelName,
    required String table,
    required String filterColumn,
    required String filterValue,
    required RealtimeChangeCallback onChanged,
    void Function(RealtimeSubscribeStatus status, Object? error)? onStatus,
  }) {
    final client = SupabaseService.client!;
    final channel = client.channel(
      channelName,
      opts: const RealtimeChannelConfig(ack: true),
    );

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: filterColumn,
            value: filterValue,
          ),
          callback: onChanged,
        )
        .subscribe((status, error) {
          onStatus?.call(status, error);
        });

    return channel;
  }

  void unsubscribe(RealtimeChannel? channel) {
    if (channel != null) {
      SupabaseService.client?.removeChannel(channel);
    }
  }
}
